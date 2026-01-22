//
//  GeomPolar.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//

import Foundation
import tdLB
import tdLBGeometry




public struct RushtonTurbinePolarSwift: Geometry {
 
    
    typealias T = Int
    typealias TQ = Float
    
    public var gridX, gridY, gridZ: Int
    public let startingStep: Int
    
    let uav: Double
    let impellerStartupStepsUntilNormalSpeed: Int
    let impellerStartAngle: Double
    
    public let turbine: RushtonTurbine
    public let output: OutputGeometry
    
    var impellerIncrementFullStep: TQ = 0
    var impellerCurrentAngle: TQ = 0
    
    
    public var geomFixed: [Pos3d]
    public var geomRotating: [Pos3d]
    public var geomRotatingNonUpdating: [Pos3d]
    public var geomTranslating: [Pos3d]
    
    
    //    public var geomFixed: [PosPolar<Int, Float>]
    //
    //    public var geomRotating: [PosPolar<Int, Float>]
    //
    //    public var geomTranslating: [PosPolar<Int, Float>]
    //
    
    private let diameterBorder = 2

    public var tankRadius: Int { return (turbine.gridX - diameterBorder) / 2 }
    public var tankDiameter: Int { return turbine.tankDiameter - diameterBorder }
    public var iCenter: Int { return tankRadius + diameterBorder / 2 }
    public var kCenter: Int { return tankRadius + diameterBorder / 2 }


    public init(turbine: RushtonTurbine) {
        self.turbine = turbine
        self.output = exampleTurbineOutput(turbine: turbine)

        self.gridX = self.turbine.gridX
        self.gridY = self.turbine.gridX
        self.gridZ = self.turbine.gridX

        // Use max uav from all impellers for startup calculation
        self.uav = self.turbine.impellers.values.map { $0.uav }.max() ?? 0.1

        self.startingStep = self.turbine.startingStep
        self.impellerStartupStepsUntilNormalSpeed = self.turbine.impellerStartupStepsUntilNormalSpeed
        self.impellerStartAngle = self.turbine.impellerStartAngle

        geomFixed = []
        geomRotating = []
        geomRotatingNonUpdating = []
        geomTranslating = []
    }


    public init(fileName: String, outputJson: String) throws {
        self.turbine = try RushtonTurbine(fileName)
        self.output = try OutputGeometry(json: outputJson)

        self.gridX = self.turbine.gridX
        self.gridY = self.turbine.gridX
        self.gridZ = self.turbine.gridX

        // Use max uav from all impellers for startup calculation
        self.uav = self.turbine.impellers.values.map { $0.uav }.max() ?? 0.1

        self.startingStep = self.turbine.startingStep
        self.impellerStartupStepsUntilNormalSpeed = self.turbine.impellerStartupStepsUntilNormalSpeed
        self.impellerStartAngle = self.turbine.impellerStartAngle

        geomFixed = []
        geomRotating = []
        geomRotatingNonUpdating = []
        geomTranslating = []
    }
    
    
    
    public func returnFixedGeometry() -> [Pos3d]{
        return self.geomFixed
    }
    
    public func returnRotatingNonUpdatingGeometry() -> [Pos3d] {
        return self.geomRotatingNonUpdating
    }
    
    public func returnRotatingGeometry() -> [Pos3d] {
        return self.geomRotating
    }
    
    public func returnTranslatingGeometry() -> [Pos3d] {
        return self.geomTranslating
    }
    
    
    public mutating func generateFixedGeometry() {
        generateTankWall()
        generateBaffles()
    }
    
    public mutating func generateRotatingNonUpdatingGeometry() {
        // Generate geometry for all impellers
        for (_, impeller) in turbine.impellers {
            createImpellerHub(impeller: impeller, atθ: 0)
            createImpellerDisk(impeller: impeller, atθ: 0)
        }
        // Shaft is shared across all impellers
        createImpellerShaft(atθ: 0)
    }

    public mutating func generateRotatingGeometry(atθ: Float) {
        // Generate blade geometry for all impellers
        for (_, impeller) in turbine.impellers {
            createImpellerBlades(impeller: impeller, atθ: atθ)
        }
    }
    
