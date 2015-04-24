//
//  Enemy1.m
//  FartHigh
//
//  Created by Zuoyou Gu on 2/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Enemy1.h"

@implementation Enemy1

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"enemy1";
}

@end
