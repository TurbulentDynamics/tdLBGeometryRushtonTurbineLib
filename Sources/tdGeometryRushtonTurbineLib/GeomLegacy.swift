//
//  GeometryLegacy.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//

import Foundation
import tdLBApi

public struct GeometryLegacy: Geometry {



    var gridX, gridY, gridZ: Int

    let uav: Double
    let startingStep, impellerStartupStepsUntilNormalSpeed: Int
    let impellerStartAngle: Double

    public let turbine: RushtonTurbine
    public let output: qVecOutputData

    var impellerIncrementFullStep: Radian = 0
    public var impellerCurrentAngle: Radian = 0

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
        (self.turbine, self.output) = useEggelsSomersRatios(gridX: gridX, uav: uav, impellerStartupStepsUntilNormalSpeed: s, startingStep: startingStep, impellerStartAngle: impellerStartAngle)

        generateFixedGeometry(turbine: self.turbine)
        generateRotatingGeometry(turbine: self.turbine, atθ: Radian(impellerStartAngle))

    }

    public init(fileName: String, outputJson: String) throws {

        self.turbine = try RushtonTurbine(json: fileName)
        self.output = try qVecOutputData(json: outputJson)

        self.gridX = self.turbine.gridx
        self.gridY = self.turbine.gridx
        self.gridZ = self.turbine.gridx

        self.uav = self.turbine.impeller[0]!.uav
        self.startingStep = self.turbine.startingStep
        self.impellerStartupStepsUntilNormalSpeed = self.turbine.impellerStartupStepsUntilNormalSpeed
        self.impellerStartAngle = self.turbine.impellerStartAngle

    }

    public mutating func updateGeom(forStep step: Int) {

        let impellerIncrementThisStep: tGeomCalc = calcImpellerIncrement(atStep: step)

        impellerCurrentAngle += impellerIncrementThisStep

        for g in 0..<geomRotating.count {

            geomRotating[g].t_polar += impellerIncrementThisStep

            geomRotating[g].i_cart_fp = tGeomCalc(centerI) + geomRotating[g].r_polar * cos(geomRotating[g].t_polar)
            geomRotating[g].j_cart_fp = 0
            geomRotating[g].k_cart_fp = tGeomCalc(centerK) + geomRotating[g].r_polar * sin(geomRotating[g].t_polar)

            geomRotating[g].u_delta = -impellerIncrementThisStep * geomRotating[g].r_polar * sin(geomRotating[g].t_polar)
            geomRotating[g].v_delta = 0
            geomRotating[g].w_delta =  impellerIncrementThisStep * geomRotating[g].r_polar * cos(geomRotating[g].t_polar)

        }
    }

    public func getFixedPointCloud() -> [PointCloudElement] {
        var pts = [PointCloudElement]()
        for g in 0..<geomFixed.count {

            pts.append(PointCloudElement(i: geomFixed[g].i_cart, j: geomFixed[g].j_cart, k: geomFixed[g].k_cart, kind: .fixed))
        }
        return pts
    }

    public func getRotatingPointCloud() -> [PointCloudElement] {
        var pts = [PointCloudElement]()

        for g in 0..<geomRotating.count {
            pts.append(PointCloudElement(i: geomRotating[g].i_cart, j: geomRotating[g].j_cart, k: geomRotating[g].k_cart, kind: .rotating))

        }
        return pts
    }

}//end of struct

extension GeometryLegacy {


    mutating func generateFixedGeometry(turbine: RushtonTurbine) {

        generateTankWallLegacy()
        generateBafflesLegacy()

    }

    mutating func generateRotatingGeometry(turbine: RushtonTurbine, atθ: Radian) {

        let increment = calcImpellerIncrement(atStep: 0)
        createImpellerHubLegacy(withIncrement: increment)
        createImpellerDiskLegacy(withIncrement: increment)
        createImpellerShaftLegacy(withIncrement: increment)
        createImpellerBladesLegacy(withIncrement: increment)
    }

    func calcImpellerIncrement(atStep step: Int) -> tGeomCalc {

        if step >= turbine.impellerStartupStepsUntilNormalSpeed {
            return impellerIncrementFullStep
        }

        return 0.5 * tGeomCalc(turbine.impeller[0]!.bladeTipAngularVelW0) * (1.0 - cos(tGeomCalc.pi * tGeomCalc(step) / tGeomCalc(turbine.impellerStartupStepsUntilNormalSpeed)))
    }

