//
//  Lightning.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Lightning.h"

@implementation Lightning
- (void)didLoadFromCCB {
    [super setLives:3];
    [super setForce:2000];
    [super setScore:6];
    self.physicsBody.collisionType = @"lightning";
    self.scaleX = 0.3;
    self.scaleY = 0.3;
}
@end
