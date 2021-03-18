//
//  RushtonTurbinePolarObjC.h
//  
//
//  Created by Vedran Ozir on 16/03/2021.
//

#import <Foundation/Foundation.h>
#import "PosPolar_int.h"

NS_ASSUME_NONNULL_BEGIN

@class RushtonTurbineObjC;
@class ExtentsObjC;

@interface RushtonTurbinePolarObjC : NSObject

@property void* RushtonTurbinePolarCPP;

-(instancetype)init:(RushtonTurbineObjC*)turbineData_ ext:(ExtentsObjC*)ext_;

-(void)generateFixedGeometry;
-(void)generateRotatingNonUpdatingGeometry;
-(void)generateRotatingGeometry:(double)atTheta;
-(void)updateRotatingGeometry:(double)atTheta;

-(NSArray<PosPolar_int*>*)returnFixedGeometry;
-(NSArray<PosPolar_int*>*)returnRotatingNonUpdatingGeometry;
-(NSArray<PosPolar_int*>*)returnRotatingGeometry;

@end

NS_ASSUME_NONNULL_END
