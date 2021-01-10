//
//  File.cpp
//
//
//  Created by Niall Ó Broin on 31/12/2020.
//

#pragma once

#include <iostream>
#include <vector>
#include <map>
#include <fstream>
#include <algorithm>
#include <cmath>

#include "RushtonTurbine.hpp"


template <typename T>
struct Point2D{
    T x;
    T y;
};

template <typename T>
struct Pos2d{
    T x;
    T y;
};


template <typename T>
struct Pos3d{
    T i;
    T j;
    T k;
};


template <typename T>
struct Line{
    T x0;
    T y0;
    T x1;
    T y1;
};






template <typename T>
class RushtonTurbineMidPointCPP {
    
    
public:
    
    RushtonTurbine turbine;
    
    
    std::vector<Pos3d<T>> geomFixed;
    std::vector<Pos3d<T>> geomRotating;
    std::vector<Pos3d<T>> geomTranslating;
    
    int iCenter;
    int kCenter;
    int tankRadius;
    int tankHeight;
    
    
    
    
    tStep startingStep = 0;
    tGeomShape impellerStartAngle = 0.0;
    tStep impellerStartupStepsUntilNormalSpeed = 0;

    
//    tGeomShape calc_this_step_impeller_increment(tStep step);


    RushtonTurbineMidPointCPP(std::string jsonFile){
    
        RushtonTurbine turbineData;
        turbineData.loadGeometryConfigAsJSON(jsonFile);

        turbine = turbineData;
        
    }

    
    
    RushtonTurbineMidPointCPP(RushtonTurbine turbineData){
    
        turbine = turbineData;
        tankRadius = turbine.tankDiameter / 2;
        tankHeight = turbine.tankDiameter;
        iCenter = tankRadius;
        kCenter = tankRadius;
        
    }
    
    RushtonTurbineMidPointCPP(double angle, tStep step, int gridx, RushtonTurbine turbineData){
        
        turbine = turbineData;
        
    }

    
    
    
    void setGeometryStartup(tStep startingStep, tGeomShape impellerStartAngle,
                                            tStep impellerStartupStepsUntilNormalSpeed){

        startingStep = startingStep;
        impellerStartAngle = impellerStartAngle;
        impellerStartupStepsUntilNormalSpeed = impellerStartupStepsUntilNormalSpeed;

    }

    
    
    
    void clear_vectors(){

        geomFixed.clear();
        geomRotating.clear();
        geomTranslating.clear();
    }

    
    
    
    
