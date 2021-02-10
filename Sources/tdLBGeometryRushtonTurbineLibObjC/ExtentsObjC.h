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

-(instancetype)init:(int)x1 x2:(int)x2 y1:(int)y1 y2:(int)y2 z1:(int)z1 z2:(int)z2;

@end
