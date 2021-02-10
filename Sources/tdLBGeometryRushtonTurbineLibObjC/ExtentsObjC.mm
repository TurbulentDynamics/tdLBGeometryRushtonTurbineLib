//
//  MyClass.m
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

#import "ExtentsObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomMidPoint.hpp"

@implementation ExtentsObjC

-(instancetype)init:(int)x0 x1:(int)x1 y0:(int)y0 y1:(int)y1 z0:(int)z0 z1:(int)z1  {
    
    self = [super init];
    if (self) {

        self.extentsCPP = new Extents<int>(x0, x1, y0, y1, z0, z1);
    }
    
    return self;
}

@end
