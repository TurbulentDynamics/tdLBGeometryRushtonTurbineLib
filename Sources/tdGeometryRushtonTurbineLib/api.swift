//
//  data.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//

import Foundation



public func getGeometry() -> [GeomPoints]{

    var pts = [GeomPoints]()


    let tankDiameter = 300


    let testTurbine = getEggelsSomersConfig(gridx: tankDiameter, uav: 0.1, impellerStartupStepsUntilNormalSpeed: 0, startingStep: 0, impellerStartAngle: 0)


    pts.append(contentsOf: getMidPointGeometry(turbine: testTurbine))


//    pts.append(contentsOf: getGeometryGillersion(turbine: testTurbine))

    
    return pts
}




public func getGeometrySample() -> [GeomPoints] {

    //This defines the angle that the impeller will turn every step.
    let dθ = 2 * Double.pi / 500

    var points = [GeomPoints]()
    points.append(contentsOf: createTankWallSample(height: 300, diameter: 300, dθ:dθ))
    return points
}






func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}


func getPoints(θ:Double, radius:Double) -> (Int, Int) {

    //θ should be in radians
    let i = Int(radius * cos(θ) + radius)
    let k = Int(radius * sin(θ) + radius)

    return (i, k)
}

func createTankWallSample(height:Int, diameter:Int, dθ:Double) -> [GeomPoints] {

    //dθ is increment in radians per step.

    var pts = [GeomPoints]()

    let radius:Double = Double(diameter) / 2


    for j in 0..<height {

        for θ in stride(from: 0, to: 2 * Double.pi, by: dθ) {

            let (i, k) = getPoints(θ: θ, radius: radius)

            pts.append(GeomPoints(i:i, j:j, k:k, kind: .FixedBoundary))
        }
    }

    return pts
}