    public mutating func updateRotatingGeometry(atθ: Float) {

        self.geomRotating.removeAll()

        generateRotatingGeometry(atθ: atθ)
    }
    
    public mutating func generateTranslatingGeometry() {
        
    }
    
    public mutating func updateTranslatingGeometry(atStep step: Int) {
        
    }
    
    
}//end of struct




extension RushtonTurbinePolarSwift {
    
    func calcImpellerIncrement(atStep step: Int) -> TQ {
        if step >= self.turbine.impellerStartupStepsUntilNormalSpeed {
            return impellerIncrementFullStep
        }

        // Use max angular velocity from all impellers
        let maxAngularVel = turbine.impellers.values.map { $0.bladeTipAngularVelW0 }.max() ?? 0.0
        return 0.5 * TQ(maxAngularVel) * (1.0 - cos(TQ.pi * TQ(step) / TQ(self.turbine.impellerStartupStepsUntilNormalSpeed)))
    }
    
    
    
    
    
    mutating func generateTankWall() {
        
        let tankHeight = self.tankDiameter
        let resolution = TQ(self.turbine.resolution)
        
        let nCircPoints: Int = 4 * Int((TQ.pi * TQ(self.tankDiameter) / (4.0 * resolution)))
        let dTheta: TQ = 2 * TQ.pi / TQ(nCircPoints)
        let r: TQ = 0.5 * TQ(self.tankDiameter)
        
        for j in 0..<tankHeight {
            for k in 0..<nCircPoints {
                
                var theta: TQ = TQ(k) * dTheta
                if (j & 1) == 1 {theta += 0.5 * dTheta}
                
                let g = PosPolar<T, TQ>(
                    iFP: TQ(self.iCenter) + r * cos(theta),
                    jFP: TQ(j),
                    kFP: TQ(self.kCenter) + r * sin(theta),
                    uDelta: 0.0,
                    vDelta: 0.0,
                    wDelta: 0.0
                )
                
                self.geomFixed.append(g.getPos3d())
                
            }
        }
    }
    
    mutating func generateBaffles() {
        
        let tankHeight = self.tankDiameter
        
        let resolution = TQ(self.turbine.resolution)
        
        var nPointsBaffleThickness = Int(TQ(turbine.baffles.thickness) / resolution)
        if nPointsBaffleThickness == 0 {nPointsBaffleThickness = 1}
        
        let resolutionBaffleThickness: TQ = TQ(self.turbine.baffles.thickness) / TQ(nPointsBaffleThickness)
        
        let nPointsR: Int = Int(TQ(self.turbine.baffles.outerRadius - self.turbine.baffles.innerRadius) / resolution)
        
        let deltaR: TQ = TQ((self.turbine.baffles.outerRadius - self.turbine.baffles.innerRadius)) / TQ(nPointsR)
        
        let deltaBaffleOffset: TQ = 2.0/TQ(self.turbine.baffles.numBaffles) * TQ.pi
        
        for nBaffle in 0..<self.turbine.baffles.numBaffles {
            
            for j in 0..<tankHeight {
                for idxR in 0...nPointsR {
                    let r: TQ = TQ(self.turbine.baffles.innerRadius) + deltaR * TQ(idxR)
                    for idxTheta in 0...nPointsBaffleThickness {
                        
                        let theta0: TQ = TQ(self.turbine.baffles.firstBaffleOffset) + deltaBaffleOffset * TQ(nBaffle)
                        
                        let theta = theta0 + (TQ(idxTheta - nPointsBaffleThickness) / 2.0) * resolutionBaffleThickness / r
                        
                        let isSurface: Bool = idxTheta == 0 || idxTheta == nPointsBaffleThickness || idxR == 0 || idxR == nPointsR
                        
                        let g = PosPolar<T, TQ>(
                            iFP: TQ(self.iCenter) + r * cos(theta),
                            jFP: TQ(j),
                            kFP: TQ(self.kCenter) + r * sin(theta),
                            uDelta: 0.0,
                            vDelta: 0.0,
                            wDelta: 0.0
                        )
                        
                        if isSurface {
                            self.geomFixed.append(g.getPos3d())
                        }
                    }
                }
            }
        }
    }
    
