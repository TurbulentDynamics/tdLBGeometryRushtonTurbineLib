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





public struct RushtonTurbineMidPoint {


    public var gridX, gridY, gridZ: Int
    public let startingStep:Int

    let uav: Double
    let impellerStartupStepsUntilNormalSpeed: Int
    let impellerStartAngle: Double

    public let turbine: RushtonTurbine
    public let output: OutputGeometry

    var impellerIncrementFullStep: Radian = 0
    var impellerCurrentAngle: Radian = 0

    public var geomFixed: [Pos3d]
    public var geomRotating: [Pos3d]
    public var geomRotatingNonUpdating: [Pos3d]
    public var geomTranslating: [Pos3d]

    private let iCenter: Int
    private let kCenter: Int
    private let tankRadius: Int

    
    
    public init(gridX: Int, gridY: Int, gridZ: Int, uav: Double, impellerStartupStepsUntilNormalSpeed s: Int = 0, startingStep: Int = 0, impellerStartAngle: Double = 0.0) {

        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        

        self.tankRadius = gridX / 2
        self.iCenter = self.tankRadius
        self.kCenter = self.tankRadius
        
        self.uav = uav
        self.startingStep = startingStep
        self.impellerStartupStepsUntilNormalSpeed = s
        self.impellerStartAngle = impellerStartAngle

        self.turbine = RushtonTurbineReference(gridX:gridX, uav: uav, impellerStartupStepsUntilNormalSpeed: s, startingStep: startingStep, impellerStartAngle: impellerStartAngle)

        self.output = exampleTurbineOutput(turbine: self.turbine)

        
        geomFixed = []
        geomRotating = []
        geomRotatingNonUpdating = []
        geomTranslating = []
        
        generateFixedGeometry()
        generateRotatingGeometry(atθ: Radian(impellerStartAngle))
        generateRotatingNonUpdatingGeometry()

    }

    public init(fileName: String, outputJson: String) throws {

        self.turbine = try RushtonTurbine(fileName)
        self.output = try OutputGeometry(json: outputJson)

        self.gridX = self.turbine.gridX
        self.gridY = self.turbine.gridX
        self.gridZ = self.turbine.gridX

        self.tankRadius = gridX / 2
        self.iCenter = self.tankRadius
        self.kCenter = self.tankRadius


        self.uav = self.turbine.impellers["0"]!.uav

        self.startingStep = self.turbine.startingStep
        self.impellerStartupStepsUntilNormalSpeed = self.turbine.impellerStartupStepsUntilNormalSpeed
        self.impellerStartAngle = self.turbine.impellerStartAngle
        
        geomFixed = []
        geomRotating = []
        geomRotatingNonUpdating = []
        geomTranslating = []
    }

    
    
    public init(turbine: RushtonTurbine) {

        self.turbine = turbine
        self.output = exampleTurbineOutput(turbine: turbine)

        self.gridX = self.turbine.gridX
        self.gridY = self.turbine.gridX
        self.gridZ = self.turbine.gridX

        self.tankRadius = gridX / 2
        self.iCenter = self.tankRadius
        self.kCenter = self.tankRadius

        
        //TOFIX
        self.uav = self.turbine.impellers["0"]!.uav

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

  
    
    
    public mutating func generateFixedGeometry(){

        addWall(turbine: turbine)
        addBaffles(turbine: turbine)
    }

    public mutating func generateRotatingNonUpdatingGeometry() {

        addRotatingPartsNonUpdating(turbine: turbine)
    }

    public mutating func generateRotatingGeometry(atθ: Radian) {

        addImpellerBlades(turbine: turbine, atθ: atθ)
    }

    public mutating func updateRotatingGeometry(atθ: Radian) {
        self.geomRotating.removeAll()
        addImpellerBlades(turbine: turbine, atθ: atθ)
    }
    
    public mutating func updateGeometry(forStep step: Int) {
        //TODO
    }
    
    public mutating func generateTranslatingGeometry() {
        //TODO
        print("Need to implement generateTranslatingGeometry!!!!!")
    }

    public mutating func updateTranslatingGeometry(forStep step: Int) {
        //TODO
        print("Need to implement updateTranslatingGeometry!!!!!")
    }

 
}//end of class



// MARK: - Rotating Geometry
extension RushtonTurbineMidPoint {

    
    mutating func addRotatingPartsNonUpdating(turbine: RushtonTurbine){

        for imp in 0..<turbine.impellers.count {
            self.addImpellerHub(turbine: turbine, impeller: String(imp))
            self.addImpellerDisc(turbine: turbine, impeller: String(imp))
        }
        
        
        //Sort the start and end position of the shafts
        let impellers = turbine.impellers.values

        var tops = [-1]
        tops.append(contentsOf: impellers.map({$0.hub.top}))
        tops.sort(by: <)
        
        var bottoms = [turbine.tankHeight]
        bottoms.append(contentsOf: impellers.map({$0.hub.bottom}))
        bottoms.sort(by: <)
        

        let shaftSection = drawMidPointCircle(radius: turbine.shaft.radius, xCenter: iCenter, yCenter: kCenter)
        
        for (top, bottom) in zip(tops, bottoms){
            
            for j in (top+1)..<bottom {

                for s in shaftSection {

                    self.geomRotatingNonUpdating.append(Pos3d(i: s.0, j: j, k: s.1))
                }
            }
        }
        
    }
    
    
    

