//
//  RushtonTurbinePolarObjC.mm
//  
//
//  Created by Vedran Ozir on 16/03/2021.
//

#import "ExtentsObjC.h"
#import "RushtonTurbineObjC.h"
#import "RushtonTurbinePolarObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomPolarLegacy.hpp"

@implementation RushtonTurbinePolarObjC

-(instancetype)init:(RushtonTurbineObjC*)turbineData_ ext:(ExtentsObjC*)ext_ {
    
    self = [super init];
    if (self) {
        RushtonTurbine* turbineData = (RushtonTurbine*)(turbineData_.rushtonTurbineCPP);
        Extents<int>* ext = (Extents<int>*)(ext_.extentsCPP);

        self.RushtonTurbinePolarCPP = new RushtonTurbinePolarCPP<int,int>(*turbineData, *ext);
    }
    
    return self;
}

@end
