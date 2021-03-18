//
//  RushtonTurbinePolarObjC.h
//  
//
//  Created by Vedran Ozir on 16/03/2021.
//

#import <Foundation/Foundation.h>

@class RushtonTurbineObjC;
@class ExtentsObjC;

@interface RushtonTurbinePolarObjC : NSObject

@property void* RushtonTurbinePolarCPP;

-(instancetype)init:(RushtonTurbineObjC*)turbineData_ ext:(ExtentsObjC*)ext_;

@end
