//
//  GeomPolarLegacy.h
//  tdLBGeometryRushtonTurbineLib
//
//  Created by Niall Ó Broin on 13/02/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

#pragma once


//#include <stdio.h>
#include <stdlib.h>

#include <vector>
//#include <fstream>
//#include <sstream>
#include <iostream>


#include "../../tdLBCppApi/include/GlobalStructures.hpp"
#include "RushtonTurbine.hpp"


template <typename T>
struct GeomData
{
    T resolution = 0.0;
    T r_polar = 0.0;
    T t_polar = 0.0;
    
    T i_cart_fp = 0.0;
    T j_cart_fp = 0.0;
    T k_cart_fp = 0.0;
    
    //Used in forcing
    T u_delta_fp = 0.0;
    T v_delta_fp = 0.0;
    T w_delta_fp = 0.0;
    
    
    T i_cart_fraction = 0.0;
    T j_cart_fraction = 0.0;
    T k_cart_fraction = 0.0;
    
    
    tNi i_cart = 0;
    tNi j_cart = 0;
    tNi k_cart = 0;
    
    
    bool is_solid = 0; //Either 0 surface, or 1 solid (the cells between the surface)
    
    
    
    GeomData()
    {
        memset(this, 0, sizeof(GeomData));
    }
    
};







template <typename T>
class RushtonTurbinePolarCPP{
    
    
private:
    RushtonTurbine tankConfig;
    
    GridParams grid;
    
    T calc_this_step_impeller_increment(tStepRT step);
    
    Extents<T> extents;
    
    Pos3d center;
    
    
public:
    
    std::vector<GeomData> geomFixed;
    
    //These are circular rotating points that would replace one another if "rotating."
    std::vector<Pos3d<T>> geomRotatingNonUpdating;
    
    //Points that move and need to be removed as they move.
    std::vector<Pos3d<T>> geomRotating;
    
    
    std::vector<Pos3d<T>> returnFixedGeometry() {
        return geomFixed;
    }

    std::vector<Pos3d<T>> returnRotatingNonUpdatingGeometry() {
        return geomRotatingNonUpdating;
    }
    
    std::vector<Pos3d<T>> returnRotatingGeometry(double atTheta){
        return geomRotating;
    }

    std::vector<Pos3d<T>> returnTranslatingGeometry(int step){
        return geomTranslating;
    }
    
    
    
    
    
    void generateFixedGeometry() {
        
        addTankWall();
        addBaffles(turbine);
    }


    void generateRotatingNonUpdatingGeometry() {
        
        addImpellerShaft();
        addImpelerHub();
        addImpellerDisc();
        
    }
    
    
    void generateRotatingGeometry(double atTheta){
        
        addImpellerBlades(atTheta);
    }
    
    void updateRotatingGeometry(double atTheta){
        
        geomRotating.clear();
        addImpellerBlades(atTheta);
    }

    
    void generateTranslatingGeometry(int step){
    }
    
    void updateTranslatingGeometry(int step){
    }
    
    
    
    
    
    
    
    
    
    
    void clear_vectors(){

        geomFixed.clear();
        geomRotatingNonUpdating.clear();
        geomRotating.clear();
        geomTranslating.clear();
    }
    

    
    
    void inline UpdateCoordinateFraction(T coordinate, tNi *integerPart, T *fractionPart)
    {
        //CART ALWAYS goes to +ve position.
        //TOFIX
        //coord 3.25 returns 4, -1.25
        //coord 3.75 returns 4, -0.75
        
        //coord -3.25 returns -3, -0.75
        //coord -3.75 returns -3, -1.25
        *integerPart = tNi(roundf(coordinate + 0.5f));
        *fractionPart = coordinate - (T)(*integerPart) - 0.5f;
    }
    
    
    
    void inline UpdatePointFractions(GeomData &point)
    {
        UpdateCoordinateFraction(point.i_cart_fp, &point.i_cart, &point.i_cart_fraction);
        UpdateCoordinateFraction(point.j_cart_fp, &point.j_cart, &point.j_cart_fraction);
        UpdateCoordinateFraction(point.k_cart_fp, &point.k_cart, &point.k_cart_fraction);
    }
    
    
    
    
    
    
    
