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
    self.physicsBody.collisionType = @"lightning";
}
@end
