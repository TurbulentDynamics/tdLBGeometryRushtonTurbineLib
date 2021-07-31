//
//  File.swift
//
//
//  Created by Niall Ó Broin on 09/02/2021.
//

#include <iostream>
#include <fstream>
#include <vector>

#include "GeomPolar.hpp"
#include "GlobalStructures.hpp"
#include "RushtonTurbine.hpp"



using tNi = long int;


int main(){
    
    tNi gridX = 200;
    
    RushtonTurbine t = RushtonTurbine((int)gridX);
    
    
    Extents<tNi> e = Extents<tNi>(0, gridX, 0, gridX, 0, gridX);

    RushtonTurbinePolarCPP<tNi, float> gCPP = RushtonTurbinePolarCPP<tNi, float>(t, e);

    gCPP.generateFixedGeometry();
    gCPP.generateRotatingGeometry(0);
    gCPP.generateRotatingNonUpdatingGeometry();

    std::vector<PosPolar<tNi, float>> geomCPP = gCPP.returnFixedGeometry();
    std::vector<PosPolar<tNi, float>> geomCPP0 = gCPP.returnRotatingGeometry();
    std::vector<PosPolar<tNi, float>> geomCPP1 = gCPP.returnRotatingNonUpdatingGeometry();

    
    geomCPP.insert(geomCPP.end(), geomCPP0.begin(), geomCPP0.end());
    geomCPP.insert(geomCPP.end(), geomCPP1.begin(), geomCPP1.end());

    std::ofstream file;
    file.open("test-polar.ply");

    file << "ply\nformat ascii 1.0\nelement vertex " << geomCPP.size();
    file << "\nproperty int x\nproperty int y\nproperty int z\nend_header\n";

    for (auto&& p : geomCPP){
        file << p.i <<" " << p.j << " " << p.k << "\n";
    }
    file.close();




    std::vector<Pos3d<tNi>> excludePts = gCPP.getFixedExcludePoints();
    std::vector<Pos3d<tNi>> exclRotatingNonUpdating = gCPP.getRotatingNonUpdatingExcludePoints();
    std::vector<Pos3d<tNi>> exclRotating = gCPP.getRotatingExcludePoints(0);


    excludePts.insert(excludePts.end(), exclRotatingNonUpdating.begin(), exclRotatingNonUpdating.end());
    excludePts.insert(excludePts.end(), exclRotating.begin(), exclRotating.end());

    std::ofstream fileExcl;
    fileExcl.open("test-polar-exclude.ply");

    fileExcl << "ply\nformat ascii 1.0\nelement vertex " << geomCPP.size() + excludePts.size();
    fileExcl << "\nproperty int x\nproperty int y\nproperty int z\nend_header\n";

    for (auto&& p : excludePts){
        fileExcl << p.i <<" " << p.j << " " << p.k << "\n";
    }

    for (auto&& p : geomCPP){
        fileExcl << p.i <<" " << p.j << " " << p.k << "\n";
    }
    fileExcl.close();




    


    
    return 0;
}
