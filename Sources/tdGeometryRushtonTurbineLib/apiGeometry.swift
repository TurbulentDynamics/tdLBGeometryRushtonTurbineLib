//
//  apiGeometry.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//

import Foundation


public typealias tGeomCalc = Float


public typealias Radian = tGeomCalc
public typealias Degree = tGeomCalc






protocol Geometry {

    var gridX: Int {get}
    var gridY: Int {get}
    var gridZ: Int {get}


    var uav: Double {get}
    var startingStep: Int  {get}
    var impellerStartupStepsUntilNormalSpeed: Int  {get}
    var impellerStartAngle: Double  {get}
    var impellerCurrentAngle: Radian {get}

    var turbine: RushtonTurbine {get}
    var output: qVecOutputData {get}


    var geomFixed: [RotatingGeomPoints] {get set}
    var geomRotating: [RotatingGeomPoints] {get set}

    init(gridX:Int, gridY:Int, gridZ:Int,
         uav: Double,
         impellerStartupStepsUntilNormalSpeed s: Int,
         startingStep: Int, impellerStartAngle: Double)

    init(fileName: String, outputJson: String) throws


    mutating func updateGeom(forStep step: Int)


    func getRotatingGeomPoints() -> [(Int, Int, Int, Int)]
    func getFixedGeomPoints() -> [(Int, Int, Int, Int)]


}




public struct FixedGeomPoints {
    let i_cart, j_cart, k_cart : Int

    init(i_cart: Int, j_cart: Int, k_cart: Int){

        self.i_cart = 0
        self.j_cart = 0
        self.k_cart = 0

    }

    init(_ i: Int, _ j: Int, _ k: Int){
        self.init(i_cart:i, j_cart:j, k_cart:k)
    }

    init(i: Int, j: Int, k: Int){
        self.init(i_cart:i, j_cart:j, k_cart:k)
    }

}




public struct RotatingGeomPoints {

    var r_polar: tGeomCalc = 0
    var t_polar: tGeomCalc = 0

    public var i_cart_fp: tGeomCalc = 0
    public var j_cart_fp: tGeomCalc = 0
    public var k_cart_fp: tGeomCalc = 0

    public var i_cart: Int = 0
    public var j_cart: Int = 0
    public var k_cart: Int = 0

    public var i_cart_fraction: tGeomCalc {return i_cart_fp.truncatingRemainder(dividingBy: 1)}
    public var j_cart_fraction: tGeomCalc {return j_cart_fp.truncatingRemainder(dividingBy: 1)}
    public var k_cart_fraction: tGeomCalc {return k_cart_fp.truncatingRemainder(dividingBy: 1)}


    public var u_delta: tGeomCalc = 0
    public var v_delta: tGeomCalc = 0
    public var w_delta: tGeomCalc = 0


    init(r_polar: tGeomCalc, t_polar: tGeomCalc,
         i_cart_fp: tGeomCalc, j_cart_fp:tGeomCalc, k_cart_fp:tGeomCalc,
         u_delta: tGeomCalc, v_delta:tGeomCalc, w_delta:tGeomCalc
    ){
        self.r_polar = r_polar
        self.t_polar = t_polar

        self.i_cart_fp = i_cart_fp
        self.j_cart_fp = j_cart_fp
        self.k_cart_fp = k_cart_fp

        self.u_delta = u_delta
        self.v_delta = v_delta
        self.w_delta = w_delta


        self.i_cart = Int(ceil(i_cart_fp))
        self.j_cart = Int(ceil(j_cart_fp))
        self.k_cart = Int(ceil(k_cart_fp))

//        print(self.i_cart, self.j_cart, self.k_cart)

    }


    init(i_cart_fp: tGeomCalc, j_cart_fp: tGeomCalc, k_cart_fp: tGeomCalc){
        self.i_cart_fp = i_cart_fp
        self.j_cart_fp = j_cart_fp
        self.k_cart_fp = k_cart_fp

        self.i_cart = Int(ceil(i_cart_fp))
        self.j_cart = Int(ceil(j_cart_fp))
        self.k_cart = Int(ceil(k_cart_fp))

    }


    init(i_cart: Int, j_cart: Int, k_cart: Int){
        self.i_cart = i_cart
        self.j_cart = j_cart
        self.k_cart = k_cart
    }


}//end of struct