    addTankWall(bool get_solid = 0)
    {
        tNi nCircPoints = 4 * tNi(roundf(M_PI * tankConfig.tankDiameter / (4 * tankConfig.resolution)));
        T dTheta = 2.0f * M_PI / T(nCircPoints);
        T r = 0.5f * tankConfig.tankDiameter;
        
        for(tNi y = extents.j0; y <= extents.j1; ++y)
        {
            for (tNi k = 0; k < nCircPoints; ++k)
            {
                T theta = T(k) * dTheta;
                if ((y & 1) == 1)
                    theta += 0.5f * dTheta;
                
                
                GeomData g;
                g.resolution = tankConfig.resolution;
                g.i_cart_fp = center.x + r * cosf(theta);
                //            g.i_cart_fp = r * cosf(theta);
                g.j_cart_fp = (T)y + 0.5f;
                g.k_cart_fp = center.z + r * sinf(theta);
                //            g.k_cart_fp = r * sinf(theta);
                g.is_solid = 0;
                
                //Separates the int and decimal part of float.  int is used for calculation in Forcing
                UpdatePointFractions(g);
                
                //            g.i_cart += center.x
                //            g.k_cart += center.z
                
                
                if (extents.containsIK(g.i_cart, g.k_cart)){
                    
                    //                g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds);
                    //                g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                    //                g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds);
                    
                    if (get_solid && g.is_solid) geomFixed.push_back(g);
                    if (get_solid == 0 && g.is_solid == 0) geomFixed.push_back(g);
                    
                    
                }
                
            }
            
        }
        
    }
    
    
    
