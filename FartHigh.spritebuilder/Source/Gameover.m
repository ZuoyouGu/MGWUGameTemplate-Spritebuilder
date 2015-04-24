//
//  Gameover.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameover.h"

@implementation Gameover {
    CCLabelTTF *_scoreLabel;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    self.position = ccp(0, 0);
}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)setScore:(int)score {
    _scoreLabel.string = [NSString stringWithFormat:@"%d", score];
}

@end
