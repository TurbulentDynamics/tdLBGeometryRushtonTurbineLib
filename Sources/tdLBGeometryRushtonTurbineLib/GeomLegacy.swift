//
//  GeometryLegacy.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//

import Foundation
import tdLB
import tdLBGeometry
import tdLBOutputGeometry


public struct RushtonTurbineLegacy: Geometry {
    

    public var gridX, gridY, gridZ: Int
    public let startingStep: Int
    
    let uav: Double
    let impellerStartupStepsUntilNormalSpeed: Int
    let impellerStartAngle: Double

    public let turbine: RushtonTurbine
    public let output: OutputGeometry

    var impellerIncrementFullStep: Radian = 0
    var impellerCurrentAngle: Radian = 0

    public var geomFixed = [RotatingGeomPoints]()
    public var geomRotating = [RotatingGeomPoints]()

    public var centerI: Int {return (gridX - turbine.tankDiameter) / 2 + turbine.tankDiameter}
    public var centerK: Int {return centerI}




    public init(gridX: Int, gridY: Int, gridZ: Int,
                uav: Double,
                impellerStartupStepsUntilNormalSpeed s: Int = 0, startingStep: Int = 0,
                impellerStartAngle: Double = 0.0) {

        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ

        self.uav = uav
        self.startingStep = startingStep
        self.impellerStartupStepsUntilNormalSpeed = s

        self.impellerStartAngle = impellerStartAngle

        self.impellerCurrentAngle = 0

        //TODO make selectable, Eggels or Load Json or other...
        self.turbine = getEggelsSomersGeometry(gridX: gridX, uav: uav, impellerStartupStepsUntilNormalSpeed: s, startingStep: startingStep, impellerStartAngle: impellerStartAngle)

        self.output = exampleTurbineOutput(turbine: self.turbine)
        
        generateFixedGeometry()
        generateRotatingGeometry(atθ: Radian(impellerStartAngle))

    }


    public init(fileName: String, outputJson: String) throws {

        self.turbine = try RushtonTurbine(fileName)
        self.output = try OutputGeometry(json: outputJson)

        self.gridX = self.turbine.gridx
        self.gridY = self.turbine.gridx
        self.gridZ = self.turbine.gridx

        self.uav = self.turbine.impeller["0"]!.uav
        self.startingStep = self.turbine.startingStep
        self.impellerStartupStepsUntilNormalSpeed = self.turbine.impellerStartupStepsUntilNormalSpeed
        self.impellerStartAngle = self.turbine.impellerStartAngle

    }

    public mutating func generateFixedGeometry() {
        generateTankWallLegacy()
        generateBafflesLegacy()
    }
    
    public mutating func generateRotatingGeometry(atθ: Radian) {
        let increment = calcImpellerIncrement(atStep: 0)
        createImpellerHubLegacy(withIncrement: increment)
        createImpellerDiskLegacy(withIncrement: increment)
        createImpellerShaftLegacy(withIncrement: increment)
        createImpellerBladesLegacy(withIncrement: increment)
    }
    
    public mutating func updateGeometry(forStep step: Int) {

        let impellerIncrementThisStep: Radian = calcImpellerIncrement(atStep: step)

        impellerCurrentAngle += impellerIncrementThisStep

        for g in 0..<geomRotating.count {

            geomRotating[g].t_polar += impellerIncrementThisStep

            geomRotating[g].iCartFP = Radian(centerI) + geomRotating[g].r_polar * cos(geomRotating[g].t_polar)
            geomRotating[g].jCartFP = 0
            geomRotating[g].kCartFP = Radian(centerK) + geomRotating[g].r_polar * sin(geomRotating[g].t_polar)

            geomRotating[g].uDelta = -impellerIncrementThisStep * geomRotating[g].r_polar * sin(geomRotating[g].t_polar)
            geomRotating[g].vDelta = 0
            geomRotating[g].wDelta =  impellerIncrementThisStep * geomRotating[g].r_polar * cos(geomRotating[g].t_polar)

        }
    }

    public func getFixedPointCloud() -> [PointCloudVertex] {
        var pts = [PointCloudVertex]()
        for g in 0..<geomFixed.count {

            pts.append(PointCloudVertex(i: geomFixed[g].iCart, j: geomFixed[g].jCart, k: geomFixed[g].kCart, t: .fixed))
        }
        return pts
    }

    public func getRotatingPointCloud() -> [PointCloudVertex] {
        var pts = [PointCloudVertex]()

        for g in 0..<geomRotating.count {
            pts.append(PointCloudVertex(i: geomRotating[g].iCart, j: geomRotating[g].jCart, k: geomRotating[g].kCart, t: .rotating))

        }
        return pts
    }

}//end of struct

