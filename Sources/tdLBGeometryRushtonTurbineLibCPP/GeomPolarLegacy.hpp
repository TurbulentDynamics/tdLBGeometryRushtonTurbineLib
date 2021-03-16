//
//  GeomPolarLegacy.h
//  tdLBGeometryRushtonTurbineLib
//
//  Created by Niall Ó Broin on 13/02/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

#pragma once


#include <iostream>
#include <vector>
#include <map>
#include <fstream>
#include <algorithm>
#include <cmath>


#include "GlobalStructures.hpp"
#include "RushtonTurbine.hpp"


//tPrecision is some kind of Floating Point
template <typename T, typename tPrecision>
struct PosPolar
{
    
    //    tPrecision resolution = 0.0;
    //    tPrecision rPolar = 0.0;
    //    tPrecision tPolar = 0.0;
    
//    double iFP = 0.0;
//    double jFP = 0.0;
//    double kFP = 0.0;
    
    T i = 0;
    T j = 0;
    T k = 0;
    
    tPrecision i_cart_fraction = 0.0;
    tPrecision j_cart_fraction = 0.0;
    tPrecision k_cart_fraction = 0.0;
    
    tPrecision u_delta_fp = 0.0;
    tPrecision v_delta_fp = 0.0;
    tPrecision w_delta_fp = 0.0;
    
    
    bool is_solid = 0; //Either 0 surface, or 1 solid (the cells between the surface)
    
    
    PosPolar()
    {
        memset(this, 0, sizeof(PosPolar));
    }
    
    
    PosPolar(double iFP, int j, double kFP):j(j)
    {
        updateCoordinateFraction(iFP, &i, &i_cart_fraction);
        updateCoordinateFraction(kFP, &k, &k_cart_fraction);
    }
    
    
//    PosPolar(double iFP, long int j, double kFP)
//    {
//        updateCoordinateFraction(iFP, &i, &i_cart_fraction);
//        j = (T)j;
//        updateCoordinateFraction(kFP, &k, &k_cart_fraction);
//    }
    
    void localise(Extents<T> e){
        
        i -= e.x0;
        j -= e.y0;
        k -= e.z0;
    }
    
    
    
    void inline updateCoordinateFraction(double coordinate, T *integerPart, tPrecision *fractionPart)
    {
        //CART ALWAYS goes to +ve position.
        //TOFIX
        //coord 3.25 returns 4, -1.25
        //coord 3.75 returns 4, -0.75
        
        //coord -3.25 returns -3, -0.75
        //coord -3.75 returns -3, -1.25
        *integerPart = T(round(coordinate + 0.5));
        *fractionPart = (tPrecision)(coordinate - (T)(*integerPart) - 0.5);
    }
    
    

    
    
};







template <typename T, typename tPrecision>
class RushtonTurbinePolarCPP{
    
public:
    
    RushtonTurbine turbine;
    
    Extents<T> extents;
    
    
    
    std::vector<PosPolar<T, tPrecision>> geomFixed;
    
    //These are circular rotating points that would replace one another if "rotating."
    std::vector<PosPolar<T, tPrecision>> geomRotatingNonUpdating;
    
    //Points that move and need to be removed as they move.
    std::vector<PosPolar<T, tPrecision>> geomRotating;
    
    
    
    
    double iCenter;
    double kCenter;
    
    
    tStepRT startingStep = 0;
    tGeomShapeRT impellerStartAngle = 0.0;
    tStepRT impellerStartupStepsUntilNormalSpeed = 0;
    
    

    
    RushtonTurbinePolarCPP(RushtonTurbine t, Extents<T> e):turbine(t), extents(e){

        iCenter = turbine.tankDiameter / 2;
        kCenter = turbine.tankDiameter / 2;

        
    }
    
    
    void clear_vectors(){
        
        geomFixed.clear();
        geomRotatingNonUpdating.clear();
        geomRotating.clear();
    }
    
    
    std::vector<PosPolar<T, tPrecision>> returnFixedGeometry() {
        return geomFixed;
    }
    
    std::vector<PosPolar<T, tPrecision>> returnRotatingNonUpdatingGeometry() {
        return geomRotatingNonUpdating;
    }
    