    void generateFixedGeometry() {
        
        getWall(turbine);
        getBaffles(turbine);
    }


    
    void generateRotatingGeometry(double atTheta) {
        
        getImpellers(turbine, atTheta);
    }





    
    void getImpellers(RushtonTurbine turbine, double atTheta){

        
        std::vector<Pos2d<T>> shaft = midPointCircle2D(turbine.shaft.radius, iCenter, kCenter);
        
        for (auto imp = 0; imp < turbine.impellers.size(); imp++){
        
            getImpellerHub(turbine, imp);
            getImpellerDisc(turbine, imp);
            
            
            //TODO HACK
            getTurbineShaft(turbine, turbine.tankDiameter, 0);

                
            getImpellerBlades(turbine, atTheta, imp);
        }

        //TODO SHAFT
        for (auto imp = 0; imp < turbine.impellers.size(); imp++){
            
            for (int j=turbine.impellers[imp].impellerPosition; j<turbine.impellers[imp].impellerPosition; j++){
                
                for (const auto& p: shaft){
                    geomRotating.push_back(Pos3d<T>{p.x, j, p.y});
                }
            }
        }

    }


    
    void getImpellerBlades(RushtonTurbine turbine, double atTheta, int imp){

        Impeller impeller = turbine.impellers[imp];
        Blades blades = impeller.blades;
        
        double deltaImpellerOffset = (2.0 * M_PI) / double(impeller.numBlades);

        double reducedTheta = 0;
        while (reducedTheta > 2.0 * M_PI) {
            reducedTheta -= 2.0 * M_PI;
        }
        
     
        for (int nBlade = 0; nBlade < impeller.numBlades; nBlade ++){

            double bladeAngle = reducedTheta + double(impeller.firstBladeOffset) + deltaImpellerOffset * double(nBlade);
            
            
            std::vector<Pos2d<T>> box = getBoxOnRadius2D(bladeAngle, blades.outerRadius, blades.innerRadius, blades.thickness, iCenter, kCenter);

            for (int j=blades.top+1; j<blades.bottom-1; j++){
                
                for (const auto& p: box){
                    geomRotating.push_back({p.x, j, p.y});
                }
            }
            
            
            
            std::vector<Pos3d<T>> lid = getBoxLidOnRadius2D(blades.bottom, box);
            for (const auto& p: lid){
                geomRotating.push_back(p);
            }
            std::vector<Pos3d<T>> lid2 = getBoxLidOnRadius2D(blades.top, box);
            for (const auto& p: lid2){
                geomRotating.push_back(p);
            }

        }

    }

    
    void getTurbineShaft(RushtonTurbine turbine, int bottom, int height) {
     
        std::vector<Pos3d<T>> shaft = getCylinderWallIK(turbine.shaft.radius, height, bottom, iCenter, kCenter);
        
        for (const auto& p: shaft){
            geomRotating.push_back(p);
        }
        
    }




    
    void getImpellerDisc(RushtonTurbine turbine, int impeller) {
        
        Disk disk = turbine.impellers[impeller].disk;
        
        std::vector<Pos3d<T>> diskPoints  = getThickHollowDisc(turbine.shaft.radius, disk.radius, disk.top-disk.bottom, disk.bottom, iCenter, kCenter);
        
        for (const auto& p: diskPoints){
            geomRotating.push_back(p);
        }
        
        std::vector<Pos3d<T>> wall = getCylinderWallIK(disk.radius, disk.top-disk.bottom, disk.bottom, iCenter, kCenter);

        for (const auto& p: wall){
            geomFixed.push_back(p);
        }

        
    }



    
    void getImpellerHub(RushtonTurbine turbine, int impeller) {
        
        Disk hub = turbine.impellers[impeller].hub;

        std::vector<Pos3d<T>> hubPoints  = getThickHollowDisc(turbine.shaft.radius, hub.radius, hub.top - hub.bottom, hub.bottom, iCenter, kCenter);
        
        for (const auto& p: hubPoints){
            geomRotating.push_back(p);
        }
        
        std::vector<Pos3d<T>> wall = getCylinderWallIK(hub.radius, hub.top-hub.bottom, hub.bottom, iCenter, kCenter);

        for (const auto& p: wall){
            geomFixed.push_back(p);
        }
        
    }




    //=========Fixed Geom


    
    void getWall(RushtonTurbine turbine){

        std::vector<Pos3d<T>> wall = getCylinderWallIK(tankRadius, turbine.tankDiameter, 0, iCenter, kCenter);
        
        for (const auto& p: wall){
            geomFixed.push_back(p);
        }
    }

    
    void getBaffles(RushtonTurbine turbine){
        

        double deltaBaffleOffset = (2.0 * M_PI) / turbine.baffles.numBaffles;
        
        for (int nBaffle=0; nBaffle<turbine.baffles.numBaffles; nBaffle++){
        
            double baffleAngle = turbine.baffles.firstBaffleOffset + deltaBaffleOffset * nBaffle;
            
            std::vector<Pos2d<T>> box = getBoxOnRadius2D(baffleAngle, turbine.baffles.outerRadius, turbine.baffles.innerRadius, turbine.baffles.thickness, iCenter, kCenter);

            for (T h = 0; h < tankHeight; h++){
                for (const auto& p: box){
                    geomFixed.push_back({p.x, h, p.y});
                }
            }

        }
    }