extension RushtonTurbineLegacy {

    func calcImpellerIncrement(atStep step: Int) -> Radian {

        if step >= turbine.impellerStartupStepsUntilNormalSpeed {
            return impellerIncrementFullStep
        }
        return 0.5 * Radian(turbine.impeller["0"]!.bladeTipAngularVelW0) * (1.0 - cos(Radian.pi * Radian(step) / Radian(turbine.impellerStartupStepsUntilNormalSpeed)))
    }

    mutating func generateTankWallLegacy() {

        let tankHeight = turbine.tankDiameter
        let resolution = Radian(turbine.resolution)

        let nCircPoints: Int = 4 * Int((Radian.pi * Radian(turbine.tankDiameter) / (4.0 * resolution)))
        let dTheta: Radian = 2 * Radian.pi / Radian(nCircPoints)
        let r: Radian = 0.5 * Radian(turbine.tankDiameter)

        for j in 0..<tankHeight {
            for k in 0..<nCircPoints {

                var theta: Radian = Radian(k) * dTheta
                if (j & 1) == 1 {theta += 0.5 * dTheta}

                let g = RotatingGeomPoints(
                    iCartFP: Radian(centerI) + r * cos(theta),
                    jCartFP: Radian(j) + 0.5,
                    kCartFP: Radian(centerK) + r * sin(theta))
                //                    g.resolution = resolution

                geomFixed.append(g)

            }
        }
    }

    mutating func generateBafflesLegacy() {

        let tankHeight = turbine.tankDiameter

        let resolution = Radian(turbine.resolution)

        var nPointsBaffleThickness = Int(Radian(turbine.baffles.thickness) / resolution)
        if nPointsBaffleThickness == 0 {nPointsBaffleThickness = 1}

        let resolutionBaffleThickness: Radian = Radian(turbine.baffles.thickness) / Radian(nPointsBaffleThickness)

        let nPointsR: Int = Int(Radian(turbine.baffles.outerRadius - turbine.baffles.innerRadius) / resolution)

        let deltaR: Radian = Radian((turbine.baffles.outerRadius - turbine.baffles.innerRadius)) / Radian(nPointsR)

        let deltaBaffleOffset: Radian = 2.0/Radian(turbine.baffles.numBaffles) * Radian.pi

        for nBaffle in 0..<turbine.baffles.numBaffles {

            for j in 0..<tankHeight {
                for idxR in 0...nPointsR {
                    let r: Radian = Radian(turbine.baffles.innerRadius) + deltaR * Radian(idxR)
                    for idxTheta in 0...nPointsBaffleThickness {

                        let theta0: Radian = Radian(turbine.baffles.firstBaffleOffset) + deltaBaffleOffset * Radian(nBaffle)

                        let theta = theta0 + (Radian(idxTheta - nPointsBaffleThickness) / 2.0) * resolutionBaffleThickness / r

//                        let isSurface: Bool = idxTheta == 0 || idxTheta == nPointsBaffleThickness || idxR == 0 || idxR == nPointsR

                        let g = RotatingGeomPoints(
                            iCartFP: Radian(centerI) + r * cos(theta),
                            jCartFP: Radian(j) + 0.5,
                            kCartFP: Radian(centerK) + r * sin(theta))
                        //                    g.resolution = resolution

                        //                        if isSurface {
                        //Both surface and internal elements should be added??????
                        geomFixed.append(g)
                        //                        }

                    }
                }
            }
        }

    }

