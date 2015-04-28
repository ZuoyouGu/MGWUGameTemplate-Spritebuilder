//
//  Ice.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Ice.h"

@implementation Ice
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"ice";
}
@end
