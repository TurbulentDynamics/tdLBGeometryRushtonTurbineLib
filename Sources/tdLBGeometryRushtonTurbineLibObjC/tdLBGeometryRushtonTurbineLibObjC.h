//
//  MyClass.h
//  
//
//  Created by Vedran Ozir on 18.01.2021..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RushtonTurbineObjC;
@class ExtentsObjC;

@interface Pos3d_int : NSObject {
    int i;
    int j;
    int k;
}

@end

@interface tdLBGeometryRushtonTurbineLibObjC : NSObject

@property void* rushtonTurbineMidPointCPP; // RushtonTurbineMidPointCPP<NSObject*>*

-(instancetype)init:(RushtonTurbineObjC*)turbineData ext:(ExtentsObjC*) ext;

-(void)generateFixedGeometry;
-(void)generateRotatingGeometryNonUpdating;
-(void)generateRotatingGeometry:(double)atTheta;
-(void)updateRotatingGeometry:(double)atTheta;

-(NSArray<Pos3d_int*>*)returnFixedGeometry;
-(NSArray<Pos3d_int*>*)returnRotatingGeometryNonUpdating;
-(NSArray<Pos3d_int*>*)returnRotatingGeometry;

@end

NS_ASSUME_NONNULL_END