    mutating func createImpellerBladesLegacy(withIncrement angle: Radian) {

        let impeller = turbine.impeller

        let innerRadius = Radian(impeller["0"]!.blades.innerRadius)
        let outerRadius = Radian(impeller["0"]!.blades.outerRadius)

        let resolution = Radian(turbine.resolution)

        let nPointsR = Int(Radian(outerRadius - innerRadius) / resolution)
        var nPointsThickness = Int(Radian(impeller["0"]!.blades.thickness) / resolution)
        if nPointsThickness == 0 {nPointsThickness = 1}

        let resolutionBladeThickness: Radian = Radian(impeller["0"]!.blades.thickness) / Radian(nPointsThickness)

        let deltaR = (outerRadius - innerRadius) / Radian(nPointsR)

        let deltaTheta: Radian = 2.0 / Radian(impeller["0"]!.numBlades) * Radian.pi

        for nBlade in 1...impeller["0"]!.numBlades {
            for j in impeller["0"]!.blades.top...impeller["0"]!.blades.bottom {
                for idxR in 0...nPointsR {

                    let r: Radian = innerRadius + deltaR * Radian(idxR)

                    for idxThickness in 0...nPointsThickness {

                        let offset: Radian = deltaTheta * Radian(nBlade) + Radian(impeller["0"]!.firstBladeOffset)

                        let theta = offset + (Radian(idxThickness - nPointsThickness) / 2.0) * resolutionBladeThickness / r

                        let insideDisk: Bool = (Int(r) <= impeller["0"]!.disk.radius) && (j >= impeller["0"]!.disk.bottom) && (j <= impeller["0"]!.disk.top)
                        if insideDisk {continue}

//                        let isSurface:Bool = idxThickness == 0 || idxThickness == nPointsThickness || idxR == 0 || idxR == nPointsR || j == impeller.blades.bottom || j == impeller.blades.top

                        let g = RotatingGeomPoints(
                            r_polar: Radian(r),
                            t_polar: theta,

                            iCartFP: Radian(centerI) + r * cos(theta),
                            jCartFP: Radian(j) + 0.5,
                            kCartFP: Radian(centerK) + r * sin(theta),

                            uDelta: -angle * Radian(r) * sin(theta),
                            vDelta: 0,
                            wDelta: angle * Radian(r) * cos(theta))
                        //                    g.resolution = resolution

                        //                        if isSurface {
                        //Both surface and internal elements should be added??????
                        geomRotating.append(g)
                        //                        }

                    }
                }
            }
        }

    }

