//
//  File.swift
//
//
//  Created by Niall Ó Broin on 26/03/2020.
//

import Foundation

typealias tNi = Int


func getGeometryGillersion(turbine: RushtonTurbine) -> [GeomPoints]{

    var pts = [GeomPoints]()

    pts.append(contentsOf: createTankWallLegacy(turbine: turbine))
    pts.append(contentsOf: createBafflesLegacy(turbine: turbine))


//    pts.append(contentsOf: createImpellerBladesLegacy(turbine: turbine, step: 0, wa: 0.1))
//    pts.append(contentsOf: createImpellerDiskLegacy(turbine: turbine))
//    pts.append(contentsOf: createImpellerShaftLegacy(turbine: turbine))
//    pts.append(contentsOf: createImpellerHubLegacy(turbine: turbine))


    return pts
}





func createTankWallLegacy(turbine: RushtonTurbine) -> [GeomPoints] {

    let centerX = Float(turbine.tankDiameter) / 2.0
    let centerZ = centerX
    let tankHeight = turbine.tankDiameter
    let resolution = Float(turbine.resolution)




    let nCircPoints: tNi = 4 * tNi((Float.pi * Float(turbine.tankDiameter) / (4.0 * resolution)))
    let dTheta: Float = 2 * Float.pi / Float(nCircPoints)
    let tankRadius: Float = 0.5 * Float(turbine.tankDiameter)


    var pts = [GeomPoints]()


    for y in 0..<tankHeight {
        for k in 0..<nCircPoints {

            var theta: Float = Float(k) * dTheta
            if ((y & 1) == 1) {theta += 0.5 * dTheta}


            //            GeomData g
            let i = centerX + tankRadius * cos(theta)
            let j = Float(y) + 0.5
            let k = centerZ + tankRadius * sin(theta)
            //            g.is_solid = 0
            pts.append(GeomPoints(i:tNi(i), j:tNi(j), k:tNi(k), kind: .FixedBoundary))

            //Separates the int and decimal part of float.  int is used for calculation in Forcing
            //            UpdatePointFractions(g)
            //
            //            if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
            //
            //                g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds)
            //                g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
            //                g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds)
            //
            //                if (get_solid && g.is_solid) result.push_back(g)
            //                if (get_solid == 0 && g.is_solid == 0) result.push_back(g)


        }
    }

    return pts
}




//
//void inline Geometry::UpdateCoordinateFraction(Float coordinate, tNi *integerPart, Float *fractionPart)
//{
//    *integerPart = tNi(roundf(coordinate + 0.5f))
//    *fractionPart = coordinate - (Float)(*integerPart) - 0.5f
//}
//
//
//
//void inline Geometry::UpdatePointFractions(GeomData &point)
//{
//    UpdateCoordinateFraction(point.i_cart_fp, &point.i_cart, &point.i_cart_fraction)
//    UpdateCoordinateFraction(point.j_cart_fp, &point.j_cart, &point.j_cart_fraction)
//    UpdateCoordinateFraction(point.k_cart_fp, &point.k_cart, &point.k_cart_fraction)
//}









