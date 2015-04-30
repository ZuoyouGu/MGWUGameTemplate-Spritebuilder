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
    [super setLives:1];
    [super setForce:2000];
    [super setScore:2];
    self.physicsBody.collisionType = @"ice";
    self.scaleX = 0.5;
    self.scaleY = 0.5;
}
@end
