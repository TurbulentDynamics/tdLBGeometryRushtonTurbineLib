//
//  MidPointAlgo.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//
//Lifted midpoint code from here
//http://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm#Python

import Foundation


typealias Radian = Double
typealias Degree = Int


func getMidPointGeometry(turbine: RushtonTurbine) -> [GeomPoints]{

    var pts = [GeomPoints]()

    pts.append(contentsOf: getWall(turbine: turbine))
    pts.append(contentsOf: getBaffles(turbine: turbine))

    pts.append(contentsOf: getImpellers(turbine: turbine))

    return pts
}





// MARK: - Moving Geometry

func getImpellers(turbine: RushtonTurbine)-> [GeomPoints] {

    var pts = [GeomPoints]()

    pts.append(contentsOf: getShaft(turbine: turbine))
    pts.append(contentsOf: getHub(turbine: turbine))
    pts.append(contentsOf: getDisc(turbine: turbine))
    pts.append(contentsOf: getBlades(turbine: turbine))

    return pts
}





func getBlades(turbine: RushtonTurbine)-> [GeomPoints] {

    var pts = [GeomPoints]()

    let centerX = turbine.tankDiameter / 2
    let centerZ = centerX

    let impellerNum = 0
    let impeller = turbine.impeller[impellerNum]!
    let blades = impeller.blades

    let deltaImpellerOffset: Radian = (2.0 * Radian.pi) / Double(impeller.numBlades)


    for j in blades.top..<blades.bottom {

        for nBlade in 0..<impeller.numBlades {

            let bladeAngle: Radian = Radian(impeller.firstBladeOffset) + deltaImpellerOffset * Double(nBlade)

            let outerEdge: Line = getPerpendicularEdge(centerX:centerX, centerY:centerZ, angle: bladeAngle, radius: Double(blades.outerRadius), thickness: blades.thickness)

            for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: outerEdge.x1, y1: outerEdge.y1) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .MovingBoundary))
            }



            let innerEdge: Line = getPerpendicularEdge(centerX:centerX, centerY:centerZ, angle: bladeAngle, radius: Double(blades.innerRadius), thickness: blades.thickness)

            for l in getBresenhamline(x0: innerEdge.x0, y0: innerEdge.y0, x1: innerEdge.x1, y1: innerEdge.y1) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .MovingBoundary))
            }



            for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: innerEdge.x0, y1: innerEdge.y0) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .MovingBoundary))
            }
            for l in getBresenhamline(x0: innerEdge.x1, y0: innerEdge.y1, x1: outerEdge.x1, y1: outerEdge.y1) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .MovingBoundary))
            }

        }

    }
    return pts
}





func getShaft(turbine: RushtonTurbine)-> [GeomPoints] {

    var pts = [GeomPoints]()
    let radius = turbine.shaft.radius / 2
    let center = turbine.tankDiameter / 2


    for j in 0..<turbine.tankHeight{
        pts.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center, kind: .MovingBoundary))
    }
    return pts
}


func getDisc(turbine: RushtonTurbine) -> [GeomPoints] {

    var pts = [GeomPoints]()
    let disk = turbine.impeller[0]!.disk
    let radius = disk.radius
    let center = turbine.tankDiameter / 2

    var j = disk.top
    pts.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center, kind: .MovingBoundary))

    for j in disk.top+1..<disk.bottom {
        pts.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center, kind: .FixedBoundary))

    }

    j = disk.bottom
    pts.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center, kind: .MovingBoundary))

    return pts
}



func getHub(turbine: RushtonTurbine) -> [GeomPoints] {

    var pts = [GeomPoints]()
    let hub = turbine.impeller[0]!.hub
    let radius = hub.radius
    let center = turbine.tankDiameter / 2

    var j = hub.top
    pts.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center, kind: .MovingBoundary))

    for j in hub.top+1..<hub.bottom {
        pts.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center, kind: .FixedBoundary))
    }

    j = hub.bottom
    pts.append(contentsOf: drawHollowDiscIK(atj: j, innerRadius: turbine.shaft.radius, outerRadius: radius, iCenter: center, kCenter: center, kind: .MovingBoundary))


    return pts
}






// MARK: - Fixed Geometry
func getWall(turbine: RushtonTurbine)-> [GeomPoints] {

    var pts = [GeomPoints]()
    let radius = turbine.tankDiameter / 2
    let center = turbine.tankDiameter / 2


    for j in 0..<turbine.tankHeight{
        pts.append(contentsOf: drawCircleIK(atj: j, radius: radius, iCenter: center, kCenter: center, kind: .FixedBoundary))
    }
    return pts
}




