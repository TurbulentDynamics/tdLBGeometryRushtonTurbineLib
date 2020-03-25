//
//  data.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//

import Foundation


struct GeomPoints {
    let i: Int
    let j: Int
    let k: Int
}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}


func getPoints(θ:Double, radius:Double) -> (Int, Int) {

    //θ should be in radians
    let i = Int(radius * cos(θ))
    let k = Int(radius * sin(θ))

    return (i, k)
}


func createTankWall(height:Int, diameter:Int, dθ:Double) -> [GeomPoints] {

    //dθ is increment in radians per step.

    var pts = [GeomPoints]()

    let radius:Double = Double(diameter) / 2


    for j in 0..<height {

        for θ in stride(from: 0, to: 2 * Double.pi, by: dθ) {

            let (i, k) = getPoints(θ: θ, radius: radius)

            pts.append(GeomPoints(i:i, j:j, k:k))
        }
    }

    return pts
}