    mutating func createImpellerBlades(impeller: Impeller, atθ angle: TQ) {
        
        let innerRadius = TQ(impeller.blades.innerRadius)
        let outerRadius = TQ(impeller.blades.outerRadius)
        
        let resolution = TQ(self.turbine.resolution)
        
        let nPointsR = Int(TQ(outerRadius - innerRadius) / resolution)
        var nPointsThickness = Int(TQ(impeller.blades.thickness) / resolution)
        if nPointsThickness == 0 {nPointsThickness = 1}
        
        let resolutionBladeThickness: TQ = TQ(impeller.blades.thickness) / TQ(nPointsThickness)
        
        let deltaR = (outerRadius - innerRadius) / TQ(nPointsR)
        
        let deltaTheta: TQ = 2.0 / TQ(impeller.numBlades) * TQ.pi
        
        for nBlade in 1...impeller.numBlades {
            for j in impeller.blades.top...impeller.blades.bottom {
                for idxR in 0...nPointsR {
                    
                    let r: TQ = innerRadius + deltaR * TQ(idxR)
                    
                    for idxThickness in 0...nPointsThickness {
                        
                        let offset: TQ = deltaTheta * TQ(nBlade) + TQ(impeller.firstBladeOffset)
                        
                        let theta = offset + (TQ(idxThickness - nPointsThickness) / 2.0) * resolutionBladeThickness / r
                        
                        let insideDisk: Bool = (Int(r) <= impeller.disk.radius) && (j >= impeller.disk.bottom) && (j <= impeller.disk.top)
                        if insideDisk {continue}
                        
                        let isSurface:Bool = idxThickness == 0 || idxThickness == nPointsThickness || idxR == 0 || idxR == nPointsR || j == impeller.blades.bottom || j == impeller.blades.top
                        
                        let g = PosPolar<T, TQ>(
                            iFP: TQ(self.iCenter) + r * cos(theta),
                            jFP: TQ(j),
                            kFP: TQ(self.kCenter) + r * sin(theta),
                            
                            uDelta: -angle * TQ(r) * sin(theta),
                            vDelta: 0,
                            wDelta:  angle * TQ(r) * cos(theta)
                        )
                        
                        if isSurface {
                            self.geomRotating.append(g.getPos3d())
                        }
                        
                    }
                }
            }
        }
        
    }
    
