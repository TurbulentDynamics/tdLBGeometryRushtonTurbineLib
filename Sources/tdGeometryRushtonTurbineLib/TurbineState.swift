//
//  TurbineState.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 01.02.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

struct TurbineState: Equatable {
    var canvasWidth: Float
    var canvasHeight: Float
    var tankDiameter: Float
    var tankHeight: Float
    var shaftRadius: Float
    var kernelAutoRotation: Bool
    var kernelRotationDir: String
    var baffleCount: Int
    var baffleInnerRadius: Float
    var baffleOuterRadius: Float
    var baffleWidth: Float

    var impellerCount: Int
    var hubRadius: [Float]
    var hubHeight: [Float]
    var diskRadius: [Float]
    var diskHeight: [Float]
    var bladeCount: [Int]
    var bladeInnerRadius: [Float]
    var bladeOuterRadius: [Float]
    var bladeWidth: [Float]
    var bladeHeight: [Float]

    var transPanXY: Int
    var transPanYZ: Int
    var transPanXZ: Int
    var transRotateAngle: Int
    var transEnableXY: Bool
    var transEnableYZ: Bool
    var transEnableXZ: Bool
    var transEnableImpeller: Bool
    var transEnableRotate: Bool

    func changeValues(
        tankDiameter: Float? = nil,
        tankHeight: Float? = nil,
        shaftRadius: Float? = nil,
        baffleCount: Int? = nil,
        baffleInnerRadius: Float? = nil,
        baffleOuterRadius: Float? = nil,
        baffleWidth: Float? = nil,
        impellerCount: Int? = nil,
        hubRadius: [Float]? = nil,
        hubHeight: [Float]? = nil,
        diskRadius: [Float]? = nil,
        diskHeight: [Float]? = nil,
        bladeCount: [Int]? = nil,
        bladeInnerRadius: [Float]? = nil,
        bladeOuterRadius: [Float]? = nil,
        bladeWidth: [Float]? = nil,
        bladeHeight: [Float]? = nil,
        transPanXY: Int? = nil,
        transPanYZ: Int? = nil,
        transPanXZ: Int? = nil,
        transRotateAngle: Int? = nil,
        transEnableXY: Bool? = nil,
        transEnableYZ: Bool? = nil,
        transEnableXZ: Bool? = nil,
        transEnableRotate: Bool? = nil
    ) -> TurbineState {
        return TurbineState(
            canvasWidth: self.canvasWidth,
            canvasHeight: self.canvasHeight,
            tankDiameter: tankDiameter ?? self.tankDiameter,
            tankHeight: tankHeight ?? self.tankHeight,
            shaftRadius: shaftRadius ?? self.shaftRadius,
            kernelAutoRotation: self.kernelAutoRotation,
            kernelRotationDir: self.kernelRotationDir,
            baffleCount: baffleCount ?? self.baffleCount,
            baffleInnerRadius: baffleInnerRadius ?? self.baffleInnerRadius,
            baffleOuterRadius: baffleOuterRadius ?? self.baffleOuterRadius,
            baffleWidth: baffleWidth ?? self.baffleWidth,
            impellerCount: impellerCount ?? self.impellerCount,
            hubRadius: hubRadius ?? self.hubRadius,
            hubHeight: hubHeight ?? self.hubHeight,
            diskRadius: diskRadius ?? self.diskRadius,
            diskHeight: diskHeight ?? self.diskHeight,
            bladeCount: bladeCount ?? self.bladeCount,
            bladeInnerRadius: bladeInnerRadius ?? self.bladeInnerRadius,
            bladeOuterRadius: bladeOuterRadius ?? self.bladeOuterRadius,
            bladeWidth: bladeWidth ?? self.bladeWidth,
            bladeHeight: bladeHeight ?? self.bladeHeight,
            transPanXY: transPanXY ?? self.transPanXY,
            transPanYZ: transPanYZ ?? self.transPanYZ,
            transPanXZ: transPanXZ ?? self.transPanXZ,
            transRotateAngle: transRotateAngle ?? self.transRotateAngle,
            transEnableXY: transEnableXY ?? self.transEnableXY,
            transEnableYZ: transEnableYZ ?? self.transEnableYZ,
            transEnableXZ: transEnableXZ ?? self.transEnableXZ,
            transEnableImpeller: false,
            transEnableRotate: transEnableRotate ?? self.transEnableRotate
        )
    }

    func changeImpellerCount(_ value: Int?) -> TurbineState {
        return changeValues(
            impellerCount: value,
            hubRadius: update(newCount: value, array: self.hubRadius),
            hubHeight: update(newCount: value, array: self.hubHeight),
            diskRadius: update(newCount: value, array: self.diskRadius),
            diskHeight: update(newCount: value, array: self.diskHeight),
            bladeCount: update(newCount: value, array: self.bladeCount),
            bladeInnerRadius: update(newCount: value, array: self.bladeInnerRadius),
            bladeOuterRadius: update(newCount: value, array: self.bladeOuterRadius),
            bladeWidth: update(newCount: value, array: self.bladeWidth),
            bladeHeight: update(newCount: value, array: self.bladeHeight)
        )
    }
}

private func update<T>(newCount: Int?, array: [T]) -> [T] {
    if let value = newCount {
        if value < array.count {
            return Array<T>(array.prefix(value))
        } else if value > array.count {
            return array + Array<T>(repeating: array[0], count: value - array.count)
        }
        return array
    } else {
        return array
    }
}
