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

@interface tdLBGeometryRushtonTurbineLibObjC : NSObject

@property void* rushtonTurbineMidPointCPP; // RushtonTurbineMidPointCPP<NSObject*>*

-(instancetype)init:(RushtonTurbineObjC*)turbineData ext:(ExtentsObjC*) ext;

-(void)generateFixedGeometry;
-(void)generateRotatingGeometryNonUpdating;
-(void)generateRotatingGeometry:(double)atTheta;
-(void)updateRotatingGeometry:(double)atTheta;

//-(void)returnFixedGeometry;
//-(void)returnRotatingGeometryNonUpdating;
//-(void)returnRotatingGeometry;


@end

NS_ASSUME_NONNULL_END
