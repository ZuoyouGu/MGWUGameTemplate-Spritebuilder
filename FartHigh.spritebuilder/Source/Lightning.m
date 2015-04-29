//
//  Lightning.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Lightning.h"

@implementation Lightning {
    int _lives;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"lightning";
    _lives = 3;
}

- (BOOL)dead {
    return _lives == 0;
}

- (void)minusLive {
    _lives--;
}
@end
