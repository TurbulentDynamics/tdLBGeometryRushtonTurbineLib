//
//  GeomPolar.h
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


//TQ is some kind of Floating Point
template <typename T, typename TQ>
struct PosPolar
{
    
//    TQ resolution = 0.0;
//    TQ rPolar = 0.0;
//    TQ tPolar = 0.0;
//
//    TQ iFP = 0.0;
//    TQ jFP = 0.0;
//    TQ kFP = 0.0;
    
    T i = 0;
    T j = 0;
    T k = 0;
    
    TQ iCartFraction = 0.0;
    TQ jCartFraction = 0.0;
    TQ kCartFraction = 0.0;
    
    TQ uDelta = 0.0;
    TQ vDelta = 0.0;
    TQ wDelta = 0.0;
    
    
    bool isInternal = 0; //Either 0 surface, or 1 solid (the cells between the surface)
    
    
    PosPolar()
    {
        memset(this, 0, sizeof(PosPolar));
    }
    
    
    PosPolar(TQ iFP, T j, TQ kFP):j(j)
    {
        updateCoordinateFraction(iFP, &i, &iCartFraction);
        updateCoordinateFraction(kFP, &k, &kCartFraction);
    }
    
    
//    PosPolar(double iFP, long int j, double kFP)
//    {
//        updateCoordinateFraction(iFP, &i, &iCartFraction);
//        j = (T)j;
//        updateCoordinateFraction(kFP, &k, &kCartFraction);
//    }
    
    void localise(Extents<T> e){
        
        i -= e.x0;
        j -= e.y0;
        k -= e.z0;
    }
    
    
    
    void inline updateCoordinateFraction(TQ coordinate, T *integerPart, TQ *fractionPart)
    {
        //CART ALWAYS goes to +ve position.
        //TOFIX
        //coord 3.25 returns 4, -1.25
        //coord 3.75 returns 4, -0.75
        
        //coord -3.25 returns -3, -0.75
        //coord -3.75 returns -3, -1.25
        *integerPart = T(round(coordinate + 0.5));
        *fractionPart = (TQ)(coordinate - (T)(*integerPart) - 0.5);
    }
    
    

    
    
};







template <typename T, typename TQ>
class RushtonTurbinePolarCPP{
    
public:
    
    RushtonTurbine turbine;
    
    Extents<T> extents;
    
    
    
    std::vector<PosPolar<T, TQ>> geomFixed;
    
    //These are circular rotating points that would replace one another if "rotating."
    std::vector<PosPolar<T, TQ>> geomRotatingNonUpdating;
    
    //Points that move and need to be removed as they move.
    std::vector<PosPolar<T, TQ>> geomRotating;
    
    
    
    
    TQ iCenter;
    TQ kCenter;
    
    
    tStepRT startingStep = 0;
    tGeomShapeRT impellerStartAngle = 0.0;
    tStepRT impellerStartupStepsUntilNormalSpeed = 0;
    
    

    
    RushtonTurbinePolarCPP(RushtonTurbine t, Extents<T> e):turbine(t), extents(e){

        iCenter = turbine.tankDiameter / 2 + MDIAM_BORDER / 2;
        kCenter = turbine.tankDiameter / 2 + MDIAM_BORDER / 2;

    }
    
    
    void clear_vectors(){
        
        geomFixed.clear();
        geomRotatingNonUpdating.clear();
        geomRotating.clear();
    }
    
    
    std::vector<PosPolar<T, TQ>> returnFixedGeometry() {
        return geomFixed;
    }
    
    std::vector<PosPolar<T, TQ>> returnRotatingNonUpdatingGeometry() {
        return geomRotatingNonUpdating;
    }
    
    std::vector<PosPolar<T, TQ>> returnRotatingGeometry(){
        return geomRotating;
    }
    
    
    
    
    
    
    void generateFixedGeometry(bool getInternal = 0) {
        
        addTankWall(getInternal);
        addBaffles(getInternal);
    }
    
    
    void generateRotatingNonUpdatingGeometry(bool getInternal = 0) {
        
        addImpellerShaft(getInternal);
        addImpellerHub(getInternal);
        addImpellerDisc(getInternal);
        
    }
    
    
    void generateRotatingGeometry(TQ atTheta, bool getInternal = 0){
        
        addImpellerBlades(atTheta, getInternal);
    }
    