    mutating func generateTankWallLegacy() {

        let tankHeight = turbine.tankDiameter
        let resolution = tGeomCalc(turbine.resolution)

        let nCircPoints: Int = 4 * Int((tGeomCalc.pi * tGeomCalc(turbine.tankDiameter) / (4.0 * resolution)))
        let dTheta: tGeomCalc = 2 * tGeomCalc.pi / tGeomCalc(nCircPoints)
        let r: tGeomCalc = 0.5 * tGeomCalc(turbine.tankDiameter)

        for j in 0..<tankHeight {
            for k in 0..<nCircPoints {

                var theta: tGeomCalc = tGeomCalc(k) * dTheta
                if (j & 1) == 1 {theta += 0.5 * dTheta}

                let g = RotatingGeomPoints(
                    i_cart_fp: tGeomCalc(centerI) + r * cos(theta),
                    j_cart_fp: tGeomCalc(j) + 0.5,
                    k_cart_fp: tGeomCalc(centerK) + r * sin(theta))
                //                    g.resolution = resolution

                geomFixed.append(g)

            }
        }
    }

    mutating func generateBafflesLegacy() {

        let tankHeight = turbine.tankDiameter

        let resolution = tGeomCalc(turbine.resolution)

        var nPointsBaffleThickness = Int(tGeomCalc(turbine.baffles.thickness) / resolution)
        if nPointsBaffleThickness == 0 {nPointsBaffleThickness = 1}

        let resolutionBaffleThickness: tGeomCalc = tGeomCalc(turbine.baffles.thickness) / tGeomCalc(nPointsBaffleThickness)

        let nPointsR: Int = Int(tGeomCalc(turbine.baffles.outerRadius - turbine.baffles.innerRadius) / resolution)

        let deltaR: tGeomCalc = tGeomCalc((turbine.baffles.outerRadius - turbine.baffles.innerRadius)) / tGeomCalc(nPointsR)

        let deltaBaffleOffset: tGeomCalc = 2.0/tGeomCalc(turbine.baffles.numBaffles) * tGeomCalc.pi

        for nBaffle in 0..<turbine.baffles.numBaffles {

            for j in 0..<tankHeight {
                for idxR in 0...nPointsR {
                    let r: tGeomCalc = tGeomCalc(turbine.baffles.innerRadius) + deltaR * tGeomCalc(idxR)
                    for idxTheta in 0...nPointsBaffleThickness {

                        let theta0: tGeomCalc = tGeomCalc(turbine.baffles.firstBaffleOffset) + deltaBaffleOffset * tGeomCalc(nBaffle)

                        let theta = theta0 + (tGeomCalc(idxTheta - nPointsBaffleThickness) / 2.0) * resolutionBaffleThickness / r

//                        let isSurface: Bool = idxTheta == 0 || idxTheta == nPointsBaffleThickness || idxR == 0 || idxR == nPointsR

                        let g = RotatingGeomPoints(
                            i_cart_fp: tGeomCalc(centerI) + r * cos(theta),
                            j_cart_fp: tGeomCalc(j) + 0.5,
                            k_cart_fp: tGeomCalc(centerK) + r * sin(theta))
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

    mutating func createImpellerBladesLegacy(withIncrement angle: tGeomCalc) {

        let impellerNum = 0
        let impeller = turbine.impeller[impellerNum]!

        let innerRadius = tGeomCalc(impeller.blades.innerRadius)
        let outerRadius = tGeomCalc(impeller.blades.outerRadius)

        let resolution = tGeomCalc(turbine.resolution)

        let nPointsR = Int(tGeomCalc(outerRadius - innerRadius) / resolution)
        var nPointsThickness = Int(tGeomCalc(impeller.blades.thickness) / resolution)
        if nPointsThickness == 0 {nPointsThickness = 1}

        let resolutionBladeThickness: tGeomCalc = tGeomCalc(impeller.blades.thickness) / tGeomCalc(nPointsThickness)

        let deltaR = (outerRadius - innerRadius) / tGeomCalc(nPointsR)

        let deltaTheta: tGeomCalc = 2.0 / tGeomCalc(impeller.numBlades) * tGeomCalc.pi

        for nBlade in 1...impeller.numBlades {
            for j in impeller.blades.top...impeller.blades.bottom {
                for idxR in 0...nPointsR {

                    let r: tGeomCalc = innerRadius + deltaR * tGeomCalc(idxR)

                    for idxThickness in 0...nPointsThickness {

                        let offset: tGeomCalc = deltaTheta * tGeomCalc(nBlade) + tGeomCalc(impeller.firstBladeOffset)

                        let theta = offset + (tGeomCalc(idxThickness - nPointsThickness) / 2.0) * resolutionBladeThickness / r

                        let insideDisk: Bool = (Int(r) <= impeller.disk.radius) && (j >= impeller.disk.bottom) && (j <= impeller.disk.top)
                        if insideDisk {continue}

//                        let isSurface:Bool = idxThickness == 0 || idxThickness == nPointsThickness || idxR == 0 || idxR == nPointsR || j == impeller.blades.bottom || j == impeller.blades.top

                        let g = RotatingGeomPoints(
                            r_polar: tGeomCalc(r),
                            t_polar: theta,

                            i_cart_fp: tGeomCalc(centerI) + r * cos(theta),
                            j_cart_fp: tGeomCalc(j) + 0.5,
                            k_cart_fp: tGeomCalc(centerK) + r * sin(theta),

                            u_delta: -angle * tGeomCalc(r) * sin(theta),
                            v_delta: 0,
                            w_delta: angle * tGeomCalc(r) * cos(theta))
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

    mutating func createImpellerDiskLegacy(withIncrement angle: tGeomCalc) {

        let impellerNum = 0
        let impeller = turbine.impeller[impellerNum]!

        let hubRadius = tGeomCalc(impeller.hub.radius)
        let diskRadius = tGeomCalc(impeller.disk.radius)

        let nPointsR: Int = Int(round((diskRadius - hubRadius) / tGeomCalc(turbine.resolution)))
        let deltaR: tGeomCalc = (diskRadius - hubRadius) / tGeomCalc(nPointsR)

        let resolution = tGeomCalc(turbine.resolution)

        for j in impeller.disk.top...impeller.disk.bottom {

            for idxR in 1...nPointsR {

                let r: tGeomCalc = tGeomCalc(hubRadius) + tGeomCalc(idxR) * deltaR
                var dTheta: tGeomCalc = 0
                var nPointsTheta: Int = Int(2 * tGeomCalc.pi * r / resolution)

                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2.0 * tGeomCalc.pi / tGeomCalc(nPointsTheta)
                }

                var theta0: tGeomCalc = tGeomCalc(impeller.firstBladeOffset)
                if (idxR & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }
                if (j & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }

                for idxTheta in 0...nPointsTheta - 1 {

                    let isSurface: Bool = j == impeller.disk.bottom || j == impeller.disk.top || idxR == nPointsR

                    let t_polar = theta0 + tGeomCalc(idxTheta) * dTheta
                    let g = RotatingGeomPoints(
                        r_polar: tGeomCalc(r),
                        t_polar: t_polar,
                        i_cart_fp: tGeomCalc(centerI) + r * cos(t_polar),
                        j_cart_fp: tGeomCalc(j) + 0.5,
                        k_cart_fp: tGeomCalc(centerK) + r * sin(t_polar),
                        u_delta: -angle * tGeomCalc(r) * sin(t_polar),
                        v_delta: 0,
                        w_delta: angle * tGeomCalc(r) * cos(t_polar))
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

    mutating func createImpellerHubLegacy(withIncrement angle: tGeomCalc) {

        let impellerNum = 0
        let impeller = turbine.impeller[impellerNum]!

        let hubRadius: tGeomCalc = tGeomCalc(turbine.impeller[0]!.hub.radius)

        let nPointsR: Int = Int((hubRadius - tGeomCalc(turbine.shaft.radius)) / tGeomCalc(turbine.resolution))
        let resolutionR: tGeomCalc = (hubRadius - tGeomCalc(turbine.shaft.radius)) / tGeomCalc(nPointsR)

        for j in impeller.hub.top...impeller.hub.bottom {

//            var isWithinDisk:Bool = j >= turbine.impeller[0]!.disk.bottom && j <= turbine.impeller[0]!.disk.top

            for idxR in 1...nPointsR {

                let r: tGeomCalc = tGeomCalc(turbine.shaft.radius) + tGeomCalc(idxR) * resolutionR
                var nPointsTheta: Int = Int(2 * .pi * r / tGeomCalc(turbine.resolution))
                var dTheta: tGeomCalc

                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2 * .pi / tGeomCalc(nPointsTheta)
                }

                //TODO Change to zero. Check this
                var theta0: tGeomCalc = tGeomCalc(turbine.impeller[0]!.firstBladeOffset)

                if (idxR & 1) == 0 {theta0 += 0.5 * dTheta}
                if (j & 1) == 0 {theta0 += 0.5 * dTheta}

                for idxTheta in 0..<nPointsTheta {

//                    let isSurface:Bool = (j == turbine.impeller[0]!.hub.bottom || j == turbine.impeller[0]!.hub.top || idxR == nPointsR) && !isWithinDisk

                    let t_polar = theta0 + tGeomCalc(idxTheta) * dTheta
                    let g = RotatingGeomPoints(
                        r_polar: tGeomCalc(r),
                        t_polar: t_polar,
                        i_cart_fp: tGeomCalc(centerI) + r * cos(t_polar),
                        j_cart_fp: tGeomCalc(j) + 0.5,
                        k_cart_fp: tGeomCalc(centerK) + r * sin(t_polar),
                        u_delta: -angle * tGeomCalc(r) * sin(t_polar),
                        v_delta: 0,
                        w_delta: angle * tGeomCalc(r) * cos(t_polar))
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

    mutating func createImpellerShaftLegacy(withIncrement angle: tGeomCalc) {

        for j in 0..<turbine.tankHeight {

//            let isWithinHub:Bool = j > turbine.impeller[0]!.hub.bottom && j < turbine.impeller[0]!.hub.top

            let rEnd: tGeomCalc = tGeomCalc(turbine.shaft.radius) // isWithinHub ? turbine.hub.radius : turbine.shaft.radius
            let nPointsR: Int = Int(rEnd / tGeomCalc(turbine.resolution))

            for idxR in 0...nPointsR {

                var r: tGeomCalc = 0
                var dTheta: tGeomCalc = 0
                var nPointsTheta: Int = 0

                if idxR == 0 {
                    r = 0
                    nPointsTheta = 1
                    dTheta = 0
                } else {
                    r = tGeomCalc(idxR) * tGeomCalc(turbine.resolution)
                    nPointsTheta = 4 * Int((.pi * 2.0 * r / (4.0 * tGeomCalc(turbine.resolution))))

                    if nPointsTheta == 0 {nPointsTheta = 1}

                    dTheta = 2 * .pi / tGeomCalc(nPointsTheta)
                }

                for idxTheta in 0..<nPointsTheta {

                    var theta: tGeomCalc = tGeomCalc(idxTheta) * dTheta

                    if (j & 1) == 0 {theta += 0.5 * dTheta}

//                    let isSurface:Bool = idxR == nPointsR && !isWithinHub

                    let g = RotatingGeomPoints(
                        r_polar: tGeomCalc(r),
                        t_polar: tGeomCalc(theta),
                        i_cart_fp: tGeomCalc(centerI) + r * cos(theta),
                        j_cart_fp: tGeomCalc(j) + 0.5,
                        k_cart_fp: tGeomCalc(centerK) + r * sin(theta),
                        u_delta: -angle * tGeomCalc(r) * sin(theta),
                        v_delta: 0,
                        w_delta: angle * tGeomCalc(r) * cos(theta))
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

extension GeometryLegacy {

    public mutating func incrementGeom(byAngle angle: Radian, forStep step: Int) {

        let impellerIncrementThisStep: tGeomCalc = calcImpellerIncrement(atStep: step)

        impellerCurrentAngle += angle

        for g in 0..<geomRotating.count {

            geomRotating[g].t_polar += impellerCurrentAngle

            geomRotating[g].i_cart_fp = tGeomCalc(centerI) + geomRotating[g].r_polar * cos(geomRotating[g].t_polar)
            geomRotating[g].j_cart_fp = 0.0
            geomRotating[g].k_cart_fp = tGeomCalc(centerK) + geomRotating[g].r_polar * sin(geomRotating[g].t_polar)

            geomRotating[g].u_delta = -impellerIncrementThisStep * geomRotating[g].r_polar * sin(geomRotating[g].t_polar)
            geomRotating[g].v_delta = 0.0
            geomRotating[g].w_delta =  impellerIncrementThisStep * geomRotating[g].r_polar * cos(geomRotating[g].t_polar)

        }

    }

}//end of extension