    mutating func createImpellerDiskLegacy(withIncrement angle: Radian) {
        let impeller = turbine.impeller["0"]!

        let hubRadius = Radian(impeller.hub.radius)
        let diskRadius = Radian(impeller.disk.radius)

        let nPointsR: Int = Int(round((diskRadius - hubRadius) / Radian(turbine.resolution)))
        let deltaR: Radian = (diskRadius - hubRadius) / Radian(nPointsR)

        let resolution = Radian(turbine.resolution)

        for j in impeller.disk.top...impeller.disk.bottom {

            for idxR in 1...nPointsR {

                let r: Radian = Radian(hubRadius) + Radian(idxR) * deltaR
                var dTheta: Radian = 0
                var nPointsTheta: Int = Int(2 * Radian.pi * r / resolution)

                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2.0 * Radian.pi / Radian(nPointsTheta)
                }

                var theta0: Radian = Radian(impeller.firstBladeOffset)
                if (idxR & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }
                if (j & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }

                for idxTheta in 0...nPointsTheta - 1 {

                    let isSurface: Bool = j == impeller.disk.bottom || j == impeller.disk.top || idxR == nPointsR

                    let t_polar = theta0 + Radian(idxTheta) * dTheta
                    let g = RotatingGeomPoints(
                        r_polar: Radian(r),
                        t_polar: t_polar,
                        iCartFP: Radian(centerI) + r * cos(t_polar),
                        jCartFP: Radian(j) + 0.5,
                        kCartFP: Radian(centerK) + r * sin(t_polar),
                        uDelta: -angle * Radian(r) * sin(t_polar),
                        vDelta: 0,
                        wDelta: angle * Radian(r) * cos(t_polar))
                    //                    g.resolution = resolution * resolution

                    //                    THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
                    //                            //The Impeller Disc Solid elements are Fixed and referenced with node
                    if isSurface {

                        geomRotating.append(g)
                    }

                }
            }
        }

    }

    mutating func createImpellerHubLegacy(withIncrement angle: Radian) {

        let impeller = turbine.impeller["0"]!

//        let hubRadius: Radian = Radian(turbine.impeller["0"]!.hub.radius)
        let hubRadius: Radian = Radian(impeller.hub.radius)

        let nPointsR: Int = Int((hubRadius - Radian(turbine.shaft.radius)) / Radian(turbine.resolution))
        let resolutionR: Radian = (hubRadius - Radian(turbine.shaft.radius)) / Radian(nPointsR)

        for j in impeller.hub.top...impeller.hub.bottom {

//            var isWithinDisk:Bool = j >= turbine.impeller[0]!.disk.bottom && j <= turbine.impeller[0]!.disk.top

            for idxR in 1...nPointsR {

                let r: Radian = Radian(turbine.shaft.radius) + Radian(idxR) * resolutionR
                var nPointsTheta: Int = Int(2 * .pi * r / Radian(turbine.resolution))
                var dTheta: Radian

                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2 * .pi / Radian(nPointsTheta)
                }

                //TODO Change to zero. Check this
//                var theta0: Radian = Radian(turbine.impeller["0"]!.firstBladeOffset)
                var theta0: Radian = Radian(impeller.firstBladeOffset)

                
                if (idxR & 1) == 0 {theta0 += 0.5 * dTheta}
                if (j & 1) == 0 {theta0 += 0.5 * dTheta}

                for idxTheta in 0..<nPointsTheta {

//                    let isSurface:Bool = (j == turbine.impeller[0]!.hub.bottom || j == turbine.impeller[0]!.hub.top || idxR == nPointsR) && !isWithinDisk

                    let t_polar = theta0 + Radian(idxTheta) * dTheta
                    let g = RotatingGeomPoints(
                        r_polar: Radian(r),
                        t_polar: t_polar,
                        iCartFP: Radian(centerI) + r * cos(t_polar),
                        jCartFP: Radian(j) + 0.5,
                        kCartFP: Radian(centerK) + r * sin(t_polar),
                        uDelta: -angle * Radian(r) * sin(t_polar),
                        vDelta: 0,
                        wDelta: angle * Radian(r) * cos(t_polar))
                    //                    g.resolution = resolution * resolution

                    //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
                    //The Impeller Disc Solid elements are Fixed and referenced with node

                    //                    if isSurface {
                    geomRotating.append(g)
                    //                }
                }
            }
        }
    }

    mutating func createImpellerShaftLegacy(withIncrement angle: Radian) {

        for j in 0..<turbine.tankHeight {

//            let isWithinHub:Bool = j > turbine.impeller[0]!.hub.bottom && j < turbine.impeller[0]!.hub.top

            let rEnd: Radian = Radian(turbine.shaft.radius) // isWithinHub ? turbine.hub.radius : turbine.shaft.radius
            let nPointsR: Int = Int(rEnd / Radian(turbine.resolution))

            for idxR in 0...nPointsR {

                var r: Radian = 0
                var dTheta: Radian = 0
                var nPointsTheta: Int = 0

                if idxR == 0 {
                    r = 0
                    nPointsTheta = 1
                    dTheta = 0
                } else {
                    r = Radian(idxR) * Radian(turbine.resolution)
                    nPointsTheta = 4 * Int((.pi * 2.0 * r / (4.0 * Radian(turbine.resolution))))

                    if nPointsTheta == 0 {nPointsTheta = 1}

                    dTheta = 2 * .pi / Radian(nPointsTheta)
                }

                for idxTheta in 0..<nPointsTheta {

                    var theta: Radian = Radian(idxTheta) * dTheta

                    if (j & 1) == 0 {theta += 0.5 * dTheta}

//                    let isSurface:Bool = idxR == nPointsR && !isWithinHub

                    let g = RotatingGeomPoints(
                        r_polar: Radian(r),
                        t_polar: Radian(theta),
                        iCartFP: Radian(centerI) + r * cos(theta),
                        jCartFP: Radian(j) + 0.5,
                        kCartFP: Radian(centerK) + r * sin(theta),
                        uDelta: -angle * Radian(r) * sin(theta),
                        vDelta: 0,
                        wDelta: angle * Radian(r) * cos(theta))
                    //                    g.resolution = resolution

                    //                                //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
                    //                                //The Impeller Disc Solid elements are Fixed and referenced with node
                    //
                    //                    if isSurface {
                    geomRotating.append(g)
                    //                    }

                }
            }
        }

    }

}//end of extension

extension RushtonTurbineLegacy {

    public mutating func incrementGeom(byAngle angle: Radian, forStep step: Int) {

        let impellerIncrementThisStep: Radian = calcImpellerIncrement(atStep: step)

        impellerCurrentAngle += angle

        for g in 0..<geomRotating.count {

            geomRotating[g].t_polar += impellerCurrentAngle

            geomRotating[g].iCartFP = Radian(centerI) + geomRotating[g].r_polar * cos(geomRotating[g].t_polar)
            geomRotating[g].jCartFP = 0.0
            geomRotating[g].kCartFP = Radian(centerK) + geomRotating[g].r_polar * sin(geomRotating[g].t_polar)

            geomRotating[g].uDelta = -impellerIncrementThisStep * geomRotating[g].r_polar * sin(geomRotating[g].t_polar)
            geomRotating[g].vDelta = 0.0
            geomRotating[g].wDelta =  impellerIncrementThisStep * geomRotating[g].r_polar * cos(geomRotating[g].t_polar)

        }

    }

}//end of extension