    mutating func addImpellerBlades(turbine: RushtonTurbine, atθ θ: Radian = 0.0, impeller: String = "0") {

        
        let impeller = turbine.impellers[impeller]!
        
        let blades = impeller.blades

        let deltaImpellerOffset: Radian = (2.0 * Radian.pi) / Radian(impeller.numBlades)

        var reducedθ = θ
        while reducedθ > 2 * Radian.pi {
            reducedθ -= 2 * Radian.pi
        }

            
        for nBlade in 0..<impeller.numBlades {

                
            let bladeAngle: Radian = reducedθ + Radian(impeller.firstBladeOffset) + deltaImpellerOffset * Radian(nBlade)

                
                
                let box = getBoxOnRadius2D(centerX: self.iCenter, centerY: self.kCenter, angle: bladeAngle, outerRadius: blades.outerRadius, thickness: blades.thickness, innerRadius: blades.innerRadius)
        
                
                for j in blades.top+1..<blades.bottom {

                    for (i, k) in box {
                        geomRotating.append(Pos3d(i: i, j: j, k: k))
                    }
                }
            
        
            geomRotating.append(contentsOf: getBoxLidOnRadius2D(atJ: blades.bottom, box: box))
                
                
            geomRotating.append(contentsOf: getBoxLidOnRadius2D(atJ: blades.top, box: box))


        }
    }
    
    
    
    mutating func addTurbineShaft(turbine: RushtonTurbine, top: Int, bottom: Int) {
            
        geomRotatingNonUpdating.append(contentsOf: drawCylinderWallIK(radius: turbine.shaft.radius, top: top, bottom: bottom, iCenter: self.iCenter, kCenter: self.kCenter))

    }

    mutating func addImpellerDisc(turbine: RushtonTurbine, impeller: String = "0") {

        let disk = turbine.impellers[impeller]!.disk
        let diskRadius = disk.radius

        geomRotatingNonUpdating.append(contentsOf: drawThickHollowDiscIK(innerRadius: turbine.shaft.radius, outerRadius: diskRadius, top:disk.top, bottom: disk.bottom, iCenter: self.iCenter, kCenter: self.kCenter))

        geomRotatingNonUpdating.append(contentsOf: drawCylinderWallIK(radius: disk.radius, top: disk.top, bottom: disk.bottom, iCenter: self.iCenter, kCenter: self.kCenter))

    }

    mutating func addImpellerHub(turbine: RushtonTurbine, impeller: String = "0") {

        let hub = turbine.impellers[impeller]!.hub
        let hubRadius = hub.radius

        geomRotatingNonUpdating.append(contentsOf: drawThickHollowDiscIK(innerRadius: turbine.shaft.radius, outerRadius: hubRadius, top:hub.top, bottom: hub.bottom, iCenter: self.iCenter, kCenter: self.kCenter))

        geomRotatingNonUpdating.append(contentsOf: drawCylinderWallIK(radius: hubRadius, top: hub.top, bottom: hub.bottom, iCenter: self.iCenter, kCenter: self.kCenter))

    }

}//end of extension




// MARK: - Fixed Geometry
extension RushtonTurbineMidPoint {

    
    mutating func addWall(turbine: RushtonTurbine) {

        geomFixed.append(contentsOf: drawCylinderWallIK(radius: self.tankRadius, top: 0, bottom: turbine.tankDiameter, iCenter: self.iCenter, kCenter: self.kCenter))
    }

    
    mutating func addBaffles(turbine: RushtonTurbine) {

        let tankHeight = turbine.tankDiameter

        let deltaBaffleOffset: Radian = (2.0 * Radian.pi) / Radian(turbine.baffles.numBaffles)

        for j in 0..<tankHeight {

            for nBaffle in 0..<turbine.baffles.numBaffles {

                let baffleAngle: Radian = Radian(turbine.baffles.firstBaffleOffset) + deltaBaffleOffset * Radian(nBaffle)


                for (i, k) in  getBoxOnRadius2D(centerX: self.iCenter, centerY: self.kCenter, angle: baffleAngle, outerRadius: turbine.baffles.outerRadius, thickness: turbine.baffles.thickness, innerRadius: turbine.baffles.innerRadius){

                
                    geomFixed.append(Pos3d(i: i, j: j, k: k))

                }
            }
        }
    }
}
    
    
    
    
// MARK: - primitives
extension RushtonTurbineMidPoint {
    