func createBafflesLegacy(turbine: RushtonTurbine) -> [GeomPoints] {

    let centerX = Float(turbine.tankDiameter) / 2.0
    let centerZ = centerX
    let tankHeight = turbine.tankDiameter

    let resolution = Float(turbine.resolution)


    var nPointsBaffleThickness = tNi(Float(turbine.baffles.thickness) / resolution)
    if nPointsBaffleThickness == 0 {nPointsBaffleThickness = 1}

    let resolutionBaffleThickness: Float = Float(turbine.baffles.thickness) / Float(nPointsBaffleThickness)

    let nPointsR: tNi = tNi(Float(turbine.baffles.outerRadius - turbine.baffles.innerRadius) / resolution)

    let deltaR: Float = Float((turbine.baffles.outerRadius - turbine.baffles.innerRadius)) / Float(nPointsR)

    let deltaBaffleOffset: Float = 2.0/Float(turbine.baffles.numBaffles) * Float.pi


    var pts = [GeomPoints]()


    for nBaffle in 0..<turbine.baffles.numBaffles {
        //        for (tNi y = lowerLimitY y <= upperLimitY ++y)
        for y in 0..<tankHeight {
            for idxR in 0...nPointsR {
                let r: Float = Float(turbine.baffles.innerRadius) + deltaR * Float(idxR)
                for idxTheta in 0...nPointsBaffleThickness{


                    let theta0: Float = Float(turbine.baffles.firstBaffleOffset) + deltaBaffleOffset * Float(nBaffle)

                    let theta = theta0 + (Float(idxTheta - nPointsBaffleThickness) / 2.0) * resolutionBaffleThickness / r




                    //                    let isSurface: Bool = idxTheta == 0 || idxTheta == nPointsBaffleThickness || idxR == 0 || idxR == nPointsR


                    //                    GeomData g
                    //                    g.resolution = resolution

                    let i = centerX + r * cos(theta)
                    let j = Float(y) + 0.5
                    let k = centerZ + r * sin(theta)

                    //                    g.is_solid = isSurface ? 0 : 1
                    pts.append(GeomPoints(i:tNi(i), j:tNi(j), k:tNi(k), kind: .FixedBoundary))

                    //Separates the int and decimal part of float.  int is used for calculation in Forcing
                    //                    UpdatePointFractions(g)



                    //                    if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
                    //
                    //                        //Fixed elements are referenced with node
                    //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds)
                    //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
                    //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds)
                    //
                    //                        if (get_solid && g.is_solid) result.push_back(g)
                    //                        if (get_solid == 0 && g.is_solid == 0) result.push_back(g)
                    //
                    //
                    //                    }
                }
            }
        }
    }

    return pts
}




func createImpellerBladesLegacy(turbine: RushtonTurbine, step: Int, wa: Float) -> [GeomPoints] {

    let centerX = Float(turbine.tankDiameter) / 2.0
    let centerZ = centerX

    let impellerNum = 0
    let impeller = turbine.impeller[impellerNum]!

    let innerRadius = Float(impeller.blades.innerRadius)
    let outerRadius = Float(impeller.blades.outerRadius)

    let resolution = Float(turbine.resolution)

    //    lowerLimitY = std::max(lowerLimitY, impellerTop)
    //    upperLimitY = std::min(upperLimitY, impellerBottom)



    let nPointsR = tNi(Float(outerRadius - innerRadius) / resolution)
    var nPointsThickness = tNi(Float(impeller.blades.thickness) / resolution)
    if nPointsThickness == 0 {nPointsThickness = 1}


    let resolutionBladeThickness: Float = Float(impeller.blades.thickness) / Float(nPointsThickness)

    let deltaR = (outerRadius - innerRadius) / Float(nPointsR)


    let deltaTheta: Float = 2.0 / Float(impeller.numBlades) * Float.pi



//    var currentWA = wa
//    if step < tankConfig.impeller_startup_steps_until_normal_speed {
//        currentWA = 0.5 * tankConfig.impeller[0]!.blade_tip_angular_vel_w0 * (1.0 - cos(Float.pi * Float(step) / Float(tankConfig.impeller_startup_steps_until_normal_speed)))
//    }



    var pts = [GeomPoints]()

    for nBlade in 1...impeller.numBlades {
        for y in impeller.blades.top...impeller.blades.bottom {
            for idxR in 0...nPointsR {

                let r: Float = innerRadius + deltaR * Float(idxR)

                for idxThickness in 0...nPointsThickness {

                    let offset: Float = deltaTheta * Float(nBlade) + Float(impeller.firstBladeOffset)

                    let theta = offset + (Float(idxThickness - nPointsThickness) / 2.0) * resolutionBladeThickness / r


                    let insideDisk: Bool = (Int(r) <= impeller.disk.radius) && (y >= impeller.disk.bottom) && (y <= impeller.disk.top)
                    if insideDisk {continue}

                    //                    bool isSurface = idxThickness == 0 || idxThickness == nPointsThickness || idxR == 0 || idxR == nPointsR || y == impellerBottom || y == impellerTop

                    //                    GeomData g
                    //                    g.resolution = resolution
                    //                    g.r_polar = r
                    //                    g.t_polar = theta

                    let i = centerX + r * cos(theta)
                    let j = y
                    let k = centerZ + r * sin(theta)


                    //                    g.u_delta_fp = -wa * g.r_polar * sinf(g.t_polar)
                    //                    g.v_delta_fp = 0.
                    //                    g.w_delta_fp = wa * g.r_polar * cosf(g.t_polar)

                    //                    g.is_solid = isSurface ? 0 : 1

                    pts.append(GeomPoints(i:tNi(i), j:tNi(j), k:tNi(k), kind: .MovingBoundary))

                    //Separates the int and decimal part of float.  int is used for calculation in Forcing
                    //                    UpdatePointFractions(g)



                    //                    if (grid_j_on_node(g.j_cart, node_bounds)){
                    //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
                    //
                    //
                    //                        //BOTH THE SOLID AND SURFACE ELEMENTS ARE ROTATING
                    //                        if (get_solid && g.is_solid) result.push_back(g)
                    //                        if (get_solid == 0 && g.is_solid == 0) result.push_back(g)
                    //                    }
                }
            }
        }
    }

    return pts
}



