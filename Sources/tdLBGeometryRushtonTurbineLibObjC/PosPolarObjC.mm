//
//  PosPolarObjC.mm
//  
//
//  Created by Vedran Ozir on 16/03/2021.
//

#import "PosPolarObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomPolarLegacy.hpp"

@implementation PosPolarObjC

-(instancetype)init:(double)iFP j:(int)j kFP:(double)kFP {
    
    self = [super init];
    if (self) {

        self.PosPolarCPP = new PosPolar<int,int>(iFP, j, kFP);
    }
    
    return self;
}

@end
