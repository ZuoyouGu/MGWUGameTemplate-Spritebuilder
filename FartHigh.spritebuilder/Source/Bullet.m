//
//  Bullet.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"bullet";
}

@end
