//
//  tdGeometryRushtonTurbineLib.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//

struct tdGeometryRushtonTurbineLib {
    var text = "Hello, World!"
}


public enum GeomPointType {
    //case Fluid
    case FixedBoundary
    case MovingBoundary
}


public struct GeomPoints {
    public let i, j, k : Int
    public let kind: GeomPointType

    init(i: Int, j: Int, k: Int, kind: GeomPointType){
        self.i = i
        self.j = j
        self.k = k
        self.kind = kind
    }

    init(_ i: Int, _ j: Int, _ k: Int, _ kind: GeomPointType){
        self.i = i
        self.j = j
        self.k = k
        self.kind = kind
    }
}


public func getRushtonTurbineGeometry() -> [GeomPoints] {
    return getGeometry()
}




