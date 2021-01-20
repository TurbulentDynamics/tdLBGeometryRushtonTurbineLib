//
//  MyClass.m
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

#import "ExtentsObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomMidPoint.hpp"

@implementation ExtentsObjC

-(instancetype)init {
    
    self = [super init];
    if (self) {

        self.extentsCPP = new Extents<int>();
    }
    
    return self;
}

@end
