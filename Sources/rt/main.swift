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



func getSwiftPoints(gridX: Int) -> [Pos3d]{

    let tSwift = RushtonTurbineEggelsSomers(gridX: gridX)
    var g = RushtonTurbineMidPoint(turbine: tSwift)


    g.generateFixedGeometry()
    g.generateRotatingGeometry(atθ: 0)
    g.generateRotatingNonUpdatingGeometry()

    var geomSwift = g.returnFixedGeometry()
    geomSwift.append(contentsOf: g.returnRotatingGeometry())
    geomSwift.append(contentsOf: g.returnRotatingNonUpdatingGeometry())

    return geomSwift
}



func getCppPoints(gridX: Int) -> [Pos3d_int]{

    var t = RushtonTurbineCPP(gridX)
    
    let e = ExtentsCPP()
//    let t = RushtonTurbineCPP()
//    let e = ExtentsCPP(0,300,0,300,0,300)

    var gCPP = RushtonTurbineMidPointCPP(rushtonTurbine: t, extents: e)

    gCPP.generateFixedGeometry()
    gCPP.generateRotatingGeometry(atTheta: 0)
    gCPP.generateRotatingGeometryNonUpdating()

    var geomCPP = gCPP.returnFixedGeometry()

    print(geomCPP.count)


    geomCPP.append(contentsOf: gCPP.returnRotatingGeometry())
    geomCPP.append(contentsOf: gCPP.returnRotatingNonUpdatingGeometry())


    return geomCPP
    
}


func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


func savePoints3d(path: URL, points pointsObjC: [Pos3d_int]){
    
    for u in pointsObjC {
        print(u)

        let p = Pos3d_int()
        print("\(p)")
    }
//    let points = pointsObjC.map()
    
//    savePoints3d(fileName: fileName, points: points)
    

    print("PLY file saved to \(path.absoluteString)")

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
    case swift, cpp
}


struct geomRushtonTurbine: ParsableCommand {

    @Argument(help: "Filename to save ply file.")
    var filename: String = "Rushton-Turbine"
    
    @Argument(help: "Tank Diameter")
    var gridX: Int = 300

//    @Flag(name: .shartAndLong, help: "Select algo")
    @Flag(help: "Select algo")
    var algo: Algo = .cpp

    mutating func run() throws {
        
        let path = getDocumentsDirectory().appendingPathComponent("\(filename)-\(algo.rawValue).ply")

        switch algo {
        case .swift:
            let points = getSwiftPoints(gridX: gridX)
            savePoints3d(path: path, points: points)
        case .cpp:
            let points = getCppPoints(gridX: gridX)
            savePoints3d(path: path, points: points)
        }
        
        print(algo, filename, gridX)
    }
    
}

geomRushtonTurbine.main()
