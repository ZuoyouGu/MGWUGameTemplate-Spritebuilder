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
    [super setLives:2];
    [super setForce:2000];
    [super setScore:4];
    self.physicsBody.collisionType = @"fire";
    self.scaleX = 0.4;
    self.scaleY = 0.4;
}
@end