    void updateRotatingGeometry(TQ atTheta, bool getInternal = 0){
        
        geomRotating.clear();
        addImpellerBlades(atTheta, getInternal);
    }
    
    
    void generateTranslatingGeometry(T step, bool getInternal = 0){
    }
    
    void updateTranslatingGeometry(T step, bool getInternal = 0){
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    void addTankWall(bool getInternal = 0) {
        
        T nCircPoints = 4 * (T)(roundf(M_PI * turbine.tankDiameter / (4 * turbine.resolution)));
        TQ dTheta = 2.0f * M_PI / TQ(nCircPoints);
        TQ r = 0.5f * turbine.tankDiameter;
        
        for(T j = (T)extents.y0; j <= (T)extents.y1; ++j)
        {
            
            for (T n = 0; n < nCircPoints; ++n)
            {
                
                TQ theta = TQ(n) * dTheta;
                if ((j & 1) == 1)
                    theta += 0.5f * dTheta;
                
                               
                //TODO, should the fractions be updated before center is added?????
                
                TQ iFP = iCenter + r * cos(theta);
                TQ kFP = kCenter + r * sin(theta);
                
                
                PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, j, kFP);
                
                if (extents.containsIK(g.i, g.k)){
                    
                    g.localise(extents);
                    
                    //                    std::cout <<g.iFP<<" "<<g.i << std::endl;
                    
                    geomFixed.push_back(g);
                    
                }
            }
        }
    }
    
    
    