    func printPoints3d(points: [Pos3d]){
        
        for p in points {
            print("\(p.i) \(p.j) \(p.k)")
        }
    }

    
    func getBoxLidOnRadius2D(atJ: Int, box: [(Int, Int)]) -> [Pos3d] {

        var boxMap: [Int: [Int]] = [:]
        
        for (x,_) in box {
            boxMap[x] = []
        }
        for (x,y) in box {
            boxMap[x]?.append(y)
        }
        

        var lid: [Pos3d] = []
        
        for (x, ys) in boxMap {

            let min = ys.min()!
            let max = ys.max()!
            
            for k in min...max {
                lid.append(Pos3d(i:x, j:atJ, k:k))
          }
        }

        return lid;
    }

    
    
    
    
    func getBoxOnRadius2D(centerX: Int, centerY: Int, angle: Radian, outerRadius: Int, thickness: Int, innerRadius: Int) -> [(Int, Int)] {

    
        let outerEdge = getPerpendicularEdgeToRadius2d(centerX: centerX, centerY: centerY, angle: angle, radius:outerRadius, halfThickness:thickness/2)
        
        let innerEdge = getPerpendicularEdgeToRadius2d(centerX: centerX, centerY: centerY, angle: angle, radius:innerRadius, halfThickness:thickness/2)

        
        
        let outerEdgePoints = getBresenhamLine(x0:outerEdge.x0, y0:outerEdge.y0, x1:outerEdge.x1, y1:outerEdge.y1);
        let innerEdgePoints = getBresenhamLine(x0:innerEdge.x0, y0:innerEdge.y0, x1:innerEdge.x1, y1:innerEdge.y1);


        let sidePointsPos = getBresenhamLine(x0:outerEdge.x0, y0:outerEdge.y0, x1:innerEdge.x0, y1:innerEdge.y0);
        let sidePointsNeg = getBresenhamLine(x0:innerEdge.x1, y0:innerEdge.y1, x1:outerEdge.x1, y1:outerEdge.y1);
        

        var box: [(Int,Int)] = []
        
        for (x,y) in outerEdgePoints {
            box.append((x, y))
        }
        for (x,y) in innerEdgePoints {
            box.append((x, y))
        }
        for (x,y) in sidePointsPos {
            box.append((x, y))
        }
        for (x,y) in sidePointsNeg {
            box.append((x, y))
        }

        return box;
    }

    
    
    
    
    
    func getPerpendicularEdgeToRadius2d(centerX: Int, centerY: Int, angle: Radian, radius: Int, halfThickness: Int) -> Line {

        
        let midPointEdgeX = centerX + Int(Radian(radius) * cos(angle))
        let midPointEdgeY = centerY + Int(Radian(radius) * sin(angle))

        let edgeAngle: Radian = angle + 0.5 * Radian.pi

        let x0 = midPointEdgeX - Int(Radian(halfThickness) * cos(edgeAngle))
        let y0 = midPointEdgeY - Int(Radian(halfThickness) * sin(edgeAngle))

        let x1 = midPointEdgeX + Int(Radian(halfThickness) * cos(edgeAngle))
        let y1 = midPointEdgeY + Int(Radian(halfThickness) * sin(edgeAngle))


        return Line(x0: x0, y0: y0, x1: x1, y1: y1)
    }

    
    
    
    func drawThickHollowDiscIK(innerRadius: Int, outerRadius: Int, top: Int, bottom: Int, iCenter: Int, kCenter: Int) -> [Pos3d] {

        
        var thickHollowDisc = [Pos3d]()
        
        //Cylindar wall
        thickHollowDisc.append(contentsOf: drawCylinderWallIK(radius: outerRadius, top: top+1, bottom: bottom-1, iCenter: iCenter, kCenter: kCenter))
        
        //Top Cap
        thickHollowDisc.append(contentsOf: drawHollowDiscIK(atj: top, innerRadius: innerRadius, outerRadius: outerRadius, iCenter: iCenter, kCenter: kCenter))

        //bottom Cap
        thickHollowDisc.append(contentsOf: drawHollowDiscIK(atj: bottom, innerRadius: innerRadius, outerRadius: outerRadius, iCenter: iCenter, kCenter: kCenter))

        return thickHollowDisc
    }
    
    
    