func createImpellerDiskLegacy(turbine: RushtonTurbine) -> [GeomPoints] {

    let centerX = Float(turbine.tankDiameter) / 2.0
    let centerZ = centerX


    let impellerNum = 0
    let impeller = turbine.impeller[impellerNum]!

//    let bottom: tNi = tNi(roundf(tankConfig.impeller[0]!.disk.bottom))
//    let top: tNi = tNi(roundf(tankConfig.impeller[0]!.disk.top))
    let hubRadius = Float(impeller.hub.radius)
    let diskRadius = Float(impeller.disk.radius)


    let nPointsR: tNi = tNi(round((diskRadius - hubRadius) / Float(turbine.resolution)))
    let deltaR: Float = (diskRadius - hubRadius) / Float(nPointsR)

//    lowerLimitY = std::max(lowerLimitY, top)
//    upperLimitY = std::min(upperLimitY, bottom)


    let resolution = Float(turbine.resolution)

    var pts = [GeomPoints]()

        for y in 0..<turbine.tankHeight {

//        for (tNi y = lowerLimitY y <= upperLimitY ++y) {

            for idxR in 1...nPointsR {

                let r:Float = Float(hubRadius) + Float(idxR) * deltaR
                var dTheta: Float = 0
                var nPointsTheta:tNi = tNi(2 * Float.pi * r / resolution)

                if nPointsTheta == 0 {
                    dTheta = 0
                    nPointsTheta = 1
                } else {
                    dTheta = 2.0 * Float.pi / Float(nPointsTheta)
                }

                var theta0: Float = Float(impeller.firstBladeOffset)
                if (idxR & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }
                if (y & 1) == 0 {
                    theta0 += 0.5 * dTheta
                }

                for idxTheta in 0...nPointsTheta - 1 {

//                    let isSurface:Bool = y == impeller.disk.bottom || y == impeller.disk.top || idxR == nPointsR


//                    let r_polar:Float = r
                    let t_polar:Float = theta0 + Float(idxTheta) * dTheta

                    let i = centerX + r * cos(t_polar)
                    let j = y
                    let k = centerZ + r * sin(t_polar)

//                    GeomData g
//                    g.r_polar = r
//                    g.t_polar = theta0 + idxTheta * dTheta
//                    g.resolution = resolution * resolution
//
//                    g.i_cart_fp = center.x + r * cos(g.t_polar)
//                    g.j_cart_fp = (Float)y - 0.5f
//                    g.k_cart_fp = center.z + r * sin(g.t_polar)
//
//                    g.u_delta_fp = -turbine.wa * g.r_polar * sinf(g.t_polar)
//                    g.v_delta_fp = 0
//                    g.w_delta_fp = turbine.wa * g.r_polar * cosf(g.t_polar)
//
//                    g.is_solid = isSurface ? 0 : 1
//
//
//                    Separates the int and decimal part of float.  int is used for calculation in Forcing
//                    UpdatePointFractions(g)


                    pts.append(GeomPoints(i:tNi(i), j:tNi(j), k:tNi(k), kind: .MovingBoundary))


//                    if (get_solid && g.is_solid) {
//                        if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
//
//                            //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
//                            //The Impeller Disc Solid elements are Fixed and referenced with node
//                            g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds)
//                            g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
//                            g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds)
//
//                            result.push_back(g)
//                        }
//                    }
//                    if (get_solid == 0 && g.is_solid == 0) {
//                        if (grid_j_on_node(g.j_cart, node_bounds)){
//                            g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
//                            result.push_back(g)
//                        }
//                    }


                }
            }
        }

    return pts
}