    void addBaffles(bool getInternal = 0) {
        
        T nPointsBaffleThickness = T(roundf(turbine.baffles.thickness / turbine.resolution));
        if (nPointsBaffleThickness == 0)
            nPointsBaffleThickness = 1;
        
        TQ resolutionBaffleThickness = (TQ)(turbine.baffles.thickness) / (TQ)(nPointsBaffleThickness);
                
        TQ innerRadius = (TQ)turbine.baffles.innerRadius;
        TQ outerRadius = (TQ)turbine.baffles.outerRadius;
        T nPointsR = T(roundf((outerRadius - innerRadius) / turbine.resolution));
        
        TQ deltaR = (outerRadius - innerRadius) / static_cast<TQ>(nPointsR);
        
        TQ deltaBaffleOffset = 2.0/(TQ)turbine.baffles.numBaffles * M_PI;
        
        for (T nBaffle = 1; nBaffle <= turbine.baffles.numBaffles; ++nBaffle)
        {
            for (T j = (T)extents.y0; j <= (T)extents.y1; ++j)
            {
                for (T idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    TQ r = innerRadius + deltaR * (TQ)idxR;
                    
                    for (T idxTheta = 0; idxTheta <= nPointsBaffleThickness; ++idxTheta)
                    {
                        TQ theta = turbine.baffles.firstBaffleOffset +
                        deltaBaffleOffset * (TQ)nBaffle +
                        (idxTheta - nPointsBaffleThickness / 2.0f) * resolutionBaffleThickness / r;
                        
                        bool isSurface = idxTheta == 0 || idxTheta == nPointsBaffleThickness ||
                        idxR == 0 || idxR == nPointsR;
                        
                        
                        
                        TQ iFP = iCenter + r * cos(theta);
                        TQ kFP = kCenter + r * sin(theta);
                        
                        bool isInternal = isSurface ? 0 : 1;
                        
                        PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, j, kFP);

                        
                        if (extents.containsIK(g.i, g.k)){
                            
                            g.localise(extents);
                            
                            if (getInternal && isInternal) geomFixed.push_back(g);
                            if (getInternal == 0 && isInternal == 0) geomFixed.push_back(g);
                            
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    void addImpellerBlades(TQ atTheta, bool getInternal = 0) {
        
        
        TQ innerRadius = turbine.impellers[0].blades.innerRadius;
        TQ outerRadius = turbine.impellers[0].blades.outerRadius;
        T diskBottom = T(roundf(turbine.impellers[0].disk.bottom));
        T diskTop = T(roundf(turbine.impellers[0].disk.top));
        T impellerBottom = T(roundf(turbine.impellers[0].blades.bottom));
        T impellerTop = T(roundf(turbine.impellers[0].blades.top));
        
        T lowerLimitY = std::max((T)extents.y0, impellerTop);
        T upperLimitY = std::min((T)extents.y1, impellerBottom);
        
        T nPointsR = T(roundf((outerRadius - innerRadius) / turbine.resolution));
        TQ nPointsThickness = T(roundf(turbine.impellers[0].blades.thickness / turbine.resolution));
        if (nPointsThickness == 0)
            nPointsThickness = 1;
        
        TQ resolutionBladeThickness = turbine.impellers[0].blades.thickness / (TQ)nPointsThickness;
        TQ deltaR = (outerRadius - innerRadius) / nPointsR;
        
        
        TQ deltaTheta = 2.0/(TQ)turbine.impellers[0].numBlades * M_PI;
        
        
        
//        double wa = calcThisStepImpellerIncrement(step);
        
        
        for (T nBlade = 1; nBlade <= turbine.impellers[0].numBlades; ++nBlade)
        {
            for (T j = lowerLimitY; j <= upperLimitY; ++j)
            {
                for (T idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    TQ r = innerRadius  + deltaR * idxR;
                    for (T idxThickness = 0; idxThickness <= nPointsThickness; ++idxThickness)
                    {
                        TQ theta = deltaTheta * nBlade +
                        turbine.impellers[0].firstBladeOffset +
                        (idxThickness - nPointsThickness / 2.0f) * resolutionBladeThickness / r;
                        
                        bool insideDisc = (r <= turbine.impellers[0].disk.radius) && (j >= diskBottom) && (j <= diskTop);
                        if(insideDisc)
                            continue;
                        
                        bool isSurface = idxThickness == 0 || idxThickness == nPointsThickness ||
                        idxR == 0 || idxR == nPointsR ||
                        j == impellerBottom || j == impellerTop;
                        
                        TQ rPolar = r;
                        TQ tPolar = theta;
                        
                        TQ iFP = iCenter + r * cos(theta);
                        TQ kFP = kCenter + r * sin(theta);
                        
                        PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, j, kFP);

                        g.uDelta = -atTheta * rPolar * sin(tPolar);
                        g.vDelta = 0.0;
                        g.wDelta = atTheta * rPolar * cos(tPolar);
                        
                        bool isInternal = isSurface ? 0 : 1;
                        
                        //TOFIX TODO BLADES ALL BLADES ARE PASSED ON
//                        if (extents.containsIK(g.i, g.k)){
                            
                           
                            g.localise(extents);
                            
                            //BOTH THE SOLID AND SURFACE ELEMENTS ARE ROTATING
                            if (getInternal && isInternal) geomRotating.push_back(g);
                            if (getInternal == 0 && isInternal == 0) geomRotating.push_back(g);
//                        }
  
                    }
                }
            }
        }
        
    }
    
    
    
    void addImpellerDisc(bool getInternal = 0){
        
        T bottom = T(roundf(turbine.impellers[0].disk.bottom));
        T top = T(roundf(turbine.impellers[0].disk.top));
        TQ hubRadius = turbine.impellers[0].hub.radius;
        TQ diskRadius = turbine.impellers[0].disk.radius;
        
        T nPointsR = T(round((diskRadius - hubRadius) / turbine.resolution));
        TQ deltaR = (diskRadius - hubRadius) / (TQ)(nPointsR);
        
        T lowerLimitY = std::max((T)extents.y0, top);
        T upperLimitY = std::min((T)extents.y1, bottom);
        
        for (T j = lowerLimitY; j <= upperLimitY; ++j)
        {
            for (T idxR = 1; idxR <= nPointsR; ++idxR)
            {
                TQ r = hubRadius + idxR * deltaR;
                TQ dTheta;
                T nPointsTheta = T(roundf(2 * M_PI * r / turbine.resolution));
                if(nPointsTheta == 0)
                {
                    dTheta = 0;
                    nPointsTheta = 1;
                }
                else
                    dTheta = 2 * M_PI / nPointsTheta;
                
                TQ theta0 = turbine.impellers[0].firstBladeOffset;
                if ((idxR & 1) == 0)
                    theta0 += 0.5f * dTheta;
                if ((j & 1) == 0)
                    theta0 += 0.5f * dTheta;
                
                for (T idxTheta = 0; idxTheta <= nPointsTheta - 1; ++idxTheta)
                {
                    bool isSurface = j == bottom || j == top || idxR == nPointsR;
                    
                    TQ rPolar = r;
                    TQ tPolar = theta0 + idxTheta * dTheta;
                    
                    TQ iFP = iCenter + r * cos(tPolar);
                    TQ kFP = kCenter + r * sin(tPolar);
                    
                    PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, j, kFP);

                    
                    g.uDelta = -turbine.wa * rPolar * sin(tPolar);
                    g.vDelta = 0;
                    g.wDelta = turbine.wa * rPolar * cos(tPolar);
                    
                    bool isInternal = isSurface ? 0 : 1;
                    
                    
                    if (extents.containsIK(g.i, g.k)){
                        
                        g.localise(extents);
                        
                        if (getInternal && isInternal) geomRotating.push_back(g);
                        if (getInternal == 0 && isInternal == 0) geomRotating.push_back(g);
                        
                    }
                }
            }
        }
        
    }
    
    
    
    
    void addImpellerHub(bool getInternal = 0){
        
        T diskBottom = T(roundf(turbine.impellers[0].disk.bottom));
        T diskTop = T(roundf(turbine.impellers[0].disk.top));
        
        T bottom = T(roundf(turbine.impellers[0].hub.bottom));
        T top = T(roundf(turbine.impellers[0].hub.top));
        TQ hubRadius = turbine.impellers[0].hub.radius;
        
        T nPointsR = T(roundf((hubRadius - turbine.shaft.radius) / turbine.resolution));
        TQ resolutionR = (hubRadius - turbine.shaft.radius) / TQ(nPointsR);
        
        T lowerLimitY = std::max((T)extents.y0, top);
        T upperLimitY = std::min((T)extents.y1, bottom);
        
        for (T j = lowerLimitY; j <= upperLimitY; ++j)
        {
            bool isWithinDisc = j >= diskBottom && j <= diskTop;
            
            for (T idxR = 1; idxR <= nPointsR; ++idxR)
            {
                TQ r = turbine.shaft.radius + idxR * resolutionR;
                T nPointsTheta = T(roundf(2 * M_PI * r / turbine.resolution));
                TQ dTheta;
                if(nPointsTheta == 0)
                {
                    dTheta = 0;
                    nPointsTheta = 1;
                }
                else
                    dTheta = 2 * M_PI / nPointsTheta;
                
                TQ theta0 = turbine.impellers[0].firstBladeOffset;
                if ((idxR & 1) == 0)
                    theta0 += 0.5f * dTheta;
                if ((j & 1) == 0)
                    theta0 += 0.5f * dTheta;
                
                for (T idxTheta = 0; idxTheta <= nPointsTheta - 1; ++idxTheta)
                {
                    bool isSurface = (j == bottom || j == top || idxR == nPointsR) && !isWithinDisc;
                    
                    
                    TQ rPolar = r;
                    TQ tPolar = theta0 + idxTheta * dTheta;
                    //                    g.resolution = turbine.resolution * turbine.resolution;
                    
                    TQ iFP = iCenter + r * cos(tPolar);
                    TQ kFP = kCenter + r * sin(tPolar);
                    
                    PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, j, kFP);

                    g.uDelta = -turbine.wa * rPolar * sin(tPolar);
                    g.vDelta = 0;
                    g.wDelta = turbine.wa * rPolar * cos(tPolar);
                    
                    bool isInternal = isSurface ? 0 : 1;
                    
                                        
                    if (extents.containsIK(g.i, g.k)){
                        
                        g.localise(extents);
                        
                        
                        if (getInternal && isInternal) geomRotating.push_back(g);
                        if (getInternal == 0 && isInternal == 0) geomRotating.push_back(g);
                        
                    }
                }
            }
        }
    }
    
    
    void addImpellerShaft(bool getInternal = 0){
        
        T hubBottom = T(roundf(turbine.impellers[0].hub.bottom));
        T hubTop = T(roundf(turbine.impellers[0].hub.top));
        
        for (T j = (T)extents.y0; j <= (T)extents.y1; ++j)
        {
            bool isWithinHub = j >= hubBottom && j <= hubTop;
            
            
            TQ rEnd = turbine.shaft.radius; // isWithinHub ? modelConfig.hub.radius : modelConfig.shaft.radius;
            T nPointsR = roundf(rEnd / turbine.resolution);
            
            for(T idxR = 0; idxR <= nPointsR; ++idxR)
            {
                TQ r, dTheta;
                T nPointsTheta;
                if(idxR == 0)
                {
                    r = 0;
                    nPointsTheta = 1;
                    dTheta = 0;
                }
                else
                {
                    r = idxR * turbine.resolution;
                    nPointsTheta = 4 * T(roundf(M_PI * 2.0f * r / (4.0f * turbine.resolution)));
                    if(nPointsTheta == 0)
                        nPointsTheta = 1;
                    dTheta = 2 * M_PI / nPointsTheta;
                }
                
                for (T idxTheta = 0; idxTheta < nPointsTheta; ++idxTheta)
                {
                    TQ theta = idxTheta * dTheta;
                    if ((j & 1) == 0)
                        theta += 0.5f * dTheta;
                    
                    bool isSurface = idxR == nPointsR && !isWithinHub;

                    TQ rPolar = r;
                    TQ tPolar = theta;
                    //                        g.resolution = turbine.resolution;

                    TQ iFP = iCenter + r * cos(theta);
                    TQ kFP = kCenter + r * sin(theta);
                    
                    PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, j, kFP);

                    
                    g.uDelta = -turbine.wa * rPolar * sin(tPolar);
                    g.vDelta = 0.0f;
                    g.wDelta =  turbine.wa * rPolar * cos(tPolar);
                    
                    bool isInternal = isSurface ? 0 : 1;
                    
                    
                                    
                    if (extents.containsIK(g.i, g.k)){
                        
                        
                        g.localise(extents);
                        
                        if (getInternal && isInternal) geomRotating.push_back(g);
                        if (getInternal == 0 && isInternal == 0) geomRotating.push_back(g);
                        
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    TQ calcThisStepImpellerIncrement(tStepRT step)
    {
        
        TQ thisStepImpellerIncrementWA = turbine.impellers[0].bladeTipAngularVelW0;
        
        
        //slowly start the impeller
        if (step < impellerStartupStepsUntilNormalSpeed) {
            
            thisStepImpellerIncrementWA = 0.5 * turbine.impellers[0].bladeTipAngularVelW0 * (1.0 - cos(M_PI * (T)step / impellerStartupStepsUntilNormalSpeed));
            
        }
        return thisStepImpellerIncrementWA;
    }
    
    
    
    
//    TQ updateRotatingGeometry(tStepRT step, TQ impellerTheta)
//    {
//
//
//        TQ thisStepImpellerIncrementWA = calcThisStepImpellerIncrement(step);
//
//        impellerTheta += thisStepImpellerIncrementWA;
//
//
//
//
//
//        //Only updates the rotating elements
//
//#pragma omp parallel for
//        for (int i = 0; i < geomRotating.size(); i++)
//        {
//
//            PosPolar<T, TQ> &g = geomRotating[i];
//
//            g.tPolar += thisStepImpellerIncrementWA;
//
//
//
//            g.iFP = iCenter + g.rPolar * cos(g.tPolar);
//            g.kFP = kCenter + g.rPolar * sin(g.tPolar);
//
//            g.uDelta = -thisStepImpellerIncrementWA * g.rPolar * sin(g.tPolar);
//            g.wDelta =  thisStepImpellerIncrementWA * g.rPolar * cos(g.tPolar);
//
//            UpdateCoordinateFraction(g.iFP, &g.i_cart, &g.iCartFraction);
//            UpdateCoordinateFraction(g.kFP, &g.k_cart, &g.kCartFraction);
//
//
//        }
//
//
//
//        return impellerTheta;
//    }
    
    
    
    
    
    
};//end of class
