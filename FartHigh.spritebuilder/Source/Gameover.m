//
//  Gameover.m
//  FartHigh
//
//  Created by Zuoyou Gu on 4/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameover.h"
#import "Enemy.h"
#import "Powerup.h"

#define NUM_OF_ENEMY 3

@implementation Gameover {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_scoreLabel0;
    CCLabelTTF *_scoreLabel1;
    CCLabelTTF *_scoreLabel2;
    NSArray *_scoreLabels;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    self.position = ccp(0, 0);
    _scoreLabels = @[_scoreLabel0, _scoreLabel1, _scoreLabel2];
}

- (void)retry {
    [Enemy reset];
    [Powerup reset];
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void)setScoreWithTotalScore:(int)score withScoreArray:(NSInteger *)scores {
    _scoreLabel.string = [NSString stringWithFormat:@"%d", score];
    for(NSInteger i=0; i<NUM_OF_ENEMY; i++) {
        CCLabelTTF *count = [_scoreLabels objectAtIndex:i];
        count.string = [NSString stringWithFormat:@"%ld", (long)scores[i]];
    }
}

@end