    mutating func createImpellerDisk(impeller: Impeller, atθ angle: TQ) {
        
        let hubRadius = TQ(impeller.hub.radius)
        let diskRadius = TQ(impeller.disk.radius)
        
        let nPointsR: Int = Int(round((diskRadius - hubRadius) / TQ(self.turbine.resolution)))
        let deltaR: TQ = (diskRadius - hubRadius) / TQ(nPointsR)
        
        let resolution = TQ(self.turbine.resolution)
        
        for j in impeller.disk.top...impeller.disk.bottom {
            
            for idxR in 1...nPointsR {
                
                let r: TQ = TQ(hubRadius) + TQ(idxR) * deltaR
                var dTheta: TQ = 0
                var nPointsTheta: Int = Int(2 * TQ.pi * r / resolution)
                
                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2.0 * TQ.pi / TQ(nPointsTheta)
                }
                
                var theta0: TQ = TQ(impeller.firstBladeOffset)
                if (idxR & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }
                if (j & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }
                
                for idxTheta in 0...nPointsTheta - 1 {
                    
                    let isSurface: Bool = j == impeller.disk.bottom || j == impeller.disk.top || idxR == nPointsR
                    
                    let t_polar = theta0 + TQ(idxTheta) * dTheta
                    let g = PosPolar<T, TQ>(
                        iFP: TQ(self.iCenter) + r * cos(t_polar),
                        jFP: TQ(j),
                        kFP: TQ(self.kCenter) + r * sin(t_polar),
                        
                        uDelta: -angle * TQ(r) * sin(t_polar),
                        vDelta: 0,
                        wDelta: angle * TQ(r) * cos(t_polar)
                    )
                    
                    
                    if isSurface {
                        self.geomRotatingNonUpdating.append(g.getPos3d())
                    }
                    
                }
            }
        }
        
    }
    
    mutating func createImpellerHub(impeller: Impeller, atθ angle: TQ) {
        let hubRadius: TQ = TQ(impeller.hub.radius)
        
        let nPointsR: Int = Int((hubRadius - TQ(self.turbine.shaft.radius)) / TQ(self.turbine.resolution))
        let resolutionR: TQ = (hubRadius - TQ(self.turbine.shaft.radius)) / TQ(nPointsR)
        
        for j in impeller.hub.top...impeller.hub.bottom {
            
            let isWithinDisk:Bool = j >= impeller.disk.bottom && j <= impeller.disk.top
            
            for idxR in 1...nPointsR {
                
                let r: TQ = TQ(self.turbine.shaft.radius) + TQ(idxR) * resolutionR
                var nPointsTheta: Int = Int(2 * .pi * r / TQ(self.turbine.resolution))
                var dTheta: TQ
                
                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2 * .pi / TQ(nPointsTheta)
                }
                
                var theta0: TQ = TQ(impeller.firstBladeOffset)
                
                
                if (idxR & 1) == 0 {theta0 += 0.5 * dTheta}
                if (j & 1) == 0 {theta0 += 0.5 * dTheta}
                
                for idxTheta in 0..<nPointsTheta {
                    
                    let isSurface:Bool = (j == impeller.hub.bottom || j == impeller.hub.top || idxR == nPointsR) && !isWithinDisk
                    
                    let t_polar = theta0 + TQ(idxTheta) * dTheta
                    let g = PosPolar<T, TQ>(
                        iFP: TQ(self.iCenter) + r * cos(t_polar),
                        jFP: TQ(j),
                        kFP: TQ(self.kCenter) + r * sin(t_polar),
                        uDelta: -angle * TQ(r) * sin(t_polar),
                        vDelta: 0,
                        wDelta: angle * TQ(r) * cos(t_polar)
                    )
                    
                    if isSurface {
                        self.geomRotatingNonUpdating.append(g.getPos3d())
                    }
                }
            }
        }
    }
    
    mutating func createImpellerShaft(atθ angle: TQ) {
        for j in 0..<self.turbine.tankHeight {
            // Check if this height is within any impeller's hub
            let isWithinAnyHub = turbine.impellers.values.contains { impeller in
                j > impeller.hub.bottom && j < impeller.hub.top
            }

            let rEnd: TQ = TQ(self.turbine.shaft.radius)
            let nPointsR: Int = Int(rEnd / TQ(self.turbine.resolution))

            for idxR in 0...nPointsR {
                var r: TQ = 0
                var dTheta: TQ = 0
                var nPointsTheta: Int = 0

                if idxR == 0 {
                    r = 0
                    nPointsTheta = 1
                    dTheta = 0
                } else {
                    r = TQ(idxR) * TQ(self.turbine.resolution)
                    nPointsTheta = 4 * Int((.pi * 2.0 * r / (4.0 * TQ(self.turbine.resolution))))

                    if nPointsTheta == 0 { nPointsTheta = 1 }

                    dTheta = 2 * .pi / TQ(nPointsTheta)
                }

                for idxTheta in 0..<nPointsTheta {
                    var theta: TQ = TQ(idxTheta) * dTheta

                    if (j & 1) == 0 { theta += 0.5 * dTheta }

                    let isSurface: Bool = idxR == nPointsR && !isWithinAnyHub

                    let g = PosPolar<T, TQ>(
                        iFP: TQ(self.iCenter) + r * cos(theta),
                        jFP: TQ(j),
                        kFP: TQ(self.kCenter) + r * sin(theta),
                        uDelta: -angle * TQ(r) * sin(theta),
                        vDelta: 0,
                        wDelta: angle * TQ(r) * cos(theta))

                    if isSurface {
                        self.geomRotatingNonUpdating.append(g.getPos3d())
                    }
                }
            }
        }
    }
    
}//end of extension


