//
//  File.swift
//  
//
//  Created by Niall Ó Broin on 09/02/2021.
//

import Foundation
import tdLB
import tdLBGeometryRushtonTurbineLib
import tdLBGeometryRushtonTurbineLibObjC


func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


func savePoints3d(fileName: String, points pointsObjC: [Pos3d_int]){
    
    for u in pointsObjC {
        print(u)
    }
//    let points = pointsObjC.map()
    
//    savePoints3d(fileName: fileName, points: points)
    
    let filename = getDocumentsDirectory().appendingPathComponent(fileName)

    print("PLY file saved to \(filename.absoluteString)")

}


func savePoints3d(fileName: String, points: [Pos3d]){

    let filename = getDocumentsDirectory().appendingPathComponent(fileName)

    var str = "ply\nformat ascii 1.0\nelement vertex \(points.count)"
    str += "\nproperty int x\nproperty int y\nproperty int z\nend_header\n"
    
    for p in points {
        str += "\(p.i) \(p.j) \(p.k)\n"
    }

    do {
        try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        print("PLY file saved to \(filename.absoluteString)")
    } catch {
        print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding.")
    }
}


func printPoints3d(points: [Pos3d]){
    
    for p in points {
        print("\(p.i) \(p.j) \(p.k)")
    }
}



let tSwift = RushtonTurbineEggelsSomers(gridX: 300)
var g = RushtonTurbineMidPoint(turbine: tSwift)


g.generateFixedGeometry()
g.generateRotatingGeometry(atθ: 0)
g.generateRotatingNonUpdatingGeometry()

var geomSwift = g.returnFixedGeometry()
geomSwift.append(contentsOf: g.returnRotatingGeometry())
geomSwift.append(contentsOf: g.returnRotatingNonUpdatingGeometry())


savePoints3d(fileName: "yoke.ply", points: geomSwift)





let t = RushtonTurbineCPP()
let e = ExtentsCPP(0,300,0,300,0,300)

var gCPP = RushtonTurbineMidPointCPP(rushtonTurbine: t, extents: e)

gCPP.generateFixedGeometry()
gCPP.generateRotatingGeometry(atTheta: 0)
gCPP.generateRotatingGeometryNonUpdating()

var geomCPP = gCPP.returnFixedGeometry()

print(geomCPP.count)


geomCPP.append(contentsOf: gCPP.returnRotatingGeometry())
geomCPP.append(contentsOf: gCPP.returnRotatingNonUpdatingGeometry())


savePoints3d(fileName: "TurbineWithCPP.ply", points: geomCPP)

