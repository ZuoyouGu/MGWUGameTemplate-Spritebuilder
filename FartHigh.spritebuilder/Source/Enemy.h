//
//  Enemy.h
//  FartHigh
//
//  Created by Zuoyou Gu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

#define Width   20
#define Height  20

@interface Enemy : CCNode
- (BOOL)dead;
- (void)minusLive;
- (int)getForce;
- (int)getScore;
- (id)initWithLives:(int) lives withForce: (int) force withScore: (int) score;
- (void)setLives:(int)lives;
- (void)setForce:(int)force;
- (void)setScore:(int)score;
@end
