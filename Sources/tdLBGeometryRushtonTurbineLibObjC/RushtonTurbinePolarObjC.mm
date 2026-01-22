//
//  RushtonTurbinePolarObjC.mm
//  
//
//  Created by Vedran Ozir on 16/03/2021.
//

#import "ExtentsObjC.h"
#import "RushtonTurbineObjC.h"
#import "RushtonTurbinePolarObjC.h"
#import "../tdLBGeometryRushtonTurbineLibCPP/GeomPolar.hpp"

@implementation PosPolar_int

-(instancetype)init:(PosPolar<int, int>*)point {
    
    self = [super init];
    if (self) {
        self.i = point-> i;
        self.j = point-> j;
        self.k = point-> k;
    }
    
    return self;
}

-(NSString *)description {

    return [NSString stringWithFormat:@"polar point i: %d j: %d k: %d", self.i, self.j, self.k];
}

@end

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

-(void)generateFixedGeometry {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> generateFixedGeometry(onSurface);
}

-(void)generateRotatingNonUpdatingGeometry {
    [self generateRotatingNonUpdatingGeometryWithDeltaTheta:0.0];
}

-(void)generateRotatingNonUpdatingGeometryWithDeltaTheta:(double)deltaTheta {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> generateRotatingNonUpdatingGeometry(deltaTheta, onSurface);
}

-(void)generateRotatingGeometry:(double)atTheta {
    [self generateRotatingGeometry:atTheta deltaTheta:0.0];
}

-(void)generateRotatingGeometry:(double)atTheta deltaTheta:(double)deltaTheta {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> generateRotatingGeometry(atTheta, deltaTheta, onSurface);
}

-(void)updateRotatingGeometry:(double)atTheta {
    [self updateRotatingGeometry:atTheta deltaTheta:0.0];
}

-(void)updateRotatingGeometry:(double)atTheta deltaTheta:(double)deltaTheta {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> updateRotatingGeometry(atTheta, deltaTheta, onSurface);
}

-(NSArray<PosPolar_int*>*)returnFixedGeometry {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    NSMutableArray<PosPolar_int*>* result = @[].mutableCopy;
    
    std::vector<PosPolar<int, int>> resultCPP = rushtonTurbinePolarCPP-> returnFixedGeometry();
    
    for (auto&& pointCPP : resultCPP)
    {
        PosPolar_int* newPoint = [[PosPolar_int alloc] init:&pointCPP];
        
        [result addObject:newPoint];
    }

    return result;
}

-(NSArray<PosPolar_int*>*)returnRotatingNonUpdatingGeometry {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    NSMutableArray<PosPolar_int*>* result = @[].mutableCopy;
    
    std::vector<PosPolar<int, int>> resultCPP = rushtonTurbinePolarCPP-> returnRotatingNonUpdatingGeometry();
    
    for (auto&& pointCPP : resultCPP)
    {
        PosPolar_int* newPoint = [[PosPolar_int alloc] init:&pointCPP];
        [result addObject:newPoint];
    }

    return result;
}

-(NSArray<PosPolar_int*>*)returnRotatingGeometry {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    NSMutableArray<PosPolar_int*>* result = @[].mutableCopy;

    std::vector<PosPolar<int, int>> resultCPP = rushtonTurbinePolarCPP-> returnRotatingGeometry();

    for (auto&& pointCPP : resultCPP)
    {
        PosPolar_int* newPoint = [[PosPolar_int alloc] init:&pointCPP];
        [result addObject:newPoint];
    }

    return result;
}

@end
