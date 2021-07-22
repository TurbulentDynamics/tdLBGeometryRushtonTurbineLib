//
//  File.cpp
//
//
//  Created by Niall Ó Broin on 05/01/2021.
//

#pragma once

#include <iostream>
#include <vector>
#include <map>
#include <fstream>
#include <algorithm>
#include <cmath>


#include "json.h"

using tStepRT = uint64_t;
using tGeomShapeRT = double;

//TODO Fix this
#define MDIAM_BORDER 2




struct Baffles
{
    int numBaffles = 0;

    double firstBaffleOffset = 0.0;

    int innerRadius = 0;
    int outerRadius = 0;
    int thickness = 0; // Half thickness a.k.a. symmetric thickness
};


struct Blades
{
    int innerRadius = 0.0;
    int outerRadius = 0.0;
    int bottom = 0.0;
    int top = 0.0;
    int thickness = 0.0;
};


struct Disk
{
    int radius = 0.0;
    int bottom = 0.0;
    int top = 0.0;
};


struct Impeller
{
    int numBlades = 0;

    // first blade starting angle impeller
    double firstBladeOffset = 0.0;

    //Normal velocity at impeller tip
    double uav = 0.0;

    // max speed
    double bladeTipAngularVelW0 = 0.0;

    //impeller height
    int impellerPosition = 0.0;


    Blades blades;
    Disk disk;
    Disk hub;
};


struct Shaft
{
    int radius = 0.0;
    int bottom = 0.0;
    int top = 0.0;
};





class RushtonTurbine
{
public:
    


    // Current step angular velocity impeller
    double wa = 0.0;



    tStepRT startingStep = 0;
    int impellerStartAngle = 0.0;
    tStepRT impellerStartupStepsUntilNormalSpeed = 0;


    // Model resolution
    double resolution = 0.0;
    int tankDiameter = 0.0;

    Baffles baffles;

    int numImpellers;
    std::vector<Impeller> impellers;
    using size_type=std::vector<Impeller>::size_type;
    
    Shaft shaft;


    RushtonTurbine(int gridX=300){
        setHartmannDerksenProportions(gridX);
    }
    
    void loadGeometryConfigAsJSON(std::string filePath){


        try {
            std::ifstream in(filePath.c_str());
            Json::Value jsonParams;
            in >> jsonParams;
            in.close();

            wa = (double)jsonParams["wa"].asDouble();

            resolution = (double)jsonParams["resolution"].asDouble();
            tankDiameter = (int)jsonParams["tankDiameter"].asInt();


            startingStep = (tStepRT)jsonParams["startingStep"].asUInt64();
            impellerStartAngle = (double)jsonParams["impellerStartAngle"].asDouble();
            impellerStartupStepsUntilNormalSpeed = (tStepRT)jsonParams["impellerStartupStepsUntilNormalSpeed"].asUInt64();



            baffles.numBaffles = jsonParams["baffles"]["numBaffles"].asInt();
            baffles.firstBaffleOffset = jsonParams["baffles"]["firstBaffleOffset"].asDouble();
            baffles.innerRadius = jsonParams["baffles"]["innerRadius"].asInt();
            baffles.outerRadius = jsonParams["baffles"]["outerRadius"].asInt();
            baffles.thickness = jsonParams["baffles"]["thickness"].asInt();


            numImpellers = (int)jsonParams["numImpellers"].asInt();

            impellers.clear();
                
            for (int imp=0; imp<numImpellers; imp++){
                
                auto impStr = "impeller" + std::to_string(imp);
                if (!jsonParams.isMember(impStr)) {
                    // if impeller#i doesn't exists, this means we have numImpellers wrong value;
                    break;
                }
                impellers.push_back(Impeller());
                
                impellers[imp].firstBladeOffset = jsonParams[impStr]["firstBladeOffset"].asDouble();
                impellers[imp].uav = jsonParams[impStr]["uav"].asDouble();
                impellers[imp].bladeTipAngularVelW0 = jsonParams[impStr]["blade_tip_angular_vel_w0"].asDouble();
                impellers[imp].impellerPosition = jsonParams[impStr]["impeller_position"].asInt();
                impellers[imp].numBlades = jsonParams[impStr]["numBlades"].asInt();


                impellers[imp].blades.innerRadius = jsonParams[impStr]["blades"]["innerRadius"].asInt();
                impellers[imp].blades.outerRadius = jsonParams[impStr]["blades"]["outerRadius"].asInt();
                impellers[imp].blades.bottom = jsonParams[impStr]["blades"]["bottom"].asInt();
                impellers[imp].blades.top = jsonParams[impStr]["blades"]["top"].asInt();
                impellers[imp].blades.thickness = jsonParams[impStr]["blades"]["bladeThickness"].asInt();

                impellers[imp].disk.radius = jsonParams[impStr]["disk"]["radius"].asInt();
                impellers[imp].disk.bottom = jsonParams[impStr]["disk"]["bottom"].asInt();
                impellers[imp].disk.top = jsonParams[impStr]["disk"]["top"].asInt();

                impellers[imp].hub.radius = jsonParams[impStr]["hub"]["radius"].asInt();
                impellers[imp].hub.bottom = jsonParams[impStr]["hub"]["bottom"].asInt();
                impellers[imp].hub.top = jsonParams[impStr]["hub"]["top"].asInt();
            }
            
            numImpellers = impellers.size();

            shaft.radius = jsonParams["shaft"]["radius"].asInt();
            shaft.bottom = jsonParams["shaft"]["bottom"].asInt();
            shaft.top = jsonParams["shaft"]["top"].asInt();

        }
        catch(std::exception& e)
        {
            std::cerr << "Unhandled Exception reached parsing arguments: "
            << e.what() << ", application will now exit" << std::endl;
        }
    }
    

