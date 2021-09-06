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
#include <climits>


#include "GlobalStructures.hpp"
#include "RushtonTurbine.hpp"


using tNi = long int;



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


    PosPolar(TQ iFP, TQ jFP, TQ kFP)
    {
        updateCoordinateFraction(iFP, &i, &iCartFraction);
        updateCoordinateFraction(jFP, &j, &jCartFraction);
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
        //TOFIX TODO
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

private:
    T diameterBorder = 4;

public:

    RushtonTurbine turbine;

    Extents<T> extents;

    std::vector<PosPolar<T, TQ>> geomFixed;

    //These are circular rotating points that would replace one another if "rotating."
    std::vector<PosPolar<T, TQ>> geomRotatingNonUpdating;

    //Points that move and need to be removed as they move.
    std::vector<PosPolar<T, TQ>> geomRotating;



    T tankDiameter;
    TQ iCenter;
    TQ kCenter;




    tStepRT startingStep = 0;
    tGeomShapeRT impellerStartAngle = 0.0;
    tStepRT impellerStartupStepsUntilNormalSpeed = 0;




    RushtonTurbinePolarCPP(RushtonTurbine t, Extents<T> e):turbine(t), extents(e){

        tankDiameter = turbine.tankDiameter - diameterBorder;
        iCenter = (TQ)tankDiameter / 2 + (TQ)diameterBorder / 2;
        kCenter = (TQ)tankDiameter / 2 + (TQ)diameterBorder / 2;

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




    void generateFixedGeometry(GeomPlacement place) {

        std::vector<PosPolar<T, TQ>> wall = getTankWall();
        std::vector<PosPolar<T, TQ>> baffles = getBaffles(place);
        geomFixed.insert( geomFixed.end(), wall.begin(), wall.end() );
        geomFixed.insert( geomFixed.end(), baffles.begin(), baffles.end() );
    }


    void generateRotatingNonUpdatingGeometry(TQ deltaTheta, GeomPlacement place) {

        std::vector<PosPolar<T, TQ>> disk = getImpellerDisk(deltaTheta, place);
        std::vector<PosPolar<T, TQ>> hub = getImpellerHub(deltaTheta, place);
        std::vector<PosPolar<T, TQ>> shaft = getImpellerShaft(deltaTheta, place);

        geomRotatingNonUpdating.insert( geomRotatingNonUpdating.end(), disk.begin(), disk.end() );
        geomRotatingNonUpdating.insert( geomRotatingNonUpdating.end(), hub.begin(), hub.end() );
        geomRotatingNonUpdating.insert( geomRotatingNonUpdating.end(), shaft.begin(), shaft.end() );
    }


    void generateRotatingGeometry(TQ atTheta, TQ deltaTheta, GeomPlacement place){

        std::vector<PosPolar<T, TQ>> blades = getImpellerBlades(atTheta, deltaTheta, place);
        geomRotating.insert( geomRotating.end(), blades.begin(), blades.end() );
    }

    void updateRotatingGeometry(TQ atTheta, TQ deltaTheta, GeomPlacement place){

        geomRotating.clear();

        std::vector<PosPolar<T, TQ>> blades = getImpellerBlades(atTheta, deltaTheta, place);
        geomRotating.insert( geomRotating.end(), blades.begin(), blades.end() );
    }


    void generateTranslatingGeometry(T step, GeomPlacement place){
    }

    void updateTranslatingGeometry(T step, GeomPlacement place){
    }










    std::vector<Pos3d<T>> getExternalPoints(){

        std::vector<Pos3d<tNi>> exclude;

        std::vector<PosPolar<T, TQ>> wall = getTankWall();

        Pos3d<T> minP(INT_MAX,INT_MAX,INT_MAX);
        Pos3d<T> maxP(0,0,0);

        for (auto &p: wall){

            if (p.i < minP.i){
                minP.i = p.i;
                minP.j = p.j;
                minP.k = p.k;
            }
            if (p.i > maxP.i){
                maxP.i = p.i;
                maxP.j = p.j;
                maxP.k = p.k;
            }


            //Exclude everything outside the tank wall
            if (p.k <= (T)kCenter){
                if (p.k > extents.z0 && p.k < extents.z1){

                    //fill to p.k-1 because p.k will be set for the wall surface
                    for (auto k = extents.z0; k < p.k; k++){
                        Pos3d<tNi> e = Pos3d<tNi>(p.i, p.j, k);
                        e.localise(extents);
                        exclude.push_back(e);
                    }
                }
            }

            if (p.k >= (T)kCenter){
                if (p.k > extents.z0 && p.k < extents.z1){
                    for (auto k = p.k + 1; k < extents.z1; k++){
                        Pos3d<tNi> e = Pos3d<tNi>(p.i, p.j, k);
                        e.localise(extents);
                        exclude.push_back(e);
                    }
                }
            }
        }// end of wall points


        if (minP.i >= extents.x0 && minP.i < extents.x1){
            for (auto i = extents.x0; i < minP.i; i++){
                for (auto j = extents.y0; j < extents.y1; j++){
                    for (auto k = extents.z0; k < extents.z1; k++){
                        Pos3d<tNi> e = Pos3d<tNi>(i, j, k);
                        e.localise(extents);
                        exclude.push_back(e);
                    }
                }
            }
        }
        if (maxP.i >= extents.x0 && maxP.i < extents.x1){
            for (auto i = maxP.i; i < extents.x1; i++){
                for (auto j = extents.y0; j < extents.y1; j++){
                    for (auto k = extents.z0; k < extents.z1; k++){
                        Pos3d<tNi> e = Pos3d<tNi>(i, j, k);
                        e.localise(extents);
                        exclude.push_back(e);
                    }
                }
            }
        }
        return exclude;
    }







    std::vector<PosPolar<T, TQ>> getTankWall() {

        T nCircPoints = 4 * (T)(roundf(M_PI * tankDiameter / (4 * turbine.resolution)));
        TQ dTheta = 2.0f * M_PI / TQ(nCircPoints);
        TQ r = 0.5f * tankDiameter;

        std::vector<PosPolar<T, TQ>> wall;

        for(T j = (T)extents.y0; j <= (T)extents.y1; ++j)
        {

            for (T n = 0; n < nCircPoints; ++n)
            {
                TQ theta = TQ(n) * dTheta;
                if ((j & 1) == 1)
                    theta += 0.5f * dTheta;

                TQ iFP = iCenter + r * cos(theta);
                TQ kFP = kCenter + r * sin(theta);

                PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, (TQ)j - 0.5, kFP);

                if (extents.containsIK(g.i, g.k)){

                    g.localise(extents);
                    wall.push_back(g);
                }
            }
        }
        return wall;
    }



    std::vector<PosPolar<T, TQ>> getBaffles(GeomPlacement place) {

        T nPointsBaffleThickness = T(roundf(turbine.baffles.thickness / turbine.resolution));
        if (nPointsBaffleThickness == 0)
            nPointsBaffleThickness = 1;

        TQ resolutionBaffleThickness = (TQ)(turbine.baffles.thickness) / (TQ)(nPointsBaffleThickness);

        TQ innerRadius = (TQ)turbine.baffles.innerRadius;
        TQ outerRadius = (TQ)turbine.baffles.outerRadius;
        T nPointsR = T(roundf((outerRadius - innerRadius) / turbine.resolution));

        TQ deltaR = (outerRadius - innerRadius) / static_cast<TQ>(nPointsR);

        TQ deltaBaffleOffset = 2.0/(TQ)turbine.baffles.numBaffles * M_PI;

        T lowerY = (T)extents.y0;
        if ((T)extents.y0 == 0) lowerY = 1;

        T upperY = (T)extents.y1;
        if ((T)extents.y1 == turbine.tankHeight) upperY = turbine.tankHeight - 1;


        std::vector<PosPolar<T, TQ>> baffles;
        for (T nBaffle = 1; nBaffle <= turbine.baffles.numBaffles; ++nBaffle)
        {
            for (T j = lowerY; j <= upperY; ++j)
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

                        PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, (TQ)j - 0.5, kFP);


                        if (extents.containsIK(g.i, g.k)){

                            g.localise(extents);

                            if (place == surfaceAndInternal){
                                baffles.push_back(g);
                            }
                            else if (isInternal && place == internal){
                                baffles.push_back(g);
                            }
                            else if (isInternal == 0 && place == surface){
                                baffles.push_back(g);
                            }



                        }
                    }
                }
            }
        }
        return baffles;
    }





    std::vector<PosPolar<T, TQ>> getImpellerBlades(TQ atTheta, TQ deltaTheta, GeomPlacement place) {


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


        TQ deltaBlade = 2.0/(TQ)turbine.impellers[0].numBlades * M_PI;


        std::vector<PosPolar<T, TQ>> blades;
        for (T nBlade = 1; nBlade <= turbine.impellers[0].numBlades; ++nBlade)
        {
            for (T j = lowerLimitY; j <= upperLimitY; ++j)
            {
                for (T idxR = 0; idxR <= nPointsR; ++idxR)
                {
                    TQ r = innerRadius  + deltaR * idxR;
                    for (T idxThickness = 0; idxThickness <= nPointsThickness; ++idxThickness)
                    {
                        TQ theta = deltaBlade * nBlade +
                        turbine.impellers[0].firstBladeOffset +
                        (idxThickness - nPointsThickness / 2.0f) * resolutionBladeThickness / r;

                        bool insideDisk = (r <= turbine.impellers[0].disk.radius) && (j >= diskBottom) && (j <= diskTop);
                        if(insideDisk)
                            continue;

                        bool isSurface = idxThickness == 0 || idxThickness == nPointsThickness ||
                        idxR == 0 || idxR == nPointsR ||
                        j == impellerBottom || j == impellerTop;


                        //Update polar coords
                        TQ rPolar = r;
                        TQ tPolar = theta + atTheta;


                        TQ iFP = iCenter + rPolar * cos(tPolar);
                        TQ kFP = kCenter + rPolar * sin(tPolar);

                        PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, (TQ)j - 0.5, kFP);

                        g.uDelta = -deltaTheta * rPolar * sin(tPolar);
                        g.vDelta = 0.0;
                        g.wDelta = deltaTheta * rPolar * cos(tPolar);

                        bool isInternal = isSurface ? 0 : 1;


                        g.localise(extents);

                        if (place == surfaceAndInternal){
                            blades.push_back(g);
                        }
                        else if (isInternal && place == internal){
                            blades.push_back(g);
                        }
                        else if (isInternal == 0 && place == surface){
                            blades.push_back(g);
                        }
                    }
                }
            }
        }
        return blades;
    }


    std::vector<PosPolar<T, TQ>> getImpellerDisk(TQ deltaTheta, GeomPlacement place){

        T bottom = T(roundf(turbine.impellers[0].disk.bottom));
        T top = T(roundf(turbine.impellers[0].disk.top));
        TQ hubRadius = turbine.impellers[0].hub.radius;
        TQ diskRadius = turbine.impellers[0].disk.radius;

        T nPointsR = T(round((diskRadius - hubRadius) / turbine.resolution));
        TQ deltaR = (diskRadius - hubRadius) / (TQ)(nPointsR);

        T lowerLimitY = std::max((T)extents.y0, top);
        T upperLimitY = std::min((T)extents.y1, bottom);

        std::vector<PosPolar<T, TQ>> disk;
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

                    PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, (TQ)j - 0.5, kFP);

                    g.uDelta = -deltaTheta * rPolar * sin(tPolar);
                    g.vDelta = 0;
                    g.wDelta = deltaTheta * rPolar * cos(tPolar);

                    bool isInternal = isSurface ? 0 : 1;


                    if (extents.containsIK(g.i, g.k)){

                        g.localise(extents);

                        if (place == surfaceAndInternal){
                            disk.push_back(g);
                        }
                        else if (isInternal && place == internal){
                            disk.push_back(g);
                        }
                        else if (isInternal == 0 && place == surface){
                            disk.push_back(g);
                        }

                    }
                }
            }
        }
        return disk;
    }

    std::vector<PosPolar<T, TQ>> getImpellerHub(TQ deltaTheta, GeomPlacement place){

        T diskBottom = T(roundf(turbine.impellers[0].disk.bottom));
        T diskTop = T(roundf(turbine.impellers[0].disk.top));

        T bottom = T(roundf(turbine.impellers[0].hub.bottom));
        T top = T(roundf(turbine.impellers[0].hub.top));
        TQ hubRadius = turbine.impellers[0].hub.radius;

        T nPointsR = T(roundf((hubRadius - turbine.shaft.radius) / turbine.resolution));
        TQ resolutionR = (hubRadius - turbine.shaft.radius) / TQ(nPointsR);

        T lowerLimitY = std::max((T)extents.y0, top);
        T upperLimitY = std::min((T)extents.y1, bottom);

        std::vector<PosPolar<T, TQ>> hub;
        for (T j = lowerLimitY; j <= upperLimitY; ++j)
        {
            bool isWithinDisk = j >= diskBottom && j <= diskTop;

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
                    bool isSurface = (j == bottom || j == top || idxR == nPointsR) && !isWithinDisk;


                    TQ rPolar = r;
                    TQ tPolar = theta0 + idxTheta * dTheta;
                    //                    g.resolution = turbine.resolution * turbine.resolution;

                    TQ iFP = iCenter + r * cos(tPolar);
                    TQ kFP = kCenter + r * sin(tPolar);

                    PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, (TQ)j - 0.5, kFP);

                    g.uDelta = -deltaTheta * rPolar * sin(tPolar);
                    g.vDelta = 0;
                    g.wDelta = deltaTheta * rPolar * cos(tPolar);

                    bool isInternal = isSurface ? 0 : 1;


                    if (extents.containsIK(g.i, g.k)){

                        g.localise(extents);

                        if (place == surfaceAndInternal){
                            hub.push_back(g);
                        }
                        else if (isInternal && place == internal){
                            hub.push_back(g);
                        }
                        else if (isInternal == 0 && place == surface){
                            hub.push_back(g);
                        }

                    }
                }
            }
        }
        return hub;
    }

    std::vector<PosPolar<T, TQ>> getImpellerShaft(TQ deltaTheta, GeomPlacement place){

        T hubBottom = T(roundf(turbine.impellers[0].hub.bottom));
        T hubTop = T(roundf(turbine.impellers[0].hub.top));

        T lowerY = (T)extents.y0;
        if ((T)extents.y0 == 0) lowerY = 1;

        T upperY = (T)extents.y1;
        if ((T)extents.y1 == turbine.tankHeight) upperY = turbine.tankHeight - 1;


        std::vector<PosPolar<T, TQ>> shaft;
        for (T j = lowerY; j <= upperY; ++j)
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

                    PosPolar<T, TQ> g = PosPolar<T, TQ>(iFP, (TQ)j - 0.5, kFP);

                    g.uDelta = -deltaTheta * rPolar * sin(tPolar);
                    g.vDelta = 0.0f;
                    g.wDelta =  deltaTheta * rPolar * cos(tPolar);

                    bool isInternal = isSurface ? 0 : 1;



                    if (extents.containsIK(g.i, g.k)){


                        g.localise(extents);

                        if (place == surfaceAndInternal){
                            shaft.push_back(g);
                        }
                        else if (isInternal && place == internal){
                            shaft.push_back(g);
                        }
                        else if (isInternal == 0 && place == surface){
                            shaft.push_back(g);
                        }

                    }



                }
            }
        }
        return shaft;
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




    //    void fastOneCURotateImpellerBlades(std::vector<PosPolar<tNi, TQ>> geom, TQ deltaTheta){
    //
    //        //Only works with ONE CU
    //
    //        for (auto &p: geom){
    //
    //            //Update polar coords. Polar not saved anymore.
    //            TQ rPolar = p.rPolar;
    //            TQ tPolar = p.tPolar+ deltaTheta;
    //
    //            TQ iFP = iCenter + rPolar * cos(tPolar);
    //            TQ kFP = kCenter + rPolar * sin(tPolar);
    //
    //
    //            //Update the vector of points
    //            p.tPolar = tPolar;
    //
    //            updateCoordinateFraction(iFP, &p.i, &p.iCartFraction);
    ////          updateCoordinateFraction(jFP, &p.j, &p.jCartFraction); //j doesnt change
    //            updateCoordinateFraction(kFP, &p.k, &p.kCartFraction);
    //
    //            p.uDelta = -deltaTheta * rPolar * sin(tPolar);
    //            p.vDelta = 0.0;
    //            p.wDelta = deltaTheta * rPolar * cos(tPolar);
    //
    //
    //            //Localise not needed as function used when simulation run with only 1 CU.
    //            //g.localise(extents);
    //        }
    //    }



};//end of class