    std::vector<PosPolar<T, tPrecision>> returnRotatingGeometry(double atTheta){
        return geomRotating;
    }
    
    
    
    
    
    
    void generateFixedGeometry() {
        
        addTankWall();
        addBaffles();
    }
    
    
    void generateRotatingNonUpdatingGeometry() {
        
        addImpellerShaft();
        addImpellerHub();
        addImpellerDisc();
        
    }
    
    
    void generateRotatingGeometry(double atTheta){
        
        addImpellerBlades(atTheta);
    }
    
    void updateRotatingGeometry(double atTheta){
        
        geomRotating.clear();
        addImpellerBlades(turbine, atTheta);
    }
    
    
    void generateTranslatingGeometry(int step){
    }
    
    void updateTranslatingGeometry(int step){
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    void addTankWall(bool get_solid = 0) {
        
        unsigned long int nCircPoints = 4 * (unsigned long int)(roundf(M_PI * turbine.tankDiameter / (4 * turbine.resolution)));
        double dTheta = 2.0f * M_PI / double(nCircPoints);
        double r = 0.5f * turbine.tankDiameter;
        
        for(int j = (int)extents.y0; j <= (int)extents.y1; ++j)
        {
            
            for (unsigned long int n = 0; n < nCircPoints; ++n)
            {
                
                double theta = double(n) * dTheta;
                if ((j & 1) == 1)
                    theta += 0.5f * dTheta;
                
                               
                //TODO, should the fractions be updated before center is added?????
                
                double iFP = iCenter + r * cos(theta);
                double kFP = kCenter + r * sin(theta);
                
                
                PosPolar<T, tPrecision> g = PosPolar<T, tPrecision>(iFP, j, kFP);
                
                if (extents.containsIK(g.i, g.k)){
                    
                    g.localise(extents);
                    
                    //                    std::cout <<g.iFP<<" "<<g.i << std::endl;
                    
                    geomFixed.push_back(g);
                    
                }
            }
        }
    }
    
    
    
    void addBaffles(bool get_solid = 0) {
        
        int nPointsBaffleThickness = int(roundf(turbine.baffles.thickness / turbine.resolution));
        if (nPointsBaffleThickness == 0)
            nPointsBaffleThickness = 1;
        
        double resolutionBaffleThickness = (double)(turbine.baffles.thickness) / (double)(nPointsBaffleThickness);
                
        double innerRadius = (double)turbine.baffles.innerRadius;
        double outerRadius = (double)turbine.baffles.outerRadius;
        int nPointsR = int(roundf((outerRadius - innerRadius) / turbine.resolution));
        
        double deltaR = (outerRadius - innerRadius) / static_cast<double>(nPointsR);
        
        double deltaBaffleOffset = 2.0/(double)turbine.baffles.numBaffles * M_PI;
        
        for (int nBaffle = 1; nBaffle <= turbine.baffles.numBaffles; ++nBaffle)
        {
            for (int j = (int)extents.y0; j <= (int)extents.y1; ++j)
            {
                for (T idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    double r = innerRadius + deltaR * (double)idxR;
                    
                    for (int idxTheta = 0; idxTheta <= nPointsBaffleThickness; ++idxTheta)
                    {
                        double theta = turbine.baffles.firstBaffleOffset +
                        deltaBaffleOffset * (double)nBaffle +
                        (idxTheta - nPointsBaffleThickness / 2.0f) * resolutionBaffleThickness / r;
                        
                        bool isSurface = idxTheta == 0 || idxTheta == nPointsBaffleThickness ||
                        idxR == 0 || idxR == nPointsR;
                        
                        
                        
                        double iFP = iCenter + r * cos(theta);
                        double kFP = kCenter + r * sin(theta);
                        
                        bool is_solid = isSurface ? 0 : 1;
                        
                        PosPolar<T, tPrecision> g = PosPolar<T, tPrecision>(iFP, j, kFP);

                        
                        if (extents.containsIK(g.i, g.k)){
                            
                            g.localise(extents);
                            
                            if (get_solid && is_solid) geomFixed.push_back(g);
                            if (get_solid == 0 && is_solid == 0) geomFixed.push_back(g);
                            
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    void addImpellerBlades(tStepRT step, bool get_solid = 0) {
        
        
        double innerRadius = turbine.impellers[0].blades.innerRadius;
        double outerRadius = turbine.impellers[0].blades.outerRadius;
        int diskBottom = int(roundf(turbine.impellers[0].disk.bottom));
        int diskTop = int(roundf(turbine.impellers[0].disk.top));
        int impellerBottom = int(roundf(turbine.impellers[0].blades.bottom));
        int impellerTop = int(roundf(turbine.impellers[0].blades.top));
        
        int lowerLimitY = std::max((int)extents.y0, impellerTop);
        int upperLimitY = std::min((int)extents.y1, impellerBottom);
        
        int nPointsR = int(roundf((outerRadius - innerRadius) / turbine.resolution));
        double nPointsThickness = int(roundf(turbine.impellers[0].blades.thickness / turbine.resolution));
        if (nPointsThickness == 0)
            nPointsThickness = 1;
        
        double resolutionBladeThickness = turbine.impellers[0].blades.thickness / (double)nPointsThickness;
        double deltaR = (outerRadius - innerRadius) / nPointsR;
        
        
        double deltaTheta = 2.0/(double)turbine.impellers[0].numBlades * M_PI;
        
        
        
        double wa = calcThisStepImpellerIncrement(step);
        
        
        for (int nBlade = 1; nBlade <= turbine.impellers[0].numBlades; ++nBlade)
        {
            for (int j = lowerLimitY; j <= upperLimitY; ++j)
            {
                for (int idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    double r = innerRadius  + deltaR * idxR;
                    for (int idxThickness = 0; idxThickness <= nPointsThickness; ++idxThickness)
                    {
                        double theta = deltaTheta * nBlade +
                        turbine.impellers[0].firstBladeOffset +
                        (idxThickness - nPointsThickness / 2.0f) * resolutionBladeThickness / r;
                        
                        bool insideDisc = (r <= turbine.impellers[0].disk.radius) && (j >= diskBottom) && (j <= diskTop);
                        if(insideDisc)
                            continue;
                        
                        bool isSurface = idxThickness == 0 || idxThickness == nPointsThickness ||
                        idxR == 0 || idxR == nPointsR ||
                        j == impellerBottom || j == impellerTop;
                        
                        double rPolar = r;
                        double tPolar = theta;
                        
                        double iFP = iCenter + r * cos(theta);
                        double kFP = kCenter + r * sin(theta);
                        
                        PosPolar<T, tPrecision> g = PosPolar<T, tPrecision>(iFP, j, kFP);

                        g.u_delta_fp = -wa * rPolar * sin(tPolar);
                        g.v_delta_fp = 0.0;
                        g.w_delta_fp = wa * rPolar * cos(tPolar);
                        
                        bool is_solid = isSurface ? 0 : 1;
                        
                        //TOFIX TODO BLADES ALL BLADES ARE PASSED ON
//                        if (extents.containsIK(g.i, g.k)){
                            
                           
                            g.localise(extents);
                            
                            //BOTH THE SOLID AND SURFACE ELEMENTS ARE ROTATING
                            if (get_solid && is_solid) geomRotating.push_back(g);
                            if (get_solid == 0 && is_solid == 0) geomRotating.push_back(g);
//                        }
  
                    }
                }
            }
        }
        
    }
    
    
    
    void addImpellerDisc(bool get_solid = 0){
        
        int bottom = int(roundf(turbine.impellers[0].disk.bottom));
        int top = int(roundf(turbine.impellers[0].disk.top));
        double hubRadius = turbine.impellers[0].hub.radius;
        double diskRadius = turbine.impellers[0].disk.radius;
        
        int nPointsR = int(round((diskRadius - hubRadius) / turbine.resolution));
        double deltaR = (diskRadius - hubRadius) / (double)(nPointsR);
        
        int lowerLimitY = std::max((int)extents.y0, top);
        int upperLimitY = std::min((int)extents.y1, bottom);
        
        for (int j = lowerLimitY; j <= upperLimitY; ++j)
        {
            for (int idxR = 1; idxR <= nPointsR; ++idxR)
            {
                double r = hubRadius + idxR * deltaR;
                double dTheta;
                int nPointsTheta = int(roundf(2 * M_PI * r / turbine.resolution));
                if(nPointsTheta == 0)
                {
                    dTheta = 0;
                    nPointsTheta = 1;
                }
                else
                    dTheta = 2 * M_PI / nPointsTheta;
                
                double theta0 = turbine.impellers[0].firstBladeOffset;
                if ((idxR & 1) == 0)
                    theta0 += 0.5f * dTheta;
                if ((j & 1) == 0)
                    theta0 += 0.5f * dTheta;
                
                for (int idxTheta = 0; idxTheta <= nPointsTheta - 1; ++idxTheta)
                {
                    bool isSurface = j == bottom || j == top || idxR == nPointsR;
                    
                    double rPolar = r;
                    double tPolar = theta0 + idxTheta * dTheta;
                    
                    double iFP = iCenter + r * cos(tPolar);
                    double kFP = kCenter + r * sin(tPolar);
                    
                    PosPolar<T, tPrecision> g = PosPolar<T, tPrecision>(iFP, j, kFP);

                    
                    g.u_delta_fp = -turbine.wa * rPolar * sin(tPolar);
                    g.v_delta_fp = 0;
                    g.w_delta_fp = turbine.wa * rPolar * cos(tPolar);
                    
                    bool is_solid = isSurface ? 0 : 1;
                    
                    
                    if (extents.containsIK(g.i, g.k)){
                        
                        g.localise(extents);
                        
                        if (get_solid && is_solid) geomRotating.push_back(g);
                        if (get_solid == 0 && is_solid == 0) geomRotating.push_back(g);
                        
                    }
                }
            }
        }
        
    }
    
    
    
    
    void addImpellerHub(bool get_solid = 0){
        
        int diskBottom = int(roundf(turbine.impellers[0].disk.bottom));
        int diskTop = int(roundf(turbine.impellers[0].disk.top));
        
        int bottom = int(roundf(turbine.impellers[0].hub.bottom));
        int top = int(roundf(turbine.impellers[0].hub.top));
        double hubRadius = turbine.impellers[0].hub.radius;
        
        int nPointsR = int(roundf((hubRadius - turbine.shaft.radius) / turbine.resolution));
        double resolutionR = (hubRadius - turbine.shaft.radius) / double(nPointsR);
        
        int lowerLimitY = std::max((int)extents.y0, top);
        int upperLimitY = std::min((int)extents.y1, bottom);
        
        for (int j = lowerLimitY; j <= upperLimitY; ++j)
        {
            bool isWithinDisc = j >= diskBottom && j <= diskTop;
            
            for (int idxR = 1; idxR <= nPointsR; ++idxR)
            {
                double r = turbine.shaft.radius + idxR * resolutionR;
                int nPointsTheta = int(roundf(2 * M_PI * r / turbine.resolution));
                double dTheta;
                if(nPointsTheta == 0)
                {
                    dTheta = 0;
                    nPointsTheta = 1;
                }
                else
                    dTheta = 2 * M_PI / nPointsTheta;
                
                double theta0 = turbine.impellers[0].firstBladeOffset;
                if ((idxR & 1) == 0)
                    theta0 += 0.5f * dTheta;
                if ((j & 1) == 0)
                    theta0 += 0.5f * dTheta;
                
                for (int idxTheta = 0; idxTheta <= nPointsTheta - 1; ++idxTheta)
                {
                    bool isSurface = (j == bottom || j == top || idxR == nPointsR) && !isWithinDisc;
                    
                    
                    double rPolar = r;
                    double tPolar = theta0 + idxTheta * dTheta;
                    //                    g.resolution = turbine.resolution * turbine.resolution;
                    
                    double iFP = iCenter + r * cos(tPolar);
                    double kFP = kCenter + r * sin(tPolar);
                    
                    PosPolar<T, tPrecision> g = PosPolar<T, tPrecision>(iFP, j, kFP);

                    g.u_delta_fp = -turbine.wa * rPolar * sin(tPolar);
                    g.v_delta_fp = 0;
                    g.w_delta_fp = turbine.wa * rPolar * cos(tPolar);
                    
                    bool is_solid = isSurface ? 0 : 1;
                    
                                        
                    if (extents.containsIK(g.i, g.k)){
                        
                        g.localise(extents);
                        
                        
                        if (get_solid && is_solid) geomRotating.push_back(g);
                        if (get_solid == 0 && is_solid == 0) geomRotating.push_back(g);
                        
                    }
                }
            }
        }
    }
    
    
    void addImpellerShaft(bool get_solid = 0){
        
        int hubBottom = int(roundf(turbine.impellers[0].hub.bottom));
        int hubTop = int(roundf(turbine.impellers[0].hub.top));
        
        for (int j = (int)extents.y0; j <= (int)extents.y1; ++j)
        {
            bool isWithinHub = j >= hubBottom && j <= hubTop;
            
            
            double rEnd = turbine.shaft.radius; // isWithinHub ? modelConfig.hub.radius : modelConfig.shaft.radius;
            int nPointsR = roundf(rEnd / turbine.resolution);
            
            for(int idxR = 0; idxR <= nPointsR; ++idxR)
            {
                double r, dTheta;
                int nPointsTheta;
                if(idxR == 0)
                {
                    r = 0;
                    nPointsTheta = 1;
                    dTheta = 0;
                }
                else
                {
                    r = idxR * turbine.resolution;
                    nPointsTheta = 4 * int(roundf(M_PI * 2.0f * r / (4.0f * turbine.resolution)));
                    if(nPointsTheta == 0)
                        nPointsTheta = 1;
                    dTheta = 2 * M_PI / nPointsTheta;
                }
                
                for (int idxTheta = 0; idxTheta < nPointsTheta; ++idxTheta)
                {
                    double theta = idxTheta * dTheta;
                    if ((j & 1) == 0)
                        theta += 0.5f * dTheta;
                    
                    bool isSurface = idxR == nPointsR && !isWithinHub;

                    double rPolar = r;
                    double tPolar = theta;
                    //                        g.resolution = turbine.resolution;

                    double iFP = iCenter + r * cos(theta);
                    double kFP = kCenter + r * sin(theta);
                    
                    PosPolar<T, tPrecision> g = PosPolar<T, tPrecision>(iFP, j, kFP);

                    
                    g.u_delta_fp = -turbine.wa * rPolar * sin(tPolar);
                    g.v_delta_fp = 0.0f;
                    g.w_delta_fp =  turbine.wa * rPolar * cos(tPolar);
                    
                    bool is_solid = isSurface ? 0 : 1;
                    
                    
                                    
                    if (extents.containsIK(g.i, g.k)){
                        
                        
                        g.localise(extents);
                        
                        if (get_solid && is_solid) geomRotating.push_back(g);
                        if (get_solid == 0 && is_solid == 0) geomRotating.push_back(g);
                        
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    tPrecision calcThisStepImpellerIncrement(tStepRT step)
    {
        
        double thisStepImpellerIncrementWA = turbine.impellers[0].bladeTipAngularVelW0;
        
        
        //slowly start the impeller
        if (step < impellerStartupStepsUntilNormalSpeed) {
            
            thisStepImpellerIncrementWA = 0.5 * turbine.impellers[0].bladeTipAngularVelW0 * (1.0 - cos(M_PI * (T)step / impellerStartupStepsUntilNormalSpeed));
            
        }
        return thisStepImpellerIncrementWA;
    }
    
    
    
    
    tPrecision updateRotatingGeometry(tStepRT step, tPrecision impellerTheta)
    {
        
        
        tPrecision thisStepImpellerIncrementWA = calcThisStepImpellerIncrement(step);
        
        impellerTheta += thisStepImpellerIncrementWA;
        
        
        
        
        
        //Only updates the rotating elements
        
#pragma omp parallel for
        for (int i = 0; i < geomRotating.size(); i++)
        {
            
            PosPolar<T, tPrecision> &g = geomRotating[i];
            
            g.tPolar += thisStepImpellerIncrementWA;
            
            
            
            g.iFP = iCenter + g.rPolar * cos(g.tPolar);
            g.kFP = kCenter + g.rPolar * sin(g.tPolar);
            
            g.u_delta_fp = -thisStepImpellerIncrementWA * g.rPolar * sin(g.tPolar);
            g.w_delta_fp =  thisStepImpellerIncrementWA * g.rPolar * cos(g.tPolar);
            
            UpdateCoordinateFraction(g.iFP, &g.i_cart, &g.i_cart_fraction);
            UpdateCoordinateFraction(g.kFP, &g.k_cart, &g.k_cart_fraction);
            
            
        }
        
        
        
        return impellerTheta;
    }
    
    
    
    
    
    
};//end of class
