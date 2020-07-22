//
//  tdGeometryRushtonTurbineLib.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//
import tdLBApi

struct tdGeometryRushtonTurbineLib {
    var text = "Hello, World!"
}


public enum PointCloudType {
    case rotating
    case fixed
}


public struct PointCloudElement {
    let i, j, k: Int
    let kind: PointCloudType
}


//TODO Move more generic version to tdLBApi
protocol Geometry {

    var gridX: Int {get}
    var gridY: Int {get}
    var gridZ: Int {get}

    var uav: Double {get}
    var startingStep: Int {get}
    var impellerStartupStepsUntilNormalSpeed: Int {get}
    var impellerStartAngle: Double {get}
    var impellerCurrentAngle: Radian {get}

    var turbine: RushtonTurbine {get}
    var output: qVecOutputData {get}

    var geomFixed: [RotatingGeomPoints] {get set}
    var geomRotating: [RotatingGeomPoints] {get set}

    init(gridX: Int, gridY: Int, gridZ: Int,
         uav: Double,
         impellerStartupStepsUntilNormalSpeed s: Int,
         startingStep: Int, impellerStartAngle: Double)

    init(fileName: String, outputJson: String) throws

    mutating func updateGeom(forStep step: Int)


    mutating func generateFixedGeometry(turbine: RushtonTurbine)
    mutating func generateRotatingGeometry(turbine: RushtonTurbine, atθ: Radian)


    func getRotatingPointCloud() -> [PointCloudElement]
    func getFixedPointCloud() -> [PointCloudElement]

}
