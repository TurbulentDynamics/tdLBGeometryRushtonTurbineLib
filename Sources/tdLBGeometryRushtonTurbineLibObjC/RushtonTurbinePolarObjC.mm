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

    rushtonTurbinePolarCPP-> generateFixedGeometry();
}

-(void)generateRotatingNonUpdatingGeometry {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> generateRotatingNonUpdatingGeometry();
}

-(void)generateRotatingGeometry:(double)atTheta {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> generateRotatingGeometry(atTheta);
}

-(void)updateRotatingGeometry:(double)atTheta {
    RushtonTurbinePolarCPP<int,int>* rushtonTurbinePolarCPP = (RushtonTurbinePolarCPP<int,int>*) self.RushtonTurbinePolarCPP;

    rushtonTurbinePolarCPP-> updateRotatingGeometry(atTheta);
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
    
    std::vector<PosPolar<int, int>> resultCPP = rushtonTurbinePolarCPP-> returnRotatingGeometry(0.0);
    
    for (auto&& pointCPP : resultCPP)
    {
        PosPolar_int* newPoint = [[PosPolar_int alloc] init:&pointCPP];
        [result addObject:newPoint];
    }

    return result;
}

@end
