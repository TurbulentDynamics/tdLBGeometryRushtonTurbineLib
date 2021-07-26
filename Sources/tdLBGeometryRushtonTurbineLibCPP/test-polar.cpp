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
    
    tNi gridX = 500;
    
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

    file << "ply\nformat ascii 1.0\nelement vertex " << geomCPP.size();
    file << "\nproperty int x\nproperty int y\nproperty int z\nend_header\n";
    
    for (auto&& p : geomCPP){
        file << p.i <<" " << p.j << " " << p.k << "\n";
    }
    file.close();

    
    return 0;
}