func createImpellerHubLegacy(turbine: RushtonTurbine) -> [GeomPoints] {


    let centerX = Float(turbine.tankDiameter) / 2.0
    let centerZ = centerX

    //
    //    tNi diskBottom = tNi(roundf(tankConfig.impeller0.disk.bottom))
    //    tNi diskTop = tNi(roundf(tankConfig.impeller0.disk.top))
    //
    //
    //
    //    tNi bottom = tNi(roundf(tankConfig.impeller0.hub.bottom))
    //    tNi top = tNi(roundf(tankConfig.impeller0.hub.top))
    //    Float hubRadius = tankConfig.impeller0.hub.radius
    //
    //    tNi nPointsR = tNi(roundf((hubRadius - tankConfig.shaft.radius) / resolution))
    //    Float resolutionR = (hubRadius - tankConfig.shaft.radius) / Float(nPointsR)
    //
    //    lowerLimitY = std::max(lowerLimitY, top)
    //    upperLimitY = std::min(upperLimitY, bottom)
    //
    var pts = [GeomPoints]()
    //    for (tNi y = lowerLimitY y <= upperLimitY ++y)
    //    {
    //        bool isWithinDisk = y >= diskBottom && y <= diskTop
    //
    //
    //        for (tNi idxR = 1 idxR <= nPointsR ++idxR)
    //        {
    //            Float r = tankConfig.shaft.radius + idxR * resolutionR
    //            tNi nPointsTheta = tNi(roundf(2 * M_PI * r / resolution))
    //            Float dTheta
    //            if(nPointsTheta == 0)
    //            {
    //                dTheta = 0
    //                nPointsTheta = 1
    //            }
    //            else
    //            dTheta = 2 * M_PI / nPointsTheta
    //
    //            Float theta0 = tankConfig.impeller0.firstBladeOffset
    //            if ((idxR & 1) == 0)
    //            theta0 += 0.5f * dTheta
    //            if ((y & 1) == 0)
    //            theta0 += 0.5f * dTheta
    //
    //            for (tNi idxTheta = 0 idxTheta <= nPointsTheta - 1 ++idxTheta)
    //            {
    //                bool isSurface = (y == bottom || y == top || idxR == nPointsR) && !isWithinDisk
    //
    //
    //                GeomData g
    //                g.r_polar = r
    //                g.t_polar = theta0 + idxTheta * dTheta
    //                g.resolution = resolution * resolution
    //
    //                g.i_cart_fp = center.x + r * cos(g.t_polar)
    //                g.j_cart_fp = (Float)y - 0.5f
    //                g.k_cart_fp = center.z + r * sin(g.t_polar)
    //
    //                g.u_delta_fp = -tankConfig.wa * g.r_polar * sinf(g.t_polar)
    //                g.v_delta_fp = 0
    //                g.w_delta_fp = tankConfig.wa * g.r_polar * cosf(g.t_polar)
    //                g.is_solid = isSurface ? 0 : 1
    //
    //
    //                //Separates the int and decimal part of float.  int is used for calculation in Forcing
    //                UpdatePointFractions(g)
    //    pts.append(GeomPoints(i:tNi(i), j:tNi(j), k:tNi(k)))

    //
    //
    //
    //
    //                if (get_solid && g.is_solid) {
    //                    if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
    //
    //                        //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
    //                        //The Impeller Disc Solid elements are Fixed and referenced with node
    //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds)
    //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
    //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds)
    //
    //                        result.push_back(g)
    //                    }
    //                }
    //                if (get_solid == 0 && g.is_solid == 0) {
    //                    if (grid_j_on_node(g.j_cart, node_bounds)){
    //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
    //                        result.push_back(g)
    //                    }
    //                }
    //
    //
    //
    //            }
    //        }
    //    }
    return pts
}