    int saveGeometryConfigAsJSON(std::string filePath){

        try {

            Json::Value jsonParams;


//            jsonParams["name"] = "GeometryConfig";

            jsonParams["wa"] = wa;

            jsonParams["function"] = "saveGeometryConfigAsJSON";

            jsonParams["gridX"] = tankDiameter + MDIAM_BORDER;

            jsonParams["resolution"] = resolution;
            jsonParams["tankDiameter"] = tankDiameter;


            jsonParams["startingStep"] = startingStep;
            jsonParams["impellerStartAngle"] = impellerStartAngle;
            jsonParams["impellerStartupStepsUntilNormalSpeed"] = impellerStartupStepsUntilNormalSpeed;



            jsonParams["baffles"]["numBaffles"] = baffles.numBaffles;
            jsonParams["baffles"]["firstBaffleOffset"] = baffles.firstBaffleOffset;
            jsonParams["baffles"]["innerRadius"] = baffles.innerRadius;
            jsonParams["baffles"]["outerRadius"] = baffles.outerRadius;
            jsonParams["baffles"]["thickness"] = baffles.thickness;




            jsonParams["numImpellers"] = (int)numImpellers;

            for (size_type imp=0; imp<impellers.size(); imp++){

                auto impStr = "impeller" + std::to_string(imp);

                jsonParams[impStr]["firstBladeOffset"] = impellers[imp].firstBladeOffset;
                jsonParams[impStr]["uav"] = impellers[imp].uav;
                jsonParams[impStr]["blade_tip_angular_vel_w0"] = impellers[imp].bladeTipAngularVelW0;
                jsonParams[impStr]["impeller_position"] = impellers[imp].impellerPosition;
                jsonParams[impStr]["numBlades"] = impellers[imp].numBlades;

                jsonParams[impStr]["blades"]["innerRadius"] = impellers[imp].blades.innerRadius;
                jsonParams[impStr]["blades"]["outerRadius"] = impellers[imp].blades.outerRadius;
                jsonParams[impStr]["blades"]["bottom"] = impellers[imp].blades.bottom;
                jsonParams[impStr]["blades"]["top"] = impellers[imp].blades.top;
                jsonParams[impStr]["blades"]["bladeThickness"] = impellers[imp].blades.thickness;

                jsonParams[impStr]["disk"]["radius"] = impellers[imp].disk.radius;
                jsonParams[impStr]["disk"]["bottom"] = impellers[imp].disk.bottom;
                jsonParams[impStr]["disk"]["top"] = impellers[imp].disk.top;

                jsonParams[impStr]["hub"]["radius"] = impellers[imp].hub.radius;
                jsonParams[impStr]["hub"]["bottom"] = impellers[imp].hub.bottom;
                jsonParams[impStr]["hub"]["top"] = impellers[imp].hub.top;

            }

            jsonParams["shaft"]["radius"] = shaft.radius;
            jsonParams["shaft"]["bottom"] = shaft.bottom;
            jsonParams["shaft"]["top"] = shaft.top;


            std::ofstream out(filePath.c_str(), std::ofstream::out);
            out << jsonParams;
            out.close();

            return 0;
        }
        catch(std::exception& e) {
            std::cerr << "Unhandled Exception reached parsing arguments: "
            << e.what() << ", application will now exit" << std::endl;
            return 1;
        }

        return 0;
    }


