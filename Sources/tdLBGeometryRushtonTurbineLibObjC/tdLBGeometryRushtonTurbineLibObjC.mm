//
//  MyClass.m
//  
//
//  Created by Vedran Ozir on 18.01.2021..
//

#import "tdLBGeometryRushtonTurbineLibObjC.h"
#import "ExtentsObjC.h"
#import "RushtonTurbineObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomMidPoint.hpp"

//@class RushtonTurbine;

@implementation tdLBGeometryRushtonTurbineLibObjC

-(instancetype)init:(RushtonTurbineObjC*)turbineData_ ext:(ExtentsObjC*) ext_ {
//-(instancetype)init:(void*)turbineData_ ext:(void*)ext_ {
    
    self = [super init];
    if (self) {
        RushtonTurbine* turbineData = (RushtonTurbine*)(turbineData_.rushtonTurbineCPP);
        Extents<int>* ext = (Extents<int>*)(ext_.extentsCPP);

        self.rushtonTurbineMidPointCPP = new RushtonTurbineMidPointCPP<int>( *turbineData, *ext);

    }
    
    return self;
}

-(void)generateFixedGeometry {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> generateFixedGeometry();
}

-(void)generateRotatingGeometryNonUpdating {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> generateRotatingGeometryNonUpdating();
}

-(void)generateRotatingGeometry:(double)atTheta {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> generateRotatingGeometry(atTheta);
}

-(void)updateRotatingGeometry:(double)atTheta {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> updateRotatingGeometry(atTheta);
}



//-(void)returnFixedGeometry {
//    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;
//
//    rushtonTurbineMidPointCPP-> returnFixedGeometry();
//}
//
//-(void)returnRotatingGeometryNonUpdating {
//    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;
//
//    rushtonTurbineMidPointCPP-> returnRotatingGeometryNonUpdating();
//}
//
//-(void)returnRotatingGeometry:(double)atTheta {
//    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;
//
//    rushtonTurbineMidPointCPP-> returnRotatingGeometry(atTheta);
//}


@end
