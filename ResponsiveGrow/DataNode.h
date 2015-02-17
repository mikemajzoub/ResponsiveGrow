//
//  DataNode.h
//  ResponsiveGrow
//
//  Created by Michael Majzoub on 2/16/15.
//  Copyright (c) 2015 mikemajzoub. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DataNode : SKNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size numberValue:(int)numberValue;
- (void)updateDistanceFromTouch:(float)distanceFromTouch;
- (float)getDistanceFromTouch;
- (void)updateVisuals;
- (void)resetVisuals;
- (int)getNumberValue;
- (SKColor *)getBackgroundColor;

@end
