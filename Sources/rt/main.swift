//
//  File.swift
//  
//
//  Created by Niall Ó Broin on 09/02/2021.
//

import Foundation
import ArgumentParser

import tdLB
import tdLBGeometryRushtonTurbineLib
import tdLBGeometryRushtonTurbineLibObjC


func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getMidPointSwiftPoints(gridX: Int) -> [Pos3d]{

    let rtSwift = RushtonTurbineReference(gridX: gridX)
    var g = RushtonTurbineMidPoint(turbine: rtSwift)


    g.generateFixedGeometry()
    g.generateRotatingGeometry(atθ: 0)
    g.generateRotatingNonUpdatingGeometry()

    var geomSwift = g.returnFixedGeometry()
    geomSwift.append(contentsOf: g.returnRotatingGeometry())
    geomSwift.append(contentsOf: g.returnRotatingNonUpdatingGeometry())

    return geomSwift
}


func getPolarSwiftPoints(gridX: Int) -> [Pos3d]{

    let rtSwift = RushtonTurbineReference(gridX: gridX)
    var g = RushtonTurbinePolarSwift(turbine: rtSwift)
    

    g.generateFixedGeometry()
    g.generateRotatingGeometry(atθ: 0)
    g.generateRotatingNonUpdatingGeometry()

    var geomSwift = g.returnFixedGeometry()
    geomSwift.append(contentsOf: g.returnRotatingGeometry())
    geomSwift.append(contentsOf: g.returnRotatingNonUpdatingGeometry())

    return geomSwift
}



func getMidPointCppPoints(gridX: Int) -> [Pos3d]{

    let t = RushtonTurbineCPP(gridX: gridX)
    
    let e = ExtentsCPP(x0: 0, x1: gridX, y0: 0, y1: gridX, z0: 0, z1: gridX)

    let gCPP = RushtonTurbineMidPointCPP(rushtonTurbine: t, extents: e)

    gCPP.generateFixedGeometry()
    gCPP.generateRotatingGeometry(atTheta: 0)
    gCPP.generateRotatingNonUpdatingGeometry()

    var geomCPP = gCPP.returnFixedGeometry()
    geomCPP.append(contentsOf: gCPP.returnRotatingGeometry())
    geomCPP.append(contentsOf: gCPP.returnRotatingNonUpdatingGeometry())

    return geomCPP
}

func getPolarCppPoints(gridX: Int) -> [Pos3d]{

    let t = RushtonTurbineCPP(gridX: gridX)
    
    let e = ExtentsCPP(x0: 0, x1: gridX, y0: 0, y1: gridX, z0: 0, z1: gridX)

    let gCPP = RushtonTurbinePolarCPP(t: t, e: e)

    gCPP.generateFixedGeometry()
    gCPP.generateRotatingGeometry(atTheta: 0)
    gCPP.generateRotatingNonUpdatingGeometry()

    var geomCPP = gCPP.returnFixedGeometry()
    geomCPP.append(contentsOf: gCPP.returnRotatingGeometry())
    geomCPP.append(contentsOf: gCPP.returnRotatingNonUpdatingGeometry())

    return geomCPP
}







func savePoints3d(path: URL, points: [Pos3d]){


    var str = "ply\nformat ascii 1.0\nelement vertex \(points.count)"
    str += "\nproperty int x\nproperty int y\nproperty int z\nend_header\n"
    
    for p in points {
        str += "\(p.i) \(p.j) \(p.k)\n"
    }

    do {
        try str.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        print("PLY file saved to \(path.absoluteString)")
    } catch {
        print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding.")
    }
}


func printPoints3d(points: [Pos3d]){
    
    for p in points {
        print("\(p.i) \(p.j) \(p.k)")
    }
}




enum Algo: String, EnumerableFlag {
    case MidPointSwift, MidPointCpp, PolarSwift, PolarCpp
}


struct geomRushtonTurbine: ParsableCommand {

    @Option(name: [.short, .long], help: "Filename to save ply file.")
    var filename: String = "Rushton-Turbine"
    
    @Option(name: [.customShort("x"), .long], help: "Tank Diameter")
    var gridX: Int = 300

    @Flag(help: "Select algo")
    var algo: Algo = .MidPointCpp

    mutating func run() throws {
        
        let path = getDocumentsDirectory().appendingPathComponent("\(filename)-\(algo.rawValue).ply")

        switch algo {
        case .MidPointSwift:
            let points = getMidPointSwiftPoints(gridX: gridX)
            savePoints3d(path: path, points: points)
        case .MidPointCpp:
            let points = getMidPointCppPoints(gridX: gridX)
            savePoints3d(path: path, points: points)
        case .PolarCpp:
            let points = getPolarSwiftPoints(gridX: gridX)
            savePoints3d(path: path, points: points)
        case .PolarSwift:
            let points = getPolarCppPoints(gridX: gridX)
            savePoints3d(path: path, points: points)
        }
        
        print(algo, filename, gridX)
    }
    
}

geomRushtonTurbine.main()
