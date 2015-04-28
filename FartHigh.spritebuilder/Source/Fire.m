//
//  Fire.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Fire.h"

@implementation Fire
- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"fire";
}
@end