    //===============================





    
    void printPoints3D(std::vector<Pos3d<T>> cloud){

        for (const auto& v: cloud){
            std::cout << v.i << " " << v.j << " " << v.k << std::endl;
        }
    }


    
    void saveGeomAsPLY(std::string filename){


        std::ofstream myfile;
        myfile.open (filename);
        myfile << "ply\nformat ascii 1.0\nelement vertex " << geomRotating.size() + geomFixed.size();
        myfile << "\nproperty int x\nproperty int y\nproperty int z\nend_header\n";
        
        for (const auto& v: geomFixed){

            myfile << v.i << " " << v.j << " " << v.k << "\n";
        }

        for (const auto& v: geomRotating){

            myfile << v.i << " " << v.j << " " << v.k << "\n";
        }

        
        myfile.close();

    }






    
    std::vector<Pos3d<T>> getBoxLidOnRadius2D(T atJ, std::vector<Pos2d<T>> box){

        
        std::map<T, std::vector<T>> boxMap;
        
        for ( const auto &p : box ) {
            boxMap[p.x] = {};
        }
        for ( const auto &p : box ) {
            boxMap[p.x].push_back(p.y);
        }
        

        std::vector<Pos3d<T>> lid;
        for ( const auto &map : boxMap ) {
            
            auto minmax = std::minmax_element(map.second.begin(), map.second.end());

            for (T k=*minmax.first; k<*minmax.second; k++){
                
                lid.push_back({map.first, atJ, k});
          }
        }

        return lid;
    }





    
    std::vector<Pos2d<T>> getBoxOnRadius2D(double angle, T outerRadius, T innerRadius, T thickness, T iCenter, T kCenter){
        
        
        Line<T> outerEdge = getPerpendicularEdgeToRadius2D(angle, outerRadius, thickness, iCenter, kCenter);
        Line<T> innerEdge = getPerpendicularEdgeToRadius2D(angle, innerRadius, thickness, iCenter, kCenter);

        std::vector<Pos2d<T>> outerEdgePoints = getBresenhamLine2D(outerEdge.x0, outerEdge.y0, outerEdge.x1, outerEdge.y1);
        std::vector<Pos2d<T>> innerEdgePoints = getBresenhamLine2D(innerEdge.x0, innerEdge.y0, innerEdge.x1, innerEdge.y1);


        std::vector<Pos2d<T>> sidePointsPos = getBresenhamLine2D(outerEdge.x0, outerEdge.y0, innerEdge.x0, innerEdge.y0);
        std::vector<Pos2d<T>> sidePointsNeg = getBresenhamLine2D(innerEdge.x1, innerEdge.y1, outerEdge.x1, outerEdge.y1);
        

        std::vector<Pos2d<T>> box;
        
        for (const auto& p: outerEdgePoints){
            box.push_back({p.x, p.y});
        }
        for (const auto& p: innerEdgePoints){
            box.push_back({p.x, p.y});
        }
        for (const auto& p: sidePointsPos){
            box.push_back({p.x, p.y});
        }
        for (const auto& p: sidePointsNeg){
            box.push_back({p.x, p.y});
        }


        
        return box;
    }





    
    std::vector<Pos3d<T>> getThickHollowDisc(T innerRadius, T outerRadius, T height, T bottom, T iCenter, T kCenter) {

        std::vector<Pos3d<T>> thickHollowDisc;

        std::vector<Pos3d<T>> wall = getCylinderWallIK(outerRadius, height, bottom, iCenter, kCenter);

        for (const auto& v: wall){
            thickHollowDisc.push_back(v);
        }
            
        
        std::vector<Pos3d<T>> top_cap = drawHollowDiscIK(bottom+height, innerRadius, outerRadius, iCenter, kCenter);
        std::vector<Pos3d<T>> bottom_cap = drawHollowDiscIK(bottom, innerRadius, outerRadius, iCenter, kCenter);

        for (const auto& v: top_cap){
            thickHollowDisc.push_back(v);
        }

        for (const auto& v: bottom_cap){
            thickHollowDisc.push_back(v);
        }

        return thickHollowDisc;
    }


    
    std::vector<Pos3d<T>> drawHollowDiscIK(T atj, T innerRadius, T outerRadius, T iCenter, T kCenter) {


        std::vector<Pos3d<T>> disk3d;
        
        std::map<T, std::vector<T>> outerCircle2d = midPointCircle2Dmap(outerRadius, iCenter, kCenter);
        std::map<T, std::vector<T>> innerCircle2d = midPointCircle2Dmap(innerRadius, iCenter, kCenter);


        
        for ( const auto &outer : outerCircle2d ) {

            T outerX = outer.first;

            auto minmaxOuterY = std::minmax_element(outer.second.begin(), outer.second.end());

            
            if (innerCircle2d.count(outerX) > 0){
            
                std::vector<T> innerYs = innerCircle2d[outerX];
                
                auto minmaxInnerY = std::minmax_element(innerYs.begin(), innerYs.end());

                
                for (T k=*minmaxOuterY.first; k<=*minmaxInnerY.first; k++){
        
                    disk3d.push_back(Pos3d<T>{outerX, atj, k});
                }
                for (T k=*minmaxInnerY.second; k<=*minmaxOuterY.second; k++){
                    
                    disk3d.push_back({outerX, atj, k});
                }
                
                
            }else{
                for (T k=*minmaxOuterY.first; k<=*minmaxOuterY.second; k++){
                    
                    disk3d.push_back({outerX, atj, k});
                }
            }
                
        }
                
        
        return disk3d;
    }




    
    std::vector<Pos3d<T>> drawDiscIK(T atj, T radius, T iCenter, T kCenter) {

        std::vector<Pos3d<T>> disk3d;
        
        std::map<T, std::vector<T>> circle2d = midPointCircle2Dmap(radius, iCenter, kCenter);
        
        for ( const auto &map : circle2d ) {
            
            auto minmax = std::minmax_element(map.second.begin(), map.second.end());


            for (T k=*minmax.first; k<=*minmax.second; k++){
                
                disk3d.push_back(Pos3d<T>{map.first, atj, k});
          }
        }
        return disk3d;
    }


    
    std::vector<Pos3d<T>> getCylinderWallIK(T radius, T height, T bottom, T iCenter, T kCenter) {

        std::vector<Pos3d<T>> cylinder;

        std::vector<Pos2d<T>> circumference = midPointCircle2D(radius, iCenter, kCenter);

        for (T j=bottom; j<bottom+height; j++){
            for (const auto& v: circumference){
                
                cylinder.push_back(Pos3d<T>{v.x, j, v.y});
            }
        }
            
        return cylinder;
    }
            



    
    std::vector<Pos3d<T>> drawCircleIK(T atj, T radius, T iCenter, T kCenter) {

        std::vector<Pos3d<T>> circle3d;
        
        std::vector<Pos2d<T>> circle2d = midPointCircle2D(radius, iCenter, kCenter);
        
        for ( const auto &p : circle2d ) {
            circle3d.push_back(Pos3d<T>{p.x, atj, p.y});
        }
        
        return circle3d;
    }






    
    std::vector<Pos3d<T>> midPointEllipse2D(T xRadius, T yRadius, T xCenter, T yCenter){
        //Author: Darshan Gajara
        //http://www.pracspedia.com/CG/midpointellipse.html

        
        std::vector<Pos2d<T>> pts;

        
        T xc = xCenter;
        T yc = yCenter;
        
        long rx = xRadius;
        long ry = yRadius;

        T x, y;
        double p;


       //Region 1
        p=ry*ry-rx*rx*ry+rx*rx/4;
        x=0;
        y=ry;
        
        while(2.0*ry*ry*x <= 2.0*rx*rx*y){
        if (p < 0){
            x++;
            p = p+2*ry*ry*x+ry*ry;
        } else {
        
            x++;y--;
            p = p+2*ry*ry*x-2*rx*rx*y-ry*ry;
        }
            pts.push_back({xc+x,yc+y});
            pts.push_back({xc+x,yc-y});
            
            pts.push_back({xc-x,yc+y});
            pts.push_back({xc-x,yc-y});
        }

        
        //Region 2
        p=ry*ry*(x+0.5)*(x+0.5)+rx*rx*(y-1)*(y-1)-rx*rx*ry*ry;
        while(y > 0){
        if(p <= 0){
            x++;y--;
            p = p+2*ry*ry*x-2*rx*rx*y+rx*rx;
        } else {
            y--;
            p = p-2*rx*rx*y+rx*rx;
        }
        pts.push_back({xc+x,yc+y});
        pts.push_back({xc+x,yc-y});
            
        pts.push_back({xc-x,yc+y});
        pts.push_back({xc-x,yc-y});


        return pts;
        }
    }







    
    std::map<T, std::vector<T>> midPointCircle2Dmap(T radius, T xCenter, T yCenter) {
        //MidPoint Circle Algorithm
        //https://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm
        
        //TOFIX last 4 points are repeated
        
        T f = 1 - radius;
        T ddF_x = 0;
        T ddF_y = -2 * radius;
        T x = 0;
        T y = radius;
     

        std::map<T, std::vector<T>> pts;
        
        for (T x=xCenter-radius; x<xCenter+radius; x++){
            pts[x] = {};
        }

        
        pts[xCenter].push_back(yCenter + radius);
        pts[xCenter].push_back(yCenter - radius);
        pts[xCenter + radius].push_back(yCenter);
        pts[xCenter - radius].push_back(yCenter);

        
        while(x < y)
        {
            if(f >= 0)
            {
                y--;
                ddF_y += 2;
                f += ddF_y;
            }
            x++;
            ddF_x += 2;
            f += ddF_x + 1;
            
            
            pts[xCenter + x].push_back(yCenter + y);
            pts[xCenter - x].push_back(yCenter + y);
            pts[xCenter + x].push_back(yCenter - y);
            pts[xCenter - x].push_back(yCenter - y);
            
            pts[xCenter + y].push_back(yCenter + x);
            pts[xCenter - y].push_back(yCenter + x);
            pts[xCenter + y].push_back(yCenter - x);
            pts[xCenter - y].push_back(yCenter - x);

        }
        
        return pts;
    }



    
    std::vector<Pos2d<T>> midPointCircle2D(T radius, T xCenter, T yCenter) {
        //MidPoint Circle Algorithm
        //https://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm
        
        std::vector<Pos2d<T>> pts;
        
        //TOFIX last 4 points are repeated

        
        T f = 1 - radius;
        T ddF_x = 0;
        T ddF_y = -2 * radius;
        T x = 0;
        T y = radius;

        pts.push_back({xCenter, yCenter + radius});
        pts.push_back({xCenter, yCenter - radius});
        pts.push_back({xCenter + radius, yCenter});
        pts.push_back({xCenter - radius, yCenter});

        while(x < y)
        {
            if(f >= 0)
            {
                y--;
                ddF_y += 2;
                f += ddF_y;
            }
            x++;
            ddF_x += 2;
            f += ddF_x + 1;
            pts.push_back({xCenter + x, yCenter + y});
            pts.push_back({xCenter + x, yCenter - y});
            pts.push_back({xCenter - x, yCenter + y});
            pts.push_back({xCenter - x, yCenter - y});

            
            pts.push_back({xCenter + y, yCenter + x});
            pts.push_back({xCenter + y, yCenter - x});
            pts.push_back({xCenter - y, yCenter - x});
            pts.push_back({xCenter - y, yCenter + x});

        }
        
        return pts;
    }

    
    Line<T> getPerpendicularEdgeToRadius2D(double angle, T radius, T halfThickness, T xCenter, T yCenter){
        
        T midPointEdgeX = xCenter + radius * cos(angle);
        T midPointEdgeY = yCenter + radius * sin(angle);

        double edgeAngle = angle + 0.5 * M_PI;
        
        T x0 = midPointEdgeX - halfThickness * cos(edgeAngle);
        T y0 = midPointEdgeY - halfThickness * sin(edgeAngle);

        T x1 = midPointEdgeX + halfThickness * cos(edgeAngle);
        T y1 = midPointEdgeY + halfThickness * sin(edgeAngle);
     
        return Line<T>{x0, y0, x1, y1};
    }




    
    std::vector<Pos2d<T>> getBresenhamLine2D(T x0, T y0, T x1, T y1)
    {
        //Bresenham's line algorithm
        //http://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#C.2B.2B
        std::vector<Pos2d<T>> line;


        const bool steep = (fabs(y1 - y0) > fabs(x1 - x0));
        if(steep)
        {
            std::swap(x0, y0);
            std::swap(x1, y1);
        }

        if(x0 > x1)
        {
        std::swap(x0, x1);
        std::swap(y0, y1);
        }

        const T dx = x1 - x0;
        const T dy = fabs(y1 - y0);

        T error = dx / 2.0f;
        const T ystep = (y0 < y1) ? 1 : -1;
        T y = (T)y0;

        const T maxX = (int)x1;

        for(T x=(T)x0; x<=maxX; x++){
            Pos2d<T> pt;

            if(steep) {
                line.push_back(pt = {y, x});
            } else {
                line.push_back(pt = {x, y});
            }

            error -= dy;
            
            if(error < 0){
                y += ystep;
                error += dx;
            }
        }
        return line;
    }
     
};//end of class
