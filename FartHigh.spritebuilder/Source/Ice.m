//
//  Ice.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Ice.h"

@implementation Ice {
    int _lives;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"ice";
    _lives = 1;
}

- (BOOL)dead {
    return _lives == 0;
}

- (void)minusLive {
    _lives--;
}

@end
