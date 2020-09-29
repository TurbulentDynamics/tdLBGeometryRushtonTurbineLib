//
//  MidPointAlgo.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//
//Lifted midpoint code from here
//http://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm#Python

import Foundation
import tdLB
import tdLBGeometry
import tdLBOutputGeometry


public struct RushtonTurbineMidPoint: Geometry {


    public var gridX, gridY, gridZ: Int
    public let startingStep:Int

    let uav: Double
    let impellerStartupStepsUntilNormalSpeed: Int
    let impellerStartAngle: Double

    public let turbine: RushtonTurbine
    public let output: OutputGeometry

    var impellerIncrementFullStep: Radian = 0
    var impellerCurrentAngle: Radian = 0

    public var geomFixed = [RotatingGeomPoints]()
    public var geomRotating = [RotatingGeomPoints]()



    public init(gridX: Int, gridY: Int, gridZ: Int, uav: Double, impellerStartupStepsUntilNormalSpeed s: Int = 0, startingStep: Int = 0, impellerStartAngle: Double = 0.0) {

        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ

        self.uav = uav
        self.startingStep = startingStep
        self.impellerStartupStepsUntilNormalSpeed = s
        self.impellerStartAngle = impellerStartAngle

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

        self.uav = self.turbine.impellers["0"]!.uav
        //self.uav = self.turbine.impeller.uav

        self.startingStep = self.turbine.startingStep
        self.impellerStartupStepsUntilNormalSpeed = self.turbine.impellerStartupStepsUntilNormalSpeed
        self.impellerStartAngle = self.turbine.impellerStartAngle

    }

    mutating public func generateFixedGeometry() {

        getWall(turbine: turbine)
        getBaffles(turbine: turbine)    }

    public mutating func generateRotatingGeometry(atθ: Radian) {

        getImpellers(turbine: turbine, atθ: atθ)

    }

    public mutating func updateGeometry(forStep step: Int) {
        //TODO
        print("Need to implement updateGeom!!!!!")
    }

    mutating func updateMidpointGeometry(turbine: RushtonTurbine, atθ: Radian) {

        //TODO Fix later
//        getImpellers(turbine: turbine, atθ: atθ)

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



}//end of class

extension RushtonTurbineMidPoint {


    // MARK: - Rotating Geometry

    mutating func getImpellers(turbine: RushtonTurbine, atθ: Radian) {

        getBlades(turbine: turbine, atθ: atθ)
        getShaft(turbine: turbine)
        getHub(turbine: turbine)
        getDisc(turbine: turbine)

    }

