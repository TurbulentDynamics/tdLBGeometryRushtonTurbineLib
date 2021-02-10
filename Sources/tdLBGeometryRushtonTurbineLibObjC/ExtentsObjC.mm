//
//  MyClass.m
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

#import "ExtentsObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomMidPoint.hpp"

@implementation ExtentsObjC

-(instancetype)init:(int)x1 x2:(int)x2 y1:(int)y1 y2:(int)y2 z1:(int)z1 z2:(int)z2  {
    
    self = [super init];
    if (self) {

        self.extentsCPP = new Extents<int>(x1, x2, y1, y2, z1, z2);
    }
    
    return self;
}

@end