func getBaffles(turbine: RushtonTurbine)-> [GeomPoints] {

    var pts = [GeomPoints]()

    let centerX = turbine.tankDiameter / 2
    let centerZ = centerX
    let tankHeight = turbine.tankDiameter



    let deltaBaffleOffset: Radian = (2.0 * Radian.pi) / Double(turbine.baffles.numBaffles)


    for j in 0..<tankHeight {

        for nBaffle in 0..<turbine.baffles.numBaffles {

            let baffleAngle: Radian = turbine.baffles.firstBaffleOffset + deltaBaffleOffset * Double(nBaffle)

            let outerEdge: Line = getPerpendicularEdge(centerX:centerX, centerY:centerZ, angle: baffleAngle, radius: Double(turbine.baffles.outerRadius), thickness: turbine.baffles.thickness)

            for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: outerEdge.x1, y1: outerEdge.y1) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .FixedBoundary))
            }



            let innerEdge: Line = getPerpendicularEdge(centerX:centerX, centerY:centerZ, angle: baffleAngle, radius: Double(turbine.baffles.innerRadius), thickness: turbine.baffles.thickness)

            for l in getBresenhamline(x0: innerEdge.x0, y0: innerEdge.y0, x1: innerEdge.x1, y1: innerEdge.y1) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .FixedBoundary))
            }



            for l in getBresenhamline(x0: outerEdge.x0, y0: outerEdge.y0, x1: innerEdge.x0, y1: innerEdge.y0) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .FixedBoundary))
            }
            for l in getBresenhamline(x0: innerEdge.x1, y0: innerEdge.y1, x1: outerEdge.x1, y1: outerEdge.y1) {
                pts.append(GeomPoints(i: l.0, j: j, k: l.1, kind: .FixedBoundary))
            }

        }

    }
    return pts
}











// MARK: - primitives

struct Line {
    var x0, y0, x1, y1: Int
    init(x0:Int, y0:Int, x1:Int, y1:Int){
        self.x0 = x0
        self.y0 = y0
        self.x1 = x1
        self.y1 = y1
    }
    init(x0:Double, y0:Double, x1:Double, y1:Double){
        self.init(x0:Int(x0), y0:Int(y0), x1:Int(x1), y1:Int(y1))
    }
}


func getPerpendicularEdge(centerX:Int, centerY:Int, angle: Radian, radius: Double, thickness: Int) -> Line {

    let midPointEdgeX = Double(centerX) + radius * cos(angle)
    let midPointEdgeY = Double(centerY) + radius * sin(angle)


    let edgeAngle: Radian = angle + 0.5 * Radian.pi

    var x0 = midPointEdgeX - Double(thickness) * cos(edgeAngle)
    var y0 = midPointEdgeY - Double(thickness) * sin(edgeAngle)

    var x1 = midPointEdgeX + Double(thickness) * cos(edgeAngle)
    var y1 = midPointEdgeY + Double(thickness) * sin(edgeAngle)

    x0.round()
    y0.round()
    x1.round()
    y1.round()


    return Line(x0:x0, y0:y0, x1:x1, y1:y1)
}


func drawHollowDiscIK(atj: Int, innerRadius: Int, outerRadius: Int, iCenter: Int, kCenter: Int, kind: GeomPointType) -> [GeomPoints] {

    let outerPts = drawMidPointCircle(radius: outerRadius, xCenter: iCenter, yCenter: kCenter)
    let innerPts = drawMidPointCircle(radius: innerRadius, xCenter: iCenter, yCenter: kCenter)

    let innerI = innerPts.keys

    var points = [GeomPoints]()

    for (i, kList) in outerPts {
        let outerLeft = kList.min()!
        let outerRight = kList.max()!

        if innerI.contains(i) {
            let innerLeft = innerPts[i]!.min()!
            let innerRight = innerPts[i]!.max()!

            for k in outerLeft..<innerLeft {
                points.append(GeomPoints(i, atj, k, kind))
            }
            for k in innerRight + 1 ... outerRight {
                points.append(GeomPoints(i, atj, k, kind))
            }
            //Now do the points ON the inner Circle
            for k in innerPts[i]! {
                points.append(GeomPoints(i, atj, k, kind))
            }
        } else {
            for k in outerLeft...outerRight {
                points.append(GeomPoints(i, atj, k, kind))
            }

        }

    }
    return points
}











func drawDiscIK(atj: Int, radius: Int, iCenter: Int, kCenter: Int, kind: GeomPointType) -> [GeomPoints] {

    let pts = drawMidPointCircle(radius: radius, xCenter: iCenter, yCenter: kCenter)

    var points = [GeomPoints]()

    for (i, kList) in pts {
        let min = kList.min()!
        let max = kList.max()!

        for k in min...max{
            points.append(GeomPoints(i, atj, k, kind))
        }

    }
    return points
}



func drawCircleIK(atj: Int, radius: Int, iCenter: Int, kCenter: Int, kind: GeomPointType) -> [GeomPoints] {

    let pts = drawMidPointCircle(radius: radius, xCenter: iCenter, yCenter: kCenter)


    var points = [GeomPoints]()

    for (i, kList) in pts {
        for k in kList {
            points.append(GeomPoints(i, atj, k, kind))
        }
    }


    return points
}




//http://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm#Python
func drawMidPointCircle(radius: Int, xCenter: Int, yCenter: Int) -> [Int: [Int]] {


    //TODO add throws
    if radius > xCenter {print("ERROR")}
    if radius > yCenter {print("ERROR")}


    let x0:Int = Int(xCenter)
    let y0:Int = Int(yCenter)



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
func getBresenhamline(x0:Int, y0:Int, x1:Int, y1:Int) -> [(Int, Int)] {

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

