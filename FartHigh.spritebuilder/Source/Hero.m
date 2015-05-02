//
//  Hero.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hero.h"

#define WIDTH   36
#define HEIGHT  34
@implementation Hero {
    CCNode *_shield;
    CGRect _boundingBox;
    float _width;
    float _height;
    int _bullets;
    int _lives;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"hero";
    self.physicsBody.collisionCategories = @[@"hero"];
    self.physicsBody.collisionMask = @[@"enemy", @"powerup"];
    
    _boundingBox = CGRectMake(0, 0, WIDTH, HEIGHT);
    _bullets = BULLET_NUM_EVERY_TIME;
    [self updateScaleTo:1.0];
    _shield = nil;
    _lives = 1;
}

- (CGRect)boundingBox {
    _boundingBox.origin.x = super.boundingBox.origin.x-(_width/2);
    _boundingBox.origin.y = super.boundingBox.origin.y-(_height/2);
    return _boundingBox;
}

- (void)updateScaleTo: (float)scale {
    self.scaleX = scale;
    self.scaleY = scale;
    _boundingBox.size.width = _width = WIDTH*scale;
    _boundingBox.size.height = _height = HEIGHT*scale;
}

- (void)addBullet:(int)bulletNum {
    _bullets += bulletNum;
}

- (int)bullets {
    return _bullets;
}

- (BOOL)hasBullet {
    return _bullets > 0;
}

- (void)shoot {
    _bullets--;
}

- (void)addShield {
    // remove the old shield first
    [self removeShield];
    
    _shield = [CCBReader load:@"Star"];
    _shield.scale = 1.2;
    [self addChild:_shield];
    _shield.position = ccp(0, 0);
    [self scheduleOnce:@selector(removeShield) delay:SHIELD_EFFECT_TIME];
}

- (void)removeShield {
    [self removeChild:_shield];
    _shield = nil;
}

- (BOOL)hasShield {
    if(_shield!=nil) {
        return true;
    }
    else {
        return false;
    }
}

- (BOOL)hasLives {
    _lives--;
    return _lives>0;
}

- (void)addLives {
    _lives++;
}

- (int)lives {
    return _lives;
}

@end
