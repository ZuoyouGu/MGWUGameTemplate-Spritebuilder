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
    CGRect _boundingBox;
    float _width;
    float _height;
}

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"hero";
    
    _boundingBox = CGRectMake(0, 0, WIDTH, HEIGHT);
    [self updateScaleTo:1.0];
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
@end
