//
//  EggelsSomersConfig.swift
//
//
//  Created by Niall Ó Broin on 29/03/2020.
//

import Foundation
import tdLBGeometry



public func RushtonTurbineReference(
        gridX: Int,
        uav: Double = 0.1,
        impellerStartupStepsUntilNormalSpeed: Int = 0,
        startingStep: Int = 0,
        impellerStartAngle: Double = 0.0) -> RushtonTurbine {

    
    let MDIAM_BORDER: Int = 2
    let tankDiameter: Double = Double(gridX - MDIAM_BORDER)

    //Principal Parameters defined from
    //Hartmann H, Derksen JJ, Montavon C, Pearson J, Hamill IS, Van den Akker HEA. Assessment of large eddy and rans stirred tank simulations by means of LDA. Chem Eng Sci. 2004;59:2419–2432.
    let tankRadius: Double = tankDiameter / 2
    let impellerPosition: Int = Int(tankDiameter * (2.0 / 3.0))
    let D: Double = tankDiameter / 3.0
    
    
    let shaft = Shaft(radius: Int(D * 0.08))

    
    
    // MARK: - Baffles

    let numBaffles: Int = 4
    //First baffle is offset by 1/8 of revolution, or 1/2 of the delta between baffles.
    let firstBaffleOffset = (2.0 * Double.pi / Double(numBaffles)) / 2.0

    let baffles = Baffles(
        firstBaffleOffset: firstBaffleOffset,
        innerRadius: Int(tankRadius - (tankDiameter * 0.017) - (tankDiameter * 0.1)),
        thickness: Int(tankDiameter / 75.0),
        numBaffles: numBaffles,
        outerRadius: Int(tankRadius - (tankDiameter * 0.017))
    )

    // MARK: - Impeller

    let impellerBlades = Blades(
        innerRadius: Int((D / 2.0) - (D * 0.25)),
        top: impellerPosition - Int(D * 0.1),
        thickness: Int(D * 0.04),
        outerRadius: Int(D / 2.0),
        bottom: impellerPosition + Int(D * 0.1)
    )
    
    let impellerDisk = Disk(
        top: impellerPosition - Int(D * 0.02),
        bottom: impellerPosition + Int(D * 0.02),
        radius: Int(D * 0.375)
    )

    let impellerHub = Disk(
        top: impellerPosition - Int(D * 0.1),
        bottom: impellerPosition + Int(D * 0.1),
        radius: Int(D * 0.16)
    )

    // Eventual angular velocity impeller
    let impeller0_blade_tip_angular_vel_w0 = uav / Double(impellerBlades.outerRadius)

    let impeller = Impeller(
        blades: impellerBlades,
        uav: uav,
        bladeTipAngularVelW0: impeller0_blade_tip_angular_vel_w0,
        impellerPosition: impellerPosition,
        disk: impellerDisk,
        numBlades: 6,
        firstBladeOffset: 0,
        hub: impellerHub
    )

    let turbine = RushtonTurbine(
        tankDiameter: Int(tankDiameter),
        tankHeight: Int(tankDiameter),
        impellerStartAngle: impellerStartAngle,
        shaft: shaft,
        impeller: ["0": impeller],
        gridX: gridX,
        impellerStartupStepsUntilNormalSpeed: impellerStartupStepsUntilNormalSpeed,
        baffles: baffles,
        startingStep: startingStep,
        name: "Reference",
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