    mutating func getBlades(turbine: RushtonTurbine, atθ θ: Radian = 0.0) {

        let centerX = turbine.tankDiameter / 2
        let centerZ = centerX

        let impellerNum = 0
        let impeller = turbine.impellers[String(impellerNum)]!
        //let impeller = turbine.impeller
        let blades = impeller.blades

        let deltaImpellerOffset: Radian = (2.0 * Radian.pi) / Radian(impeller.numBlades)

        var reducedθ = θ
        while reducedθ > 2 * Radian.pi {reducedθ -= 2 * Radian.pi}

        for j in blades.top..<blades.bottom {

            for nBlade in 0..<impeller.numBlades {

                let bladeAngle: Radian = reducedθ + Radian(impeller.firstBladeOffset) + deltaImpellerOffset * Radian(nBlade)

                let outerEdge: Line = getPerpendicularEdge(centerX: centerX, centerY: centerZ, angle: bladeAngle, radius: Radian(blades.outerRadius), thickness: blades.thickness)

                for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: outerEdge.x1, y1: outerEdge.y1) {
                    geomRotating.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }

                let innerEdge: Line = getPerpendicularEdge(centerX: centerX, centerY: centerZ, angle: bladeAngle, radius: Radian(blades.innerRadius), thickness: blades.thickness)

                for l in getBresenhamline(x0: innerEdge.x0, y0: innerEdge.y0, x1: innerEdge.x1, y1: innerEdge.y1) {
                    geomRotating.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }

                for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: innerEdge.x0, y1: innerEdge.y0) {
                    geomRotating.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }
                for l in getBresenhamline(x0: innerEdge.x1, y0: innerEdge.y1, x1: outerEdge.x1, y1: outerEdge.y1) {
                    geomRotating.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }
            }
        }

    }

    mutating func getShaft(turbine: RushtonTurbine) {

        let radius = turbine.shaft.radius / 2
        let center = turbine.tankDiameter / 2

        for j in 0..<turbine.tankHeight {
            geomRotating.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center))
        }
    }

    mutating func getDisc(turbine: RushtonTurbine) {

        let disk = turbine.impellers["0"]!.disk
        let radius = disk.radius
        let center = turbine.tankDiameter / 2

        var j = disk.top
        geomRotating.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center))

        for j in disk.top+1..<disk.bottom {
            geomRotating.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center))
        }

        j = disk.bottom
        geomRotating.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center))

    }

    mutating func getHub(turbine: RushtonTurbine) {

        let hub = turbine.impellers["0"]!.hub
        let radius = hub.radius
        let center = turbine.tankDiameter / 2

        var j = hub.top
        geomRotating.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center))

        for j in hub.top+1..<hub.bottom {
            geomRotating.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center))
        }

        j = hub.bottom
        geomRotating.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center))

    }

    // MARK: - Fixed Geometry
    mutating func getWall(turbine: RushtonTurbine) {

        let radius = turbine.tankDiameter / 2
        let center = turbine.tankDiameter / 2

        for j in 0..<turbine.tankHeight {
            geomFixed.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center))
        }
    }

    mutating func getBaffles(turbine: RushtonTurbine) {

        let centerX = turbine.tankDiameter / 2
        let centerZ = centerX
        let tankHeight = turbine.tankDiameter

        let deltaBaffleOffset: Radian = (2.0 * Radian.pi) / Radian(turbine.baffles.numBaffles)

        for j in 0..<tankHeight {

            for nBaffle in 0..<turbine.baffles.numBaffles {

                let baffleAngle: Radian = Radian(turbine.baffles.firstBaffleOffset) + deltaBaffleOffset * Radian(nBaffle)

                let outerEdge: Line = getPerpendicularEdge(centerX: centerX, centerY: centerZ, angle: baffleAngle, radius: Radian(turbine.baffles.outerRadius), thickness: turbine.baffles.thickness)

                for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: outerEdge.x1, y1: outerEdge.y1) {
                    geomFixed.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }

                let innerEdge: Line = getPerpendicularEdge(centerX: centerX, centerY: centerZ, angle: baffleAngle, radius: Radian(turbine.baffles.innerRadius), thickness: turbine.baffles.thickness)

                for l in getBresenhamline(x0: innerEdge.x0, y0: innerEdge.y0, x1: innerEdge.x1, y1: innerEdge.y1) {
                    geomFixed.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }

                for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: innerEdge.x0, y1: innerEdge.y0) {
                    geomFixed.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }
                for l in getBresenhamline(x0: innerEdge.x1, y0: innerEdge.y1, x1: outerEdge.x1, y1: outerEdge.y1) {
                    geomFixed.append(RotatingGeomPoints(iCart: l.0, jCart: j, kCart: l.1))
                }

            }

        }
    }

    // MARK: - primitives

    struct Line {
        var x0, y0, x1, y1: Int
        init(x0: Int, y0: Int, x1: Int, y1: Int) {
            self.x0 = x0
            self.y0 = y0
            self.x1 = x1
            self.y1 = y1
        }
        init(x0: Radian, y0: Radian, x1: Radian, y1: Radian) {
            self.init(x0: Int(x0), y0: Int(y0), x1: Int(x1), y1: Int(y1))
        }
    }

    func getPerpendicularEdge(centerX: Int, centerY: Int, angle: Radian, radius: Radian, thickness: Int) -> Line {

        let midPointEdgeX = Radian(centerX) + radius * cos(angle)
        let midPointEdgeY = Radian(centerY) + radius * sin(angle)

        let edgeAngle: Radian = angle + 0.5 * Radian.pi

        var x0 = midPointEdgeX - Radian(thickness) * cos(edgeAngle)
        var y0 = midPointEdgeY - Radian(thickness) * sin(edgeAngle)

        var x1 = midPointEdgeX + Radian(thickness) * cos(edgeAngle)
        var y1 = midPointEdgeY + Radian(thickness) * sin(edgeAngle)

        x0.round()
        y0.round()
        x1.round()
        y1.round()

        return Line(x0: x0, y0: y0, x1: x1, y1: y1)
    }

    func drawHollowDiscIK(atj: Int, innerRadius: Int, outerRadius: Int, iCenter: Int, kCenter: Int) -> [RotatingGeomPoints] {

        let outerPts = drawMidPointCircle(radius: outerRadius, xCenter: iCenter, yCenter: kCenter)
        let innerPts = drawMidPointCircle(radius: innerRadius, xCenter: iCenter, yCenter: kCenter)

        let innerI = innerPts.keys

        var points = [RotatingGeomPoints]()

        for (i, kList) in outerPts {
            let outerLeft = kList.min()!
            let outerRight = kList.max()!

            if innerI.contains(i) {
                let innerLeft = innerPts[i]!.min()!
                let innerRight = innerPts[i]!.max()!

                for k in outerLeft..<innerLeft {
                    points.append(RotatingGeomPoints(iCart: i, jCart: atj, kCart: k))
                }
                for k in innerRight + 1 ... outerRight {
                    points.append(RotatingGeomPoints(iCart: i, jCart: atj, kCart: k))
                }
                //Now do the points ON the inner Circle
                for k in innerPts[i]! {
                    points.append(RotatingGeomPoints(iCart: i, jCart: atj, kCart: k))
                }
            } else {
                for k in outerLeft...outerRight {
                    points.append(RotatingGeomPoints(iCart: i, jCart: atj, kCart: k))
                }

            }

        }
        return points
    }

    func drawDiscIK(atj: Int, radius: Int, iCenter: Int, kCenter: Int) -> [RotatingGeomPoints] {

        let pts = drawMidPointCircle(radius: radius, xCenter: iCenter, yCenter: kCenter)

        var points = [RotatingGeomPoints]()

        for (i, kList) in pts {
            let min = kList.min()!
            let max = kList.max()!

            for k in min...max {
                points.append(RotatingGeomPoints(iCart: i, jCart: atj, kCart: k))
            }

        }
        return points
    }

    func drawCircleIK(atj: Int, radius: Int, iCenter: Int, kCenter: Int) -> [RotatingGeomPoints] {

        let pts = drawMidPointCircle(radius: radius, xCenter: iCenter, yCenter: kCenter)

        var points = [RotatingGeomPoints]()

        for (i, kList) in pts {
            for k in kList {
                points.append(RotatingGeomPoints(iCart: i, jCart: atj, kCart: k))
            }
        }

        return points
    }

    //http://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm#Python
    func drawMidPointCircle(radius: Int, xCenter: Int, yCenter: Int) -> [Int: [Int]] {

        //TODO add throws
        if radius > xCenter {print("ERROR")}
        if radius > yCenter {print("ERROR")}

        let x0: Int = Int(xCenter)
        let y0: Int = Int(yCenter)

        var f: Int = 1 - Int(radius)
        var ddF_x: Int = 0
        var ddF_y: Int = -2 * Int(radius)
        var x: Int = 0
        var y: Int = Int(radius)

        var pts: [Int: [Int]] = [:]

        pts[x0] = [y0 + radius, y0 - radius]
        pts[x0 + radius] = [y0]
        pts[x0 - radius] = [y0]

        while x < y {

            if f >= 0 {
                y -= 1
                ddF_y += 2
                f += ddF_y
            }

            x += 1
            ddF_x += 2
            f += ddF_x + 1

            pts[x0 + Int(x), default: [Int]()].append(y0 + Int(y))
            pts[x0 - Int(x), default: [Int]()].append(y0 + Int(y))
            pts[x0 + Int(x), default: [Int]()].append(y0 - Int(y))
            pts[x0 - Int(x), default: [Int]()].append(y0 - Int(y))

            pts[x0 + Int(y), default: [Int]()].append(y0 + Int(x))
            pts[x0 - Int(y), default: [Int]()].append(y0 + Int(x))
            pts[x0 + Int(y), default: [Int]()].append(y0 - Int(x))
            pts[x0 - Int(y), default: [Int]()].append(y0 - Int(x))

        }

        return pts
    }

    //http://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#Python
    func getBresenhamline(x0: Int, y0: Int, x1: Int, y1: Int) -> [(Int, Int)] {

        //    var pts: [Int: [Int]] = [:]
        var pts: [(Int, Int)] = []

        let dx: Int = abs(x1 - x0)
        let dy: Int = abs(y1 - y0)
        var x: Int = x0
        var y: Int = y0

        //    var sx = -1 if x0 > x1 else 1
        //    var sy = -1 if y0 > y1 else 1

        let sx = (x0 > x1 ? -1 : 1)
        let sy = (y0 > y1 ? -1 : 1)

        if dx > dy {
            var err = Float(dx) / 2.0

            while x != x1 {
                pts.append((x, y))
                err -= Float(dy)
                if err < 0 {
                    y += sy
                    err += Float(dx)
                }
                x += sx
            }
        } else {
            var err = Float(dy) / 2.0
            while y != y1 {
                pts.append((x, y))
                err -= Float(dx)
                if err < 0 {
                    x += sx
                    err += Float(dy)
                }
                y += sy

            }
        }
        pts.append((x, y))

        return pts
    }

}//end of extension
