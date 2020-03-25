//
//  JsonModel.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 04.02.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import Foundation

enum GeneralError: Error {
    case security
}





func readTurbineState(_ url: URL) throws -> TurbineState {
    guard url.startAccessingSecurityScopedResource() else {
        throw GeneralError.security
    }

    defer {
        url.stopAccessingSecurityScopedResource()
    }

    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    let object = try decoder.decode(JData.self, from: data)
    return JData.create(object)
}

func saveTurbineState(state: TurbineState, url: URL) throws {
    guard url.startAccessingSecurityScopedResource() else {
        throw GeneralError.security
    }

    defer {
        url.stopAccessingSecurityScopedResource()
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let date = formatter.string(from: Date())
    let fileURL = url.appendingPathComponent("tdGeometryRushtonTurbine-\(date).json")

    let encoder = JSONEncoder()
    let data = try encoder.encode(JData.create(state))
    try data.write(to: fileURL, options: .atomic)
}

extension JData {

    static func create(_ state: TurbineState) -> JData {
        var impellers = [String : JImpeller]()
        for i in 0..<state.impellerCount {
            let blade = JBlade(
                innerRadius: state.bladeInnerRadius[i],
                outerRadius: state.bladeOuterRadius[i],
                bottom: "71.4000015",
                top: state.bladeHeight[i],
                bladeThickness: state.bladeWidth[i]
            )

            let disk = JDisk(radius: state.diskRadius[i], bottom: "68.6800003", top: state.diskHeight[i])
            let hub = JHub(radius: state.hubRadius[i], bottom: "71.4000015", top: state.hubHeight[i])

            let impeller = JImpeller(
                numBlades: state.bladeCount[i],
                firstBladeOffset: 0,
                uav: "0.100000001",
                blade_tip_angular_vel_w0: "0.00588235306",
                impeller_position: Int(state.tankDiameter) / (state.impellerCount + 1) * (i + 1),
                blades: blade,
                disk: disk,
                hub: hub
            )
            impellers[String(i)] = impeller
        }

        let baffle = JBaffle(
            numBaffles: state.baffleCount,
            firstBaffleOffset: "0.785398185",
            innerRadius: state.baffleInnerRadius,
            outerRadius: state.baffleOuterRadius,
            thickness: state.baffleWidth
        )

        let shaft = JShaft(radius: state.shaftRadius)

        return JData(
            name: "GeometryConfig",
            gridx: state.tankHeight,
            resolution: "0.699999988",
            tankDiameter: state.tankDiameter,
            starting_step: 0,
            impeller_start_angle: 0,
            impeller_startup_steps_until_normal_speed: 0,
            baffles: baffle,
            numImpellers: state.impellerCount,
            shaft: shaft,
            impeller: impellers
        )
    }

    static func create(_ data: JData) -> TurbineState {
        var hubRadius = Array<Float>(repeating: 0, count: data.numImpellers)
        var hubHeight = Array<Float>(repeating: 0, count: data.numImpellers)
        var diskRadius = Array<Float>(repeating: 0, count: data.numImpellers)
        var diskHeight = Array<Float>(repeating: 0, count: data.numImpellers)

        var bladeCount = Array<Int>(repeating: 0, count: data.numImpellers)
        var bladeInnerRadius = Array<Float>(repeating: 0, count: data.numImpellers)
        var bladeOuterRadius = Array<Float>(repeating: 0, count: data.numImpellers)
        var bladeWidth = Array<Float>(repeating: 0, count: data.numImpellers)
        var bladeHeight = Array<Float>(repeating: 0, count: data.numImpellers)

        data.impeller.forEach {
            if let key = Int($0) {
                hubRadius[key] = $1.hub.radius
                hubHeight[key] = $1.hub.top
                diskRadius[key] = $1.disk.radius
                diskHeight[key] = $1.disk.top
                bladeCount[key] = $1.numBlades
                bladeInnerRadius[key] = $1.blades.innerRadius
                bladeOuterRadius[key] = $1.blades.outerRadius
                bladeWidth[key] = $1.blades.bladeThickness
                bladeHeight[key] = $1.blades.top
            }
        }

        return TurbineState(
            canvasWidth: 0,
            canvasHeight: 0,
            tankDiameter: data.tankDiameter,
            tankHeight: data.gridx,
            shaftRadius: data.shaft.radius,
            kernelAutoRotation: false,
            kernelRotationDir: "clockwise",
            baffleCount: data.baffles.numBaffles,
            baffleInnerRadius: data.baffles.innerRadius,
            baffleOuterRadius: data.baffles.outerRadius,
            baffleWidth: data.baffles.thickness,
            impellerCount: data.numImpellers,
            hubRadius: hubRadius,
            hubHeight: hubHeight,
            diskRadius: diskRadius,
            diskHeight: diskHeight,
            bladeCount: bladeCount,
            bladeInnerRadius: bladeInnerRadius,
            bladeOuterRadius: bladeOuterRadius,
            bladeWidth: bladeWidth,
            bladeHeight: bladeHeight,
            transPanXY: 0,
            transPanYZ: 0,
            transPanXZ: 0,
            transRotateAngle: 0,
            transEnableXY: false,
            transEnableYZ: false,
            transEnableXZ: false,
            transEnableImpeller: false,
            transEnableRotate: false
        )
    }
}

private struct JData: Codable {
    var name: String
    var gridx: Float
    var resolution: String
    var tankDiameter: Float
    var starting_step: Int
    var impeller_start_angle: Int
    var impeller_startup_steps_until_normal_speed: Int
    var baffles: JBaffle
    var numImpellers: Int
    var shaft: JShaft
    var impeller: [String : JImpeller]
}

private struct JBaffle: Codable {
    var numBaffles: Int
    var firstBaffleOffset: String
    var innerRadius: Float
    var outerRadius: Float
    var thickness: Float
}

private struct JShaft: Codable {
    var radius: Float
}

private struct JImpeller: Codable {
    var numBlades: Int
    var firstBladeOffset: Int
    var uav: String
    var blade_tip_angular_vel_w0: String
    var impeller_position: Int
    var blades: JBlade
    var disk: JDisk
    var hub: JHub
}

private struct JBlade: Codable {
    var innerRadius: Float
    var outerRadius: Float
    var bottom: String
    var top: Float
    var bladeThickness: Float
}

private struct JDisk: Codable {
    var radius: Float
    var bottom: String
    var top: Float
}

private struct JHub: Codable {
    var radius: Float
    var bottom: String
    var top: Float
}