func createImpellerShaftLegacy(turbine: RushtonTurbine) -> [GeomPoints] {

    let centerX = Float(turbine.tankDiameter) / 2.0
    let centerZ = centerX
    let tankHeight = turbine.tankDiameter

    //    tNi hubBottom = tNi(roundf(tankConfig.impeller0.hub.bottom))
    //    tNi hubTop = tNi(roundf(tankConfig.impeller0.hub.top))
    //
    var pts = [GeomPoints]()
    //    for (tNi y = lowerLimitY y <= upperLimitY ++y)
    //    {
    //        bool isWithinHub = y >= hubBottom && y <= hubTop
    //
    //
    //        Float rEnd = tankConfig.shaft.radius // isWithinHub ? modelConfig.hub.radius : modelConfig.shaft.radius
    //        tNi nPointsR = roundf(rEnd / resolution)
    //
    //        for(tNi idxR = 0 idxR <= nPointsR ++idxR)
    //        {
    //            Float r, dTheta
    //            tNi nPointsTheta
    //            if(idxR == 0)
    //            {
    //                r = 0
    //                nPointsTheta = 1
    //                dTheta = 0
    //            }
    //            else
    //            {
    //                r = idxR * resolution
    //                nPointsTheta = 4 * tNi(roundf(M_PI * 2.0f * r / (4.0f * resolution)))
    //                if(nPointsTheta == 0)
    //                nPointsTheta = 1
    //                dTheta = 2 * M_PI / nPointsTheta
    //            }
    //
    //            for (tNi idxTheta = 0 idxTheta < nPointsTheta ++idxTheta)
    //            {
    //                Float theta = idxTheta * dTheta
    //                if ((y & 1) == 0)
    //                theta += 0.5f * dTheta
    //
    //                bool isSurface = idxR == nPointsR && !isWithinHub
    //                GeomData g
    //                g.r_polar = r
    //                g.t_polar = theta
    //                g.resolution = resolution
    //                g.i_cart_fp = center.x + r * cosf(theta)
    //                g.j_cart_fp = (Float)y- 0.5f
    //                g.k_cart_fp = center.z + r * sinf(theta)
    //
    //                g.u_delta_fp = -tankConfig.wa * g.r_polar * sinf(g.t_polar)
    //                g.v_delta_fp = 0.0f
    //                g.w_delta_fp =  tankConfig.wa * g.r_polar * cosf(g.t_polar)
    //                g.is_solid = isSurface ? 0 : 1
    //
    //
    //                //Separates the int and decimal part of float.  int is used for calculation in Forcing
    //                UpdatePointFractions(g)
    //    pts.append(GeomPoints(i:tNi(i), j:tNi(j), k:tNi(k)))

    //
    //
    //
    //
    //
    //                if (get_solid && g.is_solid) {
    //                    if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
    //
    //                        //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
    //                        //The Impeller Disc Solid elements are Fixed and referenced with node
    //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds)
    //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
    //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds)
    //
    //                        result.push_back(g)
    //                    }
    //                }
    //                if (get_solid == 0 && g.is_solid == 0) {
    //                    if (grid_j_on_node(g.j_cart, node_bounds)){
    //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds)
    //                        result.push_back(g)
    //                    }
    //                }
    //
    //
    //
    //            }
    //        }
    //    }
    //
    return pts
}