    func drawHollowDiscIK(atj: Int, innerRadius: Int, outerRadius: Int, iCenter: Int, kCenter: Int) -> [Pos3d] {

        let outerPts = drawMidPointCircleDict(radius: outerRadius, xCenter: iCenter, yCenter: kCenter)
        let innerPts = drawMidPointCircleDict(radius: innerRadius, xCenter: iCenter, yCenter: kCenter)

        let innerI = innerPts.keys

        var disc3d = [Pos3d]()

        for (i, kList) in outerPts {
            let outerLeft = kList.min()!
            let outerRight = kList.max()!

            if innerI.contains(i) {
                let innerLeft = innerPts[i]!.min()!
                let innerRight = innerPts[i]!.max()!

                for k in outerLeft..<innerLeft {
                    disc3d.append(Pos3d(i:i, j:atj, k:k))
                }
                for k in innerRight + 1 ... outerRight {
                    disc3d.append(Pos3d(i:i, j:atj, k:k))
                }
                //Now do the points ON the inner Circle
                for k in innerPts[i]! {
                    disc3d.append(Pos3d(i:i, j:atj, k:k))
                }
            } else {
                for k in outerLeft...outerRight {
                    disc3d.append(Pos3d(i:i, j:atj, k:k))
                }

            }

        }
        return disc3d
    }

    func drawDiscIK(atj: Int, radius: Int, iCenter: Int, kCenter: Int) -> [Pos3d] {

        let pts = drawMidPointCircleDict(radius: radius, xCenter: iCenter, yCenter: kCenter)

        var disc3d = [Pos3d]()

        for (i, kList) in pts {
            let min = kList.min()!
            let max = kList.max()!

            for k in min...max {
                disc3d.append(Pos3d(i: i, j: atj, k: k))
            }
        }
        return disc3d
    }

    
    
    func drawCylinderWallIK(radius: Int, top: Int, bottom: Int, iCenter: Int, kCenter: Int) -> [Pos3d] {

        var cylinder = [Pos3d]()
    
        let circumference = drawMidPointCircle(radius: radius, xCenter: iCenter, yCenter: kCenter)
    
        for j in top...bottom {
            for p in circumference {
                cylinder.append(Pos3d(i:p.0, j:j, k:p.1))
            }
        }
        return cylinder
    }
    
    
    func drawCircleIK(atj: Int, radius: Int, iCenter: Int, kCenter: Int) -> [Pos3d] {

        var circle3d = [Pos3d]()


        let pts = drawMidPointCircle(radius: radius, xCenter: iCenter, yCenter: kCenter)

        for (i, k) in pts {
            circle3d.append(Pos3d(i: i, j: atj, k: k))
        }

        return circle3d
    }

    
    

    
    
    //http://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm#Python
    func drawMidPointCircleDict(radius: Int, xCenter: Int, yCenter: Int) -> [Int: [Int]] {

        //TODO add throws
        if radius > xCenter {print("ERROR: Radius is larger than xCenter")}
        if radius > yCenter {print("ERROR: Radius is larger than yCenter")}

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

    
    
    
    //http://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm#Python
    func drawMidPointCircle(radius: Int, xCenter: Int, yCenter: Int) -> [(Int, Int)] {

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

        var pts: [(Int, Int)] = []
    

        pts.append((x0,y0 + radius))
        pts.append((x0,y0 - radius))
        pts.append((x0 + radius,y0))
        pts.append((x0 - radius,y0))

        
        while x < y {

            if f >= 0 {
                y -= 1
                ddF_y += 2
                f += ddF_y
            }

            x += 1
            ddF_x += 2
            f += ddF_x + 1

            
            pts.append((x0 + x, y0 + y))
            pts.append((x0 - x, y0 + y))
            pts.append((x0 + x, y0 - y))
            pts.append((x0 - x, y0 - y))

            pts.append((x0 + y, y0 + x))
            pts.append((x0 - y, y0 + x))
            pts.append((x0 + y, y0 - x))
            pts.append((x0 - y, y0 - x))

        }

        return pts
    }

    
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
    
    
    
    
    //http://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#Python
    func getBresenhamLine(x0: Int, y0: Int, x1: Int, y1: Int) -> [(Int, Int)] {

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