    addBaffles(bool get_solid = 0)
    {
        tNi nPointsBaffleThickness = tNi(roundf(tankConfig.baffles.thickness / tankConfig.resolution));
        if (nPointsBaffleThickness == 0)
            nPointsBaffleThickness = 1;
        
        T resolutionBaffleThickness = tankConfig.baffles.thickness / T(nPointsBaffleThickness);
        T innerRadius = tankConfig.baffles.innerRadius;
        T outerRadius = tankConfig.baffles.outerRadius;
        tNi nPointsR = tNi(roundf((outerRadius - innerRadius) / tankConfig.resolution));
        
        double deltaR = (outerRadius - innerRadius) / static_cast<T>(nPointsR);
        
        double deltaBaffleOffset = 2.0/(double)tankConfig.baffles.numBaffles * M_PI;
        
        for (tNi nBaffle = 1; nBaffle <= (tNi)tankConfig.baffles.numBaffles; ++nBaffle)
        {
            for (tNi y = extents.j0; y <= extents.j1; ++y)
            {
                for (tNi idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    T r = innerRadius + deltaR * idxR;
                    for (tNi idxTheta = 0; idxTheta <= nPointsBaffleThickness; ++idxTheta)
                    {
                        T theta = tankConfig.baffles.firstBaffleOffset +
                        deltaBaffleOffset * nBaffle +
                        (idxTheta - nPointsBaffleThickness / 2.0f) * resolutionBaffleThickness / r;
                        
                        bool isSurface = idxTheta == 0 || idxTheta == nPointsBaffleThickness ||
                        idxR == 0 || idxR == nPointsR;
                        
                        
                        GeomData g;
                        g.resolution = tankConfig.resolution;
                        
                        g.i_cart_fp = center.x + r * cosf(theta);
                        g.j_cart_fp = (T)y + 0.5f;
                        g.k_cart_fp = center.z + r * sinf(theta);
                        
                        g.is_solid = isSurface ? 0 : 1;
                        
                        //Separates the int and decimal part of float.  int is used for calculation in Forcing
                        UpdatePointFractions(g);
                        
                        
                        
                        if (extents.containsIK(g.i_cart, g.k_cart)){
                            
                            //Fixed elements are referenced with node
                            //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds);
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds);
                            
                            if (get_solid && g.is_solid) geomFixed.push_back(g);
                            if (get_solid == 0 && g.is_solid == 0) geomFixed.push_back(g);
                            
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    addImpellerBlades(tStepRT step, bool get_solid = 0)
    {
        double innerRadius = tankConfig.impeller0.blades.innerRadius;
        double outerRadius = tankConfig.impeller0.blades.outerRadius;
        tNi discBottom = tNi(roundf(tankConfig.impeller0.disk.bottom));
        tNi discTop = tNi(roundf(tankConfig.impeller0.disk.top));
        tNi impellerBottom = tNi(roundf(tankConfig.impeller0.blades.bottom));
        tNi impellerTop = tNi(roundf(tankConfig.impeller0.blades.top));
        
        tNi lowerLimitY = std::max(extents.j0, impellerTop);
        tNi upperLimitY = std::min(extents.j1, impellerBottom);
        
        T nPointsR = tNi(roundf((outerRadius - innerRadius) / tankConfig.resolution));
        T nPointsThickness = tNi(roundf(tankConfig.impeller0.blades.bladeThickness / tankConfig.resolution));
        if (nPointsThickness == 0)
            nPointsThickness = 1;
        
        T resolutionBladeThickness = tankConfig.impeller0.blades.bladeThickness / T(nPointsThickness);
        double deltaR = (outerRadius - innerRadius) / nPointsR;
        
        
        double deltaTheta = 2.0/(double)tankConfig.impeller0.numBlades * M_PI;
        
        
        
        T wa;
        if (step < tankConfig.impeller_startup_steps_until_normal_speed)
            wa = 0.5f * tankConfig.impeller0.blade_tip_angular_vel_w0 * (1.0f - cosf(M_PI * (step) / ((float)tankConfig.impeller_startup_steps_until_normal_speed)));
        else
            wa = tankConfig.wa;
        
        
        
        for (tNi nBlade = 1; nBlade <= tankConfig.impeller0.numBlades; ++nBlade)
        {
            for (tNi y = lowerLimitY; y <= upperLimitY; ++y)
            {
                for (tNi idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    T r = innerRadius  + deltaR * idxR;
                    for (tNi idxThickness = 0; idxThickness <= nPointsThickness; ++idxThickness)
                    {
                        T theta = deltaTheta * nBlade +
                        tankConfig.impeller0.firstBladeOffset +
                        (idxThickness - nPointsThickness / 2.0f) * resolutionBladeThickness / r;
                        
                        bool insideDisc = (r <= tankConfig.impeller0.disk.radius) && (y >= discBottom) && (y <= discTop);
                        if(insideDisc)
                            continue;
                        
                        bool isSurface = idxThickness == 0 || idxThickness == nPointsThickness ||
                        idxR == 0 || idxR == nPointsR ||
                        y == impellerBottom || y == impellerTop;
                        
                        GeomData g;
                        g.resolution = tankConfig.resolution;
                        g.r_polar = r;
                        g.t_polar = theta;
                        g.i_cart_fp = center.x + r * cosf(theta);
                        g.j_cart_fp = (T)y - 0.5f;
                        g.k_cart_fp = center.z + r * sinf(theta);
                        
                        g.u_delta_fp = -wa * g.r_polar * sinf(g.t_polar);
                        g.v_delta_fp = 0.;
                        g.w_delta_fp = wa * g.r_polar * cosf(g.t_polar);
                        
                        g.is_solid = isSurface ? 0 : 1;
                        
                        
                        
                        //Separates the int and decimal part of float.  int is used for calculation in Forcing
                        UpdatePointFractions(g);
                        
                        
                        if (extents.containsJ(g.j_cart)){
                            
                            //                    if (grid_j_on_node(g.j_cart, node_bounds)){
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            
                            
                            //BOTH THE SOLID AND SURFACE ELEMENTS ARE ROTATING
                            if (get_solid && g.is_solid) geomRotating.push_back(g);
                            if (get_solid == 0 && g.is_solid == 0) geomRotating.push_back(g);
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    addImpellerDisk(bool get_solid = 0)
    {
        tNi bottom = tNi(roundf(tankConfig.impeller0.disk.bottom));
        tNi top = tNi(roundf(tankConfig.impeller0.disk.top));
        T hubRadius = tankConfig.impeller0.hub.radius;
        T diskRadius = tankConfig.impeller0.disk.radius;
        
        tNi nPointsR = tNi(round((diskRadius - hubRadius) / tankConfig.resolution));
        T deltaR = (diskRadius - hubRadius) / T(nPointsR);
        
        lowerLimitY = std::max(extents.j0, top);
        upperLimitY = std::min(extents.j1, bottom);
        
        for (tNi y = lowerLimitY; y <= upperLimitY; ++y)
        {
            for (tNi idxR = 1; idxR <= nPointsR; ++idxR)
            {
                T r = hubRadius + idxR * deltaR;
                T dTheta;
                tNi nPointsTheta = tNi(roundf(2 * M_PI * r / tankConfig.resolution));
                if(nPointsTheta == 0)
                {
                    dTheta = 0;
                    nPointsTheta = 1;
                }
                else
                    dTheta = 2 * M_PI / nPointsTheta;
                
                T theta0 = tankConfig.impeller0.firstBladeOffset;
                if ((idxR & 1) == 0)
                    theta0 += 0.5f * dTheta;
                if ((y & 1) == 0)
                    theta0 += 0.5f * dTheta;
                
                for (tNi idxTheta = 0; idxTheta <= nPointsTheta - 1; ++idxTheta)
                {
                    bool isSurface = y == bottom || y == top || idxR == nPointsR;
                    
                    GeomData g;
                    g.r_polar = r;
                    g.t_polar = theta0 + idxTheta * dTheta;
                    g.resolution = tankConfig.resolution * tankConfig.resolution;
                    
                    g.i_cart_fp = center.x + r * cos(g.t_polar);
                    g.j_cart_fp = (T)y - 0.5f;
                    g.k_cart_fp = center.z + r * sin(g.t_polar);
                    
                    g.u_delta_fp = -tankConfig.wa * g.r_polar * sinf(g.t_polar);
                    g.v_delta_fp = 0;
                    g.w_delta_fp = tankConfig.wa * g.r_polar * cosf(g.t_polar);
                    
                    g.is_solid = isSurface ? 0 : 1;
                    
                    
                    //Separates the int and decimal part of float.  int is used for calculation in Forcing
                    UpdatePointFractions(g);
                    
                    
                    
                    
                    if (get_solid && g.is_solid) {
                        if (extents.containsIJK(g.i_cart, g.j_cart, g.k_cart)){
                            //                    if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
                            
                            //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
                            //The Impeller Disc Solid elements are Fixed and referenced with node
                            //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds);
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds);
                            
                            geomRotatingNonUpdating.push_back(g);
                        }
                    }
                    if (get_solid == 0 && g.is_solid == 0) {
                        if (extents.containsJ(g.j_cart)){
                            //                    if (grid_j_on_node(g.j_cart, node_bounds)){
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            geomRotatingNonUpdating.push_back(g);
                        }
                    }
                    
                    
                }
            }
        }
        
    }
    
    
    
    
    addImpellerHub(bool get_solid = 0)
    {
        
        tNi diskBottom = tNi(roundf(tankConfig.impeller0.disk.bottom));
        tNi diskTop = tNi(roundf(tankConfig.impeller0.disk.top));
        
        
        
        tNi bottom = tNi(roundf(tankConfig.impeller0.hub.bottom));
        tNi top = tNi(roundf(tankConfig.impeller0.hub.top));
        T hubRadius = tankConfig.impeller0.hub.radius;
        
        tNi nPointsR = tNi(roundf((hubRadius - tankConfig.shaft.radius) / tankConfig.resolution));
        T resolutionR = (hubRadius - tankConfig.shaft.radius) / T(nPointsR);
        
        lowerLimitY = std::max(extents.j0, top);
        upperLimitY = std::min(extents.j1, bottom);
        
        for (tNi y = lowerLimitY; y <= upperLimitY; ++y)
        {
            bool isWithinDisk = y >= diskBottom && y <= diskTop;
            
            
            for (tNi idxR = 1; idxR <= nPointsR; ++idxR)
            {
                T r = tankConfig.shaft.radius + idxR * resolutionR;
                tNi nPointsTheta = tNi(roundf(2 * M_PI * r / tankConfig.resolution));
                T dTheta;
                if(nPointsTheta == 0)
                {
                    dTheta = 0;
                    nPointsTheta = 1;
                }
                else
                    dTheta = 2 * M_PI / nPointsTheta;
                
                T theta0 = tankConfig.impeller0.firstBladeOffset;
                if ((idxR & 1) == 0)
                    theta0 += 0.5f * dTheta;
                if ((y & 1) == 0)
                    theta0 += 0.5f * dTheta;
                
                for (tNi idxTheta = 0; idxTheta <= nPointsTheta - 1; ++idxTheta)
                {
                    bool isSurface = (y == bottom || y == top || idxR == nPointsR) && !isWithinDisk;
                    
                    
                    GeomData g;
                    g.r_polar = r;
                    g.t_polar = theta0 + idxTheta * dTheta;
                    g.resolution = tankConfig.resolution * tankConfig.resolution;
                    
                    g.i_cart_fp = center.x + r * cos(g.t_polar);
                    g.j_cart_fp = (T)y - 0.5f;
                    g.k_cart_fp = center.z + r * sin(g.t_polar);
                    
                    g.u_delta_fp = -tankConfig.wa * g.r_polar * sinf(g.t_polar);
                    g.v_delta_fp = 0;
                    g.w_delta_fp = tankConfig.wa * g.r_polar * cosf(g.t_polar);
                    g.is_solid = isSurface ? 0 : 1;
                    
                    
                    //Separates the int and decimal part of float.  int is used for calculation in Forcing
                    UpdatePointFractions(g);
                    
                    
                    
                    
                    if (get_solid && g.is_solid) {
                        if (extents.containsIJK(g.i_cart, g.j_cart, g.k_cart)){
                            //                        if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
                            
                            //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
                            //The Impeller Disc Solid elements are Fixed and referenced with node
                            //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds);
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds);
                            
                            geomRotatingNonUpdating.push_back(g);
                        }
                    }
                    if (get_solid == 0 && g.is_solid == 0) {
                        if (extents.containsJ(g.j_cart)){
                            //                    if (grid_j_on_node(g.j_cart, node_bounds)){
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            geomRotatingNonUpdating.push_back(g);
                        }
                    }
                    
                    
                    
                }
            }
        }
    }
    
    
    
    addImpellerShaft(bool get_solid = 0)
    {
        tNi hubBottom = tNi(roundf(tankConfig.impeller0.hub.bottom));
        tNi hubTop = tNi(roundf(tankConfig.impeller0.hub.top));
        
        for (tNi y = entents.j0; y <= entents.j1; ++y)
        {
            bool isWithinHub = y >= hubBottom && y <= hubTop;
            
            
            T rEnd = tankConfig.shaft.radius; // isWithinHub ? modelConfig.hub.radius : modelConfig.shaft.radius;
            tNi nPointsR = roundf(rEnd / tankConfig.resolution);
            
            for(tNi idxR = 0; idxR <= nPointsR; ++idxR)
            {
                double r, dTheta;
                tNi nPointsTheta;
                if(idxR == 0)
                {
                    r = 0;
                    nPointsTheta = 1;
                    dTheta = 0;
                }
                else
                {
                    r = idxR * tankConfig.resolution;
                    nPointsTheta = 4 * tNi(roundf(M_PI * 2.0f * r / (4.0f * tankConfig.resolution)));
                    if(nPointsTheta == 0)
                        nPointsTheta = 1;
                    dTheta = 2 * M_PI / nPointsTheta;
                }
                
                for (tNi idxTheta = 0; idxTheta < nPointsTheta; ++idxTheta)
                {
                    T theta = idxTheta * dTheta;
                    if ((y & 1) == 0)
                        theta += 0.5f * dTheta;
                    
                    bool isSurface = idxR == nPointsR && !isWithinHub;
                    GeomData g;
                    g.r_polar = r;
                    g.t_polar = theta;
                    g.resolution = tankConfig.resolution;
                    g.i_cart_fp = center.x + r * cosf(theta);
                    g.j_cart_fp = (T)y- 0.5f;
                    g.k_cart_fp = center.z + r * sinf(theta);
                    
                    g.u_delta_fp = -tankConfig.wa * g.r_polar * sinf(g.t_polar);
                    g.v_delta_fp = 0.0f;
                    g.w_delta_fp =  tankConfig.wa * g.r_polar * cosf(g.t_polar);
                    g.is_solid = isSurface ? 0 : 1;
                    
                    
                    //Separates the int and decimal part of float.  int is used for calculation in Forcing
                    UpdatePointFractions(g);
                    
                    
                    
                    
                    
                    if (get_solid && g.is_solid) {
                        if (extents.containsIJK(g.i_cart, g.j_cart, g.k_cart)){
                            //                    if (grid_ijk_on_node(g.i_cart, g.j_cart, g.k_cart, node_bounds)){
                            
                            //THE SHAFT SOLID ELEMENTS NEED NOT BE ROTATED
                            //The Impeller Disc Solid elements are Fixed and referenced with node
                            //                        g.i_cart = convert_i_grid_to_i_node(g.i_cart, node, node_bounds);
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            //                        g.k_cart = convert_k_grid_to_k_node(g.k_cart, node, node_bounds);
                            
                            geomRotatingNonUpdating.push_back(g);
                        }
                    }
                    if (get_solid == 0 && g.is_solid == 0) {
                        if (extents.containsJ(g.j_cart)){
                            //                    if (grid_j_on_node(g.j_cart, node_bounds)){
                            //                        g.j_cart = convert_j_grid_to_j_node(g.j_cart, node, node_bounds);
                            geomRotatingNonUpdating.push_back(g);
                        }
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    
    
    
    
    
    T Init_at_angle(T angle, tStepRT step, Grid_Dims grid, Node_Dims node, GeometryConfig tankConfig)
    {
        
        Init(grid, node, tankConfig);
        
        T this_step_impeller_increment_wa = calc_this_step_impeller_increment(step);
        
        
#pragma omp parallel for
        for (tNi i = 0; i < geom_rotating_surface_and_internal_blades.size(); i++)
        {
            
            GeomData &g = geom_rotating_surface_and_internal_blades[i];
            
            g.t_polar += angle;
            
            
            
            g.i_cart_fp = center.x + g.r_polar * cosf(g.t_polar);
            g.k_cart_fp = center.z + g.r_polar * sinf(g.t_polar);
            
            g.u_delta_fp = -this_step_impeller_increment_wa * g.r_polar * sinf(g.t_polar);
            g.w_delta_fp =  this_step_impeller_increment_wa * g.r_polar * cosf(g.t_polar);
            
            UpdateCoordinateFraction(g.i_cart_fp, &g.i_cart, &g.i_cart_fraction);
            UpdateCoordinateFraction(g.k_cart_fp, &g.k_cart, &g.k_cart_fraction);
            
            
        }
        return angle;
        
    }
    
    
    
    
//    void Init(Grid_Dims _grids, GeometryConfig _tankConfig)
//    {
//        geom_fixed_surface.clear();
//        geom_rotating_surface_and_internal_blades.clear();
//
//        geom_fixed_internal.clear();
//        //    geom_rotating_static_internal.clear();
//
//
//        grid = _grid;
//        node = _node;
//        tankConfig = _tankConfig;
//
//        node_bounds = get_node_bounds(node, grid);
//
//        tNi lowerLimitY = node_bounds.j0;
//        tNi upperLimitY = node_bounds.j1;
//
//        if (node.idj == 0) lowerLimitY = 1;
//        if (node.idj == grid.ngy - 1) upperLimitY -= 1;
//
//
//        center.x = T(grid.x - MDIAM_BORDER) / 2.0f; //center x direction
//        center.y = tankConfig.impeller0.impeller_position; //position of impeller, from the top
//        center.z = T(grid.z - MDIAM_BORDER) / 2.0f; //center z direction
//
//
//
//
//        //Solid are the internal points, while above is only the surface rotating
//        bool get_solid = 1;
//
//
//
//
//        // Tank wall
//        std::vector<GeomData> wallGeometry = CreateTankWall(lowerLimitY, upperLimitY);
//        geomFixed.insert(geomFixed.end(), wallGeometry.begin(), wallGeometry.end());
//
//
//
//
//        // baffles
//        std::vector<GeomData> bafflesGeometry = CreateBaffles(lowerLimitY, upperLimitY);
//        geomFixed.insert(geomFixed.end(), bafflesGeometry.begin(), bafflesGeometry.end());
//
////        std::vector<GeomData> bafflesGeometry_solid = CreateBaffles(lowerLimitY, upperLimitY, get_solid);
////        geom_fixed_internal.insert(geom_fixed_internal.end(), bafflesGeometry_solid.begin(), bafflesGeometry_solid.end());
//
//
//
//
//
//
//
//
//        // impeller blades, both surface and internal elements are rotated
//        std::vector<GeomData> impellerBladesGeometry = CreateImpellerBlades(tankConfig.starting_step);
//        geomRotating.insert(geomRotating.end(), impellerBladesGeometry.begin(), impellerBladesGeometry.end());
//
//
////        std::vector<GeomData> impellerBladesGeometry_solid = CreateImpellerBlades(tankConfig.starting_step, lowerLimitY, upperLimitY, get_solid);
////        geom_rotating_surface_and_internal_blades.insert(geom_rotating_surface_and_internal_blades.end(), impellerBladesGeometry_solid.begin(), impellerBladesGeometry_solid.end());
//
//
//
//
//
//
//        //impeller disk
//        std::vector<GeomData> impellerDiskGeometry = CreateImpellerDisk();
//        geomRotatingNonUpdating.insert(geomRotatingNonUpdating.end(), impellerDiskGeometry.begin(), impellerDiskGeometry.end());
//
////        std::vector<GeomData> impellerDiskGeometry_solid = CreateImpellerDisk(lowerLimitY, upperLimitY, get_solid);
////        geom_fixed_internal.insert(geom_fixed_internal.end(), impellerDiskGeometry_solid.begin(), impellerDiskGeometry_solid.end());
//
//
//
//        //hub
//        std::vector<GeomData> hubGeometry = CreateImpellerHub();
//        geomRotatingNonUpdating.insert(geomRotatingNonUpdating.end(), hubGeometry.begin(), hubGeometry.end());
//
//
////        std::vector<GeomData> hubGeometry_solid = CreateImpellerHub(lowerLimitY, upperLimitY, get_solid);
////        geom_fixed_internal.insert(geom_fixed_internal.end(), hubGeometry_solid.begin(), hubGeometry_solid.end());
//
//
//
//
//        //impeller shaft
//        std::vector<GeomData> impellerShaftGeometry = CreateImpellerShaft();
//
//        geomRotatingNonUpdating.insert(geomRotatingNonUpdating.end(), impellerShaftGeometry.begin(), impellerShaftGeometry.end());
//
//
//
//
////
////        std::vector<GeomData> impellerShaftGeometry_solid = CreateImpellerShaft(lowerLimitY, upperLimitY, get_solid);
////        geom_fixed_internal.insert(geom_fixed_internal.end(), impellerShaftGeometry_solid.begin(), impellerShaftGeometry_solid.end());
//
//
//    }
//
    
    
    
    
    
    T calc_this_step_impeller_increment(tStepRT step)
    {
        
        T this_step_impeller_increment_wa = tankConfig.impeller0.blade_tip_angular_vel_w0;
        
        
        //slowly start the impeller
        if (step < tankConfig.impeller_startup_steps_until_normal_speed) {
            
            this_step_impeller_increment_wa = 0.5 * tankConfig.impeller0.blade_tip_angular_vel_w0 * (1.0 - cosf(M_PI * (T)step / ((T)tankConfig.impeller_startup_steps_until_normal_speed)));
            
        }
        return this_step_impeller_increment_wa;
    }
    
    
    
    
    T updateRotatingGeometry(tStepRT step, T impellerTheta)
    {
        
        
        T this_step_impeller_increment_wa = calc_this_step_impeller_increment(step);
        
        impellerTheta += this_step_impeller_increment_wa;
        
        
        
        
        
        //Only updates the rotating elements
        
#pragma omp parallel for
        for (int i = 0; i < geomRotating.size(); i++)
        {
            
            GeomData &g = geomRotating[i];
            
            g.t_polar += this_step_impeller_increment_wa;
            
            
            
            g.i_cart_fp = center.x + g.r_polar * cosf(g.t_polar);
            g.k_cart_fp = center.z + g.r_polar * sinf(g.t_polar);
            
            g.u_delta_fp = -this_step_impeller_increment_wa * g.r_polar * sinf(g.t_polar);
            g.w_delta_fp =  this_step_impeller_increment_wa * g.r_polar * cosf(g.t_polar);
            
            UpdateCoordinateFraction(g.i_cart_fp, &g.i_cart, &g.i_cart_fraction);
            UpdateCoordinateFraction(g.k_cart_fp, &g.k_cart, &g.k_cart_fraction);
            
            
        }
        
        
        
        return impellerTheta;
    }
    
    
    
    
    
    
    
    
    Geom_Dims get_geom_dims(){
        
        Geom_Dims gdata;
        gdata.xc = center.x;
        gdata.yc = center.y;
        gdata.zc = center.z;
        
        
        gdata.mdiam = tankConfig.tankDiameter;
        
        gdata.impeller_increment = tankConfig.impeller0.blade_tip_angular_vel_w0;
        
        return gdata;
    }
    
    
    
    
}//end of class
