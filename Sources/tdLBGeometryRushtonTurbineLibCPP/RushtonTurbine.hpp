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
//#include <nlohmann/json.hpp>

#define tStep int
#define tGeomShape double

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



    tStep startingStep = 0;
    int impellerStartAngle = 0.0;
    tStep impellerStartupStepsUntilNormalSpeed = 0;


    // Model resolution
    double resolution = 0.0;
    int tankDiameter = 0.0;

    Baffles baffles;

    int numImpellers;
    std::vector<Impeller> impellers;
    
    Shaft shaft;


    
    void loadGeometryConfigAsJSON(std::string filepath){


        try {
            std::ifstream in(filepath.c_str());
            Json::Value dim_json;
            in >> dim_json;
            in.close();


            resolution = (double)dim_json["resolution"].asDouble();
            tankDiameter = (int)dim_json["tankDiameter"].asInt();


            startingStep = (tStep)dim_json["starting_step"].asInt();
            impellerStartAngle = (double)dim_json["impeller_start_angle"].asDouble();
            impellerStartupStepsUntilNormalSpeed = (tStep)dim_json["impeller_startup_steps_until_normal_speed"].asInt();



            baffles.numBaffles = dim_json["baffles"]["numBaffles"].asInt();
            baffles.firstBaffleOffset = dim_json["baffles"]["firstBaffleOffset"].asDouble();
            baffles.innerRadius = dim_json["baffles"]["innerRadius"].asInt();
            baffles.outerRadius = dim_json["baffles"]["outerRadius"].asInt();
            baffles.thickness = dim_json["baffles"]["thickness"].asInt();


            numImpellers = (int)dim_json["numImpellers"].asInt();

                
            for (auto imp=0; imp<impellers.size(); imp++){
                
                auto impStr = "impeller" + std::to_string(imp);
                
                impellers[imp].firstBladeOffset = dim_json[impStr]["firstBladeOffset"].asDouble();
                impellers[imp].uav = dim_json[impStr]["uav"].asDouble();
                impellers[imp].bladeTipAngularVelW0 = dim_json[impStr]["blade_tip_angular_vel_w0"].asDouble();
                impellers[imp].impellerPosition = dim_json[impStr]["impeller_position"].asInt();



                impellers[imp].blades.innerRadius = dim_json[impStr]["blades"]["innerRadius"].asInt();
                impellers[imp].blades.outerRadius = dim_json[impStr]["blades"]["outerRadius"].asInt();
                impellers[imp].blades.bottom = dim_json[impStr]["blades"]["bottom"].asInt();
                impellers[imp].blades.top = dim_json[impStr]["blades"]["top"].asInt();
                impellers[imp].blades.thickness = dim_json[impStr]["blades"]["bladeThickness"].asInt();

                impellers[imp].disk.radius = dim_json[impStr]["disk"]["radius"].asInt();
                impellers[imp].disk.bottom = dim_json[impStr]["disk"]["bottom"].asInt();
                impellers[imp].disk.top = dim_json[impStr]["disk"]["top"].asInt();

                impellers[imp].hub.radius = dim_json[impStr]["hub"]["radius"].asInt();
                impellers[imp].hub.bottom = dim_json[impStr]["hub"]["bottom"].asInt();
                impellers[imp].hub.top = dim_json[impStr]["hub"]["top"].asInt();
            }

        }
        catch(std::exception& e)
        {
            std::cerr << "Unhandled Exception reached parsing arguments: "
            << e.what() << ", application will now exit" << std::endl;
        }
    }
    

    int saveGeometryConfigAsJSON(std::string filepath){

        try {

            Json::Value dim_json;


//            dim_json["name"] = "GeometryConfig";

            dim_json["function"] = "saveGeometryConfigAsJSON";

            dim_json["gridX"] = tankDiameter + MDIAM_BORDER;

            dim_json["resolution"] = resolution;
            dim_json["tankDiameter"] = tankDiameter;


            dim_json["startingStep"] = startingStep;
            dim_json["impellerStartAngle"] = impellerStartAngle;
            dim_json["impellerStartupStepsUntilNormalSpeed"] = impellerStartupStepsUntilNormalSpeed;



            dim_json["baffles"]["numBaffles"] = baffles.numBaffles;
            dim_json["baffles"]["firstBaffleOffset"] = baffles.firstBaffleOffset;
            dim_json["baffles"]["innerRadius"] = baffles.innerRadius;
            dim_json["baffles"]["outerRadius"] = baffles.outerRadius;
            dim_json["baffles"]["thickness"] = baffles.thickness;




            dim_json["numImpellers"] = (int)numImpellers;

            for (auto imp=0; imp<impellers.size(); imp++){

                auto impStr = "impeller" + std::to_string(imp);

                dim_json[impStr]["firstBladeOffset"] = impellers[imp].firstBladeOffset;
                dim_json[impStr]["uav"] = impellers[imp].uav;
                dim_json[impStr]["blade_tip_angular_vel_w0"] = impellers[imp].bladeTipAngularVelW0;
                dim_json[impStr]["impeller_position"] = impellers[imp].impellerPosition;

                dim_json[impStr]["blades"]["innerRadius"] = impellers[imp].blades.innerRadius;
                dim_json[impStr]["blades"]["outerRadius"] = impellers[imp].blades.outerRadius;
                dim_json[impStr]["blades"]["bottom"] = impellers[imp].blades.bottom;
                dim_json[impStr]["blades"]["top"] = impellers[imp].blades.top;
                dim_json[impStr]["blades"]["bladeThickness"] = impellers[imp].blades.thickness;

                dim_json[impStr]["disk"]["radius"] = impellers[imp].disk.radius;
                dim_json[impStr]["disk"]["bottom"] = impellers[imp].disk.bottom;
                dim_json[impStr]["disk"]["top"] = impellers[imp].disk.top;

                dim_json[impStr]["hub"]["radius"] = impellers[imp].hub.radius;
                dim_json[impStr]["hub"]["bottom"] = impellers[imp].hub.bottom;
                dim_json[impStr]["hub"]["top"] = impellers[imp].hub.top;

            }


            std::ofstream out(filepath.c_str(), std::ofstream::out);
            out << dim_json;
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

        for (auto imp=0; imp<impellers.size(); imp++){
            

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
    
    
    void setEgglesSomersProportions(int gridX, tGeomShape uav) {
        
        resolution = 0.7f;

        //diameter tube / cylinder
        tankDiameter = gridX - MDIAM_BORDER;

        shaft.radius = (int)(tankDiameter * 2.0f / 75.0f);


        baffles.numBaffles = 4;

        //First baffle is offset by 1/8 of revolution, or 1/2 of the delta between baffles.
        baffles.firstBaffleOffset = (tGeomShape)(((2.0 * M_PI) / (tGeomShape)baffles.numBaffles) * 0.5);

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


        // top height impeller blade
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

        
        impellers.push_back(impeller);


    }

};




