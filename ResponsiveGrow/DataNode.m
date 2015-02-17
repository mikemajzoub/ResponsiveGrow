//
//  DataNode.m
//  ResponsiveGrow
//
//  Created by Michael Majzoub on 2/16/15.
//  Copyright (c) 2015 mikemajzoub. All rights reserved.
//

#import "DataNode.h"

static NSString *kSquareBackgroundName = @"squareBackgroundName";
static NSString *kNumberName = @"kNumberName";
static NSString *kFontName = @"kFontName";
static NSString *kFontBoldName = @"kFontBoldName";

@interface DataNode()

@property float distanceFromTouch;
@property int numberValue;

@end

@implementation DataNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size numberValue:(int)numberValue {
    self = [super init];
    if (self) {
        SKSpriteNode *squareBackground = [SKSpriteNode spriteNodeWithColor:color size:size];
        squareBackground.name = kSquareBackgroundName;
        squareBackground.position = CGPointMake(0, 0);
        [self addChild:squareBackground];
        
        SKLabelNode *number = [SKLabelNode labelNodeWithFontNamed:kFontName];
        number.name = kNumberName;
        number.text = [NSString stringWithFormat:@"%d", numberValue];
        number.fontColor = [SKColor whiteColor];
        number.fontSize = 12;
        number.position = CGPointMake(0, 0);
        number.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        number.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:number];
        
        self.numberValue = numberValue;
    }
    return self;
}

- (void)updateDistanceFromTouch:(float)distanceFromTouch {
    self.distanceFromTouch = distanceFromTouch;
}

- (float)getDistanceFromTouch {
    return self.distanceFromTouch;
}

- (int)getNumberValue {
    return self.numberValue;
}

- (SKColor *)getBackgroundColor {
    SKSpriteNode *squareBackground = (SKSpriteNode *) [self childNodeWithName:kSquareBackgroundName];
    return (SKColor *) squareBackground.color;
}

- (void)updateVisuals {
    SKSpriteNode *squareBackground = (SKSpriteNode *) [self childNodeWithName:kSquareBackgroundName];
    float squareLength = squareBackground.size.height;
    float unitDistance = self.distanceFromTouch / squareLength;
    
    // if node at touch, will scale 3x.
    // if node is 4 squares away from touch, will scale 2x.
    // if node is 8 squares away from touch, will not scale at all.
    float scaleTo = 3.0 - (unitDistance / 4);
    SKAction *scale = (scaleTo > 1.0) ? [SKAction scaleTo:scaleTo duration:0.1] : [SKAction scaleTo:1.0 duration:0.0];
    [self runAction:scale];
    
    // node at touch will have alpha of 1.0
    // nodes within 4 squares have alpha of 0.9
    float alphaTo = 1.0 - (unitDistance / 40);
    SKAction *alphaFade = [SKAction fadeAlphaTo:alphaTo duration:0.1];
    [self runAction:alphaFade];
    
    // closer nodes have greater zPosition, placing them in front.
    self.zPosition = 1000 - self.distanceFromTouch;
}

- (void)resetVisuals {
    SKAction *resetAlpha = [SKAction fadeAlphaTo:1.0 duration:0.2];
    SKAction *resetScale = [SKAction scaleTo:1.0 duration:0.2];
    SKAction *group = [SKAction group:@[resetAlpha, resetScale]];
    [self runAction:group];
}

@end
