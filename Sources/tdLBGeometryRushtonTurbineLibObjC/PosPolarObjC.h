//
//  PosPolarObjC.h
//  
//
//  Created by Vedran Ozir on 16/03/2021.
//

#import <Foundation/Foundation.h>

@class RushtonTurbineObjC;
@class ExtentsObjC;

@interface PosPolarObjC : NSObject

@property void* PosPolarCPP;

-(instancetype)init:(double)iFP j:(int)j kFP:(double)kFP;

@end
