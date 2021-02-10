//
//  MyClass.h
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

#import <Foundation/Foundation.h>

//#import "RushtonTurbineObjC.h"

@interface ExtentsObjC : NSObject

@property void* extentsCPP; // Extents<int>*

-(instancetype)init:(int)x0 x1:(int)x1 y0:(int)y0 y1:(int)y1 z0:(int)z0 z1:(int)z1;

@end
