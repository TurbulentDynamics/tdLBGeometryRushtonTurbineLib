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


int main(int argc, char *argv[]){

    bool excludePointsParam = false;
    bool readSize = false;
    tNi gridX = 500;
    for (int i = 1; i < argc; i++) {
        if (readSize) {
            if (sscanf(argv[i], "%ld", &gridX) != 1) {
                std::cerr << "-s has invalid parameter, needs integer" << std::endl;
            }
            readSize = false;
        }
        if (!strcmp(argv[i], "-e")) {
            excludePointsParam = true;
        } else if (!strcmp(argv[i], "-s")) {
            readSize  = true;
        } else {
            std::cerr << argv[i] << " is unknown parameter" << std::endl;
        }
    }
    
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
    file.open("test--polar.ply");

    bool *excludeGeomPoints = new bool[gridX*gridX*gridX];
    if (excludePointsParam) {
        for (auto v : gCPP.getFixedExcludePoints()) {
            excludeGeomPoints[v.i*gridX*gridX + v.j*gridX + v.k] = true;
        }
    }

    if (excludePointsParam) {
        std::vector<PosPolar<tNi, float>> tmp;
        for (auto&& p : geomCPP) {
            if (!excludeGeomPoints[p.i*gridX*gridX + p.j*gridX + p.k]) {
                tmp.push_back(p);
            }
        }
        geomCPP = tmp;
    }

    file << "ply\nformat ascii 1.0\nelement vertex " << geomCPP.size();
    file << "\nproperty int x\nproperty int y\nproperty int z\nend_header\n";

    for (auto&& p : geomCPP){
        file << p.i <<" " << p.j << " " << p.k << "\n";
    }
    file.close();

    
    return 0;
}
