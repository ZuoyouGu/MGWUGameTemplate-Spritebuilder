//
//  Fire.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Fire.h"

@implementation Fire {
    int _lives;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"fire";
    _lives = 2;
}

- (BOOL)dead {
    return _lives == 0;
}

- (void)minusLive {
    _lives--;
}
@end
