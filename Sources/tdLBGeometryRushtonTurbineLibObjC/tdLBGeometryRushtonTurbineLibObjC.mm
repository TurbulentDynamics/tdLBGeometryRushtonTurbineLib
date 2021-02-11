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

@implementation Pos3d_int

-(instancetype)init:(Pos3d<int>*)point {
    
    self = [super init];
    if (self) {
        self.i = point-> i;
        self.j = point-> j;
        self.k = point-> k;
    }
    
    return self;
}

-(NSString *)description {

    return [NSString stringWithFormat:@"point i: %d j: %d k: %d", self.i, self.j, self.k];
}

@end

@implementation tdLBGeometryRushtonTurbineLibObjC

-(instancetype)init:(RushtonTurbineObjC*)turbineData_ ext:(ExtentsObjC*) ext_ {
    
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

-(void)generateRotatingNonUpdatingGeometry {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> generateRotatingNonUpdatingGeometry();
}

-(void)generateRotatingGeometry:(double)atTheta {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> generateRotatingGeometry(atTheta);
}

-(void)updateRotatingGeometry:(double)atTheta {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    rushtonTurbineMidPointCPP-> updateRotatingGeometry(atTheta);
}

-(NSArray<Pos3d_int*>*)returnFixedGeometry {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    NSMutableArray<Pos3d_int*>* result = @[].mutableCopy;
    
    std::vector<Pos3d<int>> resultCPP = rushtonTurbineMidPointCPP-> returnFixedGeometry();
    
    for (auto&& pointCPP : resultCPP)
    {
        Pos3d_int* newPoint = [[Pos3d_int alloc] init:&pointCPP];
        [result addObject:newPoint];
    }

    return result;
}

-(NSArray<Pos3d_int*>*)returnRotatingNonUpdatingGeometry {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    NSMutableArray<Pos3d_int*>* result = @[].mutableCopy;
    
    std::vector<Pos3d<int>> resultCPP = rushtonTurbineMidPointCPP-> returnRotatingNonUpdatingGeometry();
    
    for (auto&& pointCPP : resultCPP)
    {
        Pos3d_int* newPoint = [[Pos3d_int alloc] init:&pointCPP];
        [result addObject:newPoint];
    }

    return result;
}

-(NSArray<Pos3d_int*>*)returnRotatingGeometry {
    RushtonTurbineMidPointCPP<int>* rushtonTurbineMidPointCPP = (RushtonTurbineMidPointCPP<int>*) self.rushtonTurbineMidPointCPP;

    NSMutableArray<Pos3d_int*>* result = @[].mutableCopy;
    
    std::vector<Pos3d<int>> resultCPP = rushtonTurbineMidPointCPP-> returnRotatingGeometry(0.0);
    
    for (auto&& pointCPP : resultCPP)
    {
        Pos3d_int* newPoint = [[Pos3d_int alloc] init:&pointCPP];
        [result addObject:newPoint];
    }

    return result;
}

@end
