//
//  EggelsSomersConfig.swift
//
//
//  Created by Niall Ó Broin on 29/03/2020.
//

import Foundation
import tdLBGeometry
import tdLBOutputGeometry



public func RushtonTurbineEggelsSomers(
        gridX: Int,
        uav: Double = 0.1,
        impellerStartupStepsUntilNormalSpeed: Int = 0,
        startingStep: Int = 0,
        impellerStartAngle: Double = 0.0) -> RushtonTurbine {

    let MDIAM_BORDER: Double = 2

    let tankDiameter: Double = Double(gridX) - MDIAM_BORDER
    let tankHeight: Double = tankDiameter

    let shaft = Shaft(radius: Int(tankDiameter * 2.0 / 75.0))

    // MARK: - Baffles

    let numBaffles: Int = 4
    //First baffle is offset by 1/8 of revolution, or 1/2 of the delta between baffles.
    let firstBaffleOffset = (2.0 * Double.pi / Double(numBaffles)) / 2.0

    let baffles = Baffles(
        firstBaffleOffset: firstBaffleOffset,
        innerRadius: Int(0.3830 * tankDiameter),
        thickness: Int(tankDiameter / 75.0),
        numBaffles: numBaffles,
        outerRadius: Int(0.4830 * tankDiameter)
    )

    // MARK: - Impeller

    let impellerDisk = Disk(
        top: Int(tankDiameter * 99.0 / 150.0),
        bottom: Int(tankDiameter * 101.0 / 150.0),
        radius: Int(tankDiameter / 8.0)
    )

    let impellerHub = Disk(
        top: Int(tankDiameter * 19.0 / 30.0),
        bottom: Int(tankDiameter * 21.0 / 30.0),
        radius: Int(tankDiameter * 4.0 / 75.0)
    )

    let impellerBlades = Blades(
        innerRadius: Int(tankDiameter / 12.0),
        top: Int(tankDiameter * (19.0 / 30.0)),
        thickness: Int(tankDiameter / 75.0),
        outerRadius: Int(tankDiameter / 6.0),
        bottom: Int(tankDiameter * (21.0 / 30.0))
    )

    // Eventual angular velocity impeller
    let impeller0_blade_tip_angular_vel_w0 = uav / Double(impellerBlades.outerRadius)

    let impeller = Impeller(
        blades: impellerBlades,
        uav: uav,
        bladeTipAngularVelW0: impeller0_blade_tip_angular_vel_w0,
        impellerPosition: Int(tankHeight * (2.0 / 3.0)),
        disk: impellerDisk,
        numBlades: 6,
        firstBladeOffset: 0,
        hub: impellerHub
    )

    let turbine = RushtonTurbine(
        tankDiameter: Int(tankDiameter),
        tankHeight: Int(tankHeight),
        impellerStartAngle: impellerStartAngle,
        shaft: shaft,
        impeller: ["0": impeller],
        gridX: gridX,
        impellerStartupStepsUntilNormalSpeed: impellerStartupStepsUntilNormalSpeed,
        baffles: baffles,
        startingStep: startingStep,
        name: "Eggels and Somers 1997",
        resolution: 0.7
    )
    return turbine
}




func exampleTurbineOutput(turbine: RushtonTurbine) -> OutputGeometry {

    var output = OutputGeometry()
    
    let xy0 = Ortho2D(at: turbine.tankDiameter/2 - 1, repeatStep: 10)
    let xy1 = Ortho2D(at: turbine.tankDiameter/2, repeatStep: 10)
    let xy2 = Ortho2D(at: turbine.tankDiameter/2 + 1, repeatStep: 10)
    output.add(xy:xy0)
    output.add(xy:xy1)
    output.add(xy:xy2)

    
    let xz0 = Ortho2D(at: turbine.impellers["0"]!.impellerPosition - 1, repeatStep: 10)
    let xz1 = Ortho2D(at: turbine.impellers["0"]!.impellerPosition, repeatStep: 10)
    let xz2 = Ortho2D(at: turbine.impellers["0"]!.impellerPosition + 1, repeatStep: 10)
    
//    let xz0 = Ortho2D(at: turbine.impeller.impellerPosition - 1, repeatStep: 10)
//    let xz1 = Ortho2D(at: turbine.impeller.impellerPosition, repeatStep: 10)
//    let xz2 = Ortho2D(at: turbine.impeller.impellerPosition + 1, repeatStep: 10)
    
    
    output.add(xz:xz0)
    output.add(xz:xz1)
    output.add(xz:xz2)
    
    let yz0 = Ortho2D(at: turbine.tankDiameter/2, repeatStep: 10)
    output.add(yz:yz0)

    let v = Volume(repeatStep: 100)
    output.add(v)
    
    
    
//    let xzML = Ortho2D(at: impeller.impellerPosition / 2, repeatStep:10, from: 1000)
    //TODO
    //    let angle = Angle2D(atAngle: <#T##Int#>, repeatStep: <#T##Int#>, from: <#T##Int?#>, to: <#T##Int?#>)


    return output

}