    void printGeometry(){
        
        std::cout << "name" << " GeometryConfig" << std::endl;

        std::cout << "function" << " saveGeometryConfigAsJSON" << std::endl;

        std::cout << "gridX " << tankDiameter + MDIAM_BORDER << std::endl;

        std::cout << "resolution " << resolution << std::endl;
        std::cout << "tankDiameter " << tankDiameter << std::endl;


        std::cout << "startingStep " << startingStep << std::endl;
        std::cout << "impellerStartAngle " << impellerStartAngle << std::endl;
        std::cout << "impellerStartupStepsUntilNormalSpeed " << impellerStartupStepsUntilNormalSpeed << std::endl;



        std::cout << "baffles.numBaffles " << baffles.numBaffles << std::endl;
        std::cout << "baffles.firstBaffleOffset " << baffles.firstBaffleOffset << std::endl;
        std::cout << "baffles.innerRadius " << baffles.innerRadius << std::endl;
        std::cout << "baffles.outerRadius " << baffles.outerRadius << std::endl;
        std::cout << "baffles.thickness " << baffles.thickness << std::endl;




        std::cout << "numImpellers " << numImpellers << std::endl;

        for (size_type imp=0; imp<impellers.size(); imp++){
            

            std::cout << "impeller.0.firstBladeOffset " << impellers[imp].firstBladeOffset << std::endl;
            std::cout << "impeller.0.uav " << impellers[imp].uav << std::endl;
            std::cout << "impeller.0.blade_tip_angular_vel_w0 " << impellers[imp].bladeTipAngularVelW0 << std::endl;
            std::cout << "impeller.0.impeller_position " << impellers[imp].impellerPosition << std::endl;

            std::cout << "impeller.0.blades.innerRadius " << impellers[imp].blades.innerRadius << std::endl;
            std::cout << "impeller.0.blades.outerRadius " << impellers[imp].blades.outerRadius << std::endl;
            std::cout << "impeller.0.blades.bottom " << impellers[imp].blades.bottom << std::endl;
            std::cout << "impeller.0.blades.top " << impellers[imp].blades.top << std::endl;
            std::cout << "impeller.0.blades.bladeThickness " << impellers[imp].blades.thickness << std::endl;

            std::cout << "impeller.0.disk.radius " << impellers[imp].disk.radius << std::endl;
            std::cout << "impeller.0.disk.bottom " << impellers[imp].disk.bottom << std::endl;
            std::cout << "impeller.0.disk.top " << impellers[imp].disk.top << std::endl;

            std::cout << "impeller.0.hub.radius " << impellers[imp].hub.radius << std::endl;
            std::cout << "impeller.0.hub.bottom " << impellers[imp].hub.bottom << std::endl;
            std::cout << "impeller.0.hub.top " << impellers[imp].hub.top << std::endl;

        }


    }
    
    
    void setGillissenProportions(int gridX=300, tGeomShapeRT uav=0.1) {
        
        resolution = 0.7f;

        //diameter tube / cylinder
        tankDiameter = gridX - MDIAM_BORDER;

        shaft.radius = (int)(tankDiameter * 2.0f / 75.0f);


        baffles.numBaffles = 4;

        //First baffle is offset by 1/8 of revolution, or 1/2 of the delta between baffles.
        baffles.firstBaffleOffset = (tGeomShapeRT)(((2.0 * M_PI) / (tGeomShapeRT)baffles.numBaffles) * 0.5);

        baffles.innerRadius = 0.3830f * tankDiameter;
        baffles.outerRadius = 0.4830f * tankDiameter;
        baffles.thickness = tankDiameter / 75.0f;


        numImpellers = 1;

        Impeller impeller;
        impeller.impellerPosition = (int)(gridX * (2.0f / 3.0f));
        impeller.numBlades = 6;
        impeller.firstBladeOffset = 0.0f;
        impeller.uav = uav;


        
        
        Blades blades;
        blades.innerRadius = tankDiameter / 12.0f;
        blades.outerRadius = tankDiameter / 6.0f;

        // bottom height impeller blade
        blades.top = tankDiameter * 19.0f / 30.f;
        blades.bottom = tankDiameter * 21.0f / 30.f;


        blades.thickness = tankDiameter / 75.0f;

        impeller.blades = blades;

        
        
        // Eventual angular velocity impeller
        impeller.bladeTipAngularVelW0 = impeller.uav / blades.outerRadius;


        Disk disk;
        disk.radius = tankDiameter / 8.0f;
        disk.top = tankDiameter * 99.0f / 150.0f;
        disk.bottom = tankDiameter * 101.0f / 150.0f;
        impeller.disk = disk;
        
        
        Disk hub;
        hub.radius = tankDiameter * 4.0f / 75.0f;
        hub.top = tankDiameter * 19.f / 30.0f;
        hub.bottom = tankDiameter * 21.0f / 30.0f;
        impeller.hub = hub;

        impellers.clear();
        impellers.push_back(impeller);


    }

    
    void setHartmannDerksenProportions(int gridX=300, tGeomShapeRT uav=0.1) {
        
        resolution = 0.7f;

        //diameter tube / cylinder
        tankDiameter = gridX - MDIAM_BORDER;
        
        
        //Principal Parameters defined from
        //Hartmann H, Derksen JJ, Montavon C, Pearson J, Hamill IS, Van den Akker HEA. Assessment of large eddy and rans stirred tank simulations by means of LDA. Chem Eng Sci. 2004;59:2419–2432.
        int tankRadius = tankDiameter / 2.0;
        int impellerPosition = gridX * (2.0 / 3.0);
        int D = tankDiameter / 3.0;

        
        
        shaft.radius = D * 0.08;


        baffles.numBaffles = 4;

        //First baffle is offset by 1/8 of revolution, or 1/2 of the delta between baffles.
        baffles.firstBaffleOffset = (tGeomShapeRT)(((2.0 * M_PI) / (tGeomShapeRT)baffles.numBaffles) * 0.5);

        baffles.innerRadius = tankRadius - (tankDiameter * 0.017) - (tankDiameter * 0.1);
        baffles.outerRadius = tankRadius - (tankDiameter * 0.017);
        baffles.thickness = tankDiameter / 75.0f;


        numImpellers = 1;

        Impeller impeller;
        impeller.impellerPosition = impellerPosition;
        impeller.numBlades = 6;
        impeller.firstBladeOffset = 0.0f;
        impeller.uav = uav;


        
        Blades blades;
        blades.outerRadius = D / 2.0;
        blades.innerRadius = blades.outerRadius - (D * 0.25);

        // bottom height impeller blade
        blades.top = impellerPosition -  (D * 0.1);
        blades.bottom = impellerPosition + (D * 0.1);


        blades.thickness = D * 0.04;

        impeller.blades = blades;

        
        
        // Eventual angular velocity impeller
        impeller.bladeTipAngularVelW0 = impeller.uav / blades.outerRadius;


        Disk disk;
        disk.radius = D * 0.375;
        disk.top = impellerPosition - (D * 0.02);
        disk.bottom = impellerPosition + (D * 0.02);
        impeller.disk = disk;
        
        
        Disk hub;
        hub.radius = D * 0.16;
        hub.top = impellerPosition - (D * 0.1);
        hub.bottom = impellerPosition + (D * 0.1);
        impeller.hub = hub;

        impellers.clear();
        impellers.push_back(impeller);


    }
    
};




