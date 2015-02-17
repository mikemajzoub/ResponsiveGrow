//
//  GameScene.m
//  ResponsiveGrow
//
//  Created by Michael Majzoub on 2/15/15.
//  Copyright (c) 2015 mikemajzoub. All rights reserved.
//

#import "GameScene.h"
#import "DataNode.h"

static NSString *kDataNodeName = @"dataNodeName";
static NSString *kNodeTitleName = @"nodeTitleName";
static NSString *kLargeVisualName = @"largeVisualName";
static NSString *kScreenTitle = @"Data* Browser";
static NSString *kFontName = @"Helvetica";
static NSString *kFontBoldName = @"Helvetica-Bold";
static int kRespondToTouch = 5;

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.backgroundColor = [SKColor whiteColor];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    [self makeTitleLabel];
    [self makeDetailScreen];
    
    NSMutableArray *dummyData = [[NSMutableArray alloc] init];
    for (int i = 0; i < 225; i++) {
        [dummyData addObject:[NSNumber numberWithInt:i]];
    }
    [self displayDataWithArray:(NSArray *)dummyData];
    
}

- (void)makeDetailScreen {
    SKLabelNode *nodeTitle = [SKLabelNode labelNodeWithFontNamed:kFontBoldName];
    nodeTitle.name = kNodeTitleName;
    nodeTitle.fontSize = 24;
    nodeTitle.position = CGPointMake(self.size.width * 2/3, self.size.height * 5/6);
    nodeTitle.zPosition = 0;
    nodeTitle.fontColor = [SKColor blueColor];
    [self addChild:nodeTitle];
    
    SKSpriteNode *largeVisual = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(100, 100)];
    largeVisual.name = kLargeVisualName;
    largeVisual.colorBlendFactor = 1.0;
    largeVisual.position = CGPointMake(self.size.width * 1/5, self.size.height * 7/8);
    [self addChild:largeVisual];
}

- (void)makeTitleLabel {
    SKLabelNode *screenTitle = [SKLabelNode labelNodeWithFontNamed:kFontBoldName];
    screenTitle.text = kScreenTitle;
    screenTitle.fontSize = 36;
    screenTitle.position = CGPointMake(self.size.width/2, 20);
    screenTitle.zPosition = 0;
    screenTitle.fontColor = [SKColor blueColor];
    [self addChild:screenTitle];
}

- (void)displayDataWithArray:(NSArray *)data {
    // get width of data
    int rowSize = ceil(sqrt(data.count));
    float nodeWidth = self.size.width/((float)rowSize + 2); // + 2 gives grid left and right margins
    
    // starting at 1, and the row size +1 is to give space on the edges of the grid to expand nicely.
    for (int i = 1; i < rowSize + 1; i++) {
        for (int j = 1; j < rowSize + 1; j++) {
            SKColor *nodeColor = (i % 2 && j % 2) || (!(i % 2) && !(j % 2)) ? [SKColor redColor] : [SKColor blueColor];
            DataNode *aDataNode = [[DataNode alloc] initWithColor:nodeColor size:CGSizeMake(nodeWidth, nodeWidth) numberValue:(i-1)*rowSize + j];
            aDataNode.name = kDataNodeName;
            aDataNode.position = CGPointMake((j * nodeWidth) + nodeWidth/2, (i * nodeWidth) + nodeWidth/2 + 40);
            [self addChild:aDataNode];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    kRespondToTouch = 0; // always want display responding to first tap in sequence
    [self respondToNewTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self respondToNewTouches:touches];
}

- (void)respondToNewTouches:(NSSet *)touches {
    if ((kRespondToTouch++) % 4 == 0) { // respond to every Xth touch for performance issues
        CGPoint touchPoint = [[touches anyObject] locationInNode:self];
        CGPoint aLocation = [self convertPoint:touchPoint toNode:self];
        CGPoint fatFingerAdjustedPosition = [self adjustForFatFinger:aLocation];
        
        __block DataNode *closestNode = (DataNode *) [self childNodeWithName:kDataNodeName];
        
        [self enumerateChildNodesWithName:kDataNodeName usingBlock:^(SKNode *node, BOOL *stop) {
            DataNode *aNode = (DataNode *) node;
            float widthDifference = abs(fatFingerAdjustedPosition.x - aNode.position.x);
            float heightDifference = abs(fatFingerAdjustedPosition.y - aNode.position.y);
            float distanceFromTouch = sqrtf(widthDifference * widthDifference + heightDifference * heightDifference);
            [aNode updateDistanceFromTouch:distanceFromTouch];
            [aNode updateVisuals];
            
            // update closest node
            if ([aNode getDistanceFromTouch] < [closestNode getDistanceFromTouch]) {
                closestNode = aNode;
            }
        }];
        
        [self updateDetailScreen:closestNode];
    }
}

- (CGPoint)adjustForFatFinger:(CGPoint)underFinger {
    return CGPointMake(underFinger.x, underFinger.y+60);
}

- (void)updateDetailScreen:(DataNode *)aClosestNode {
    SKLabelNode *nodeTitle = (SKLabelNode *) [self childNodeWithName:kNodeTitleName];
    SKSpriteNode *largeVisual = (SKSpriteNode *) [self childNodeWithName:kLargeVisualName];
    
    nodeTitle.text = [NSString stringWithFormat:@"%d", [aClosestNode getNumberValue]];
    largeVisual.color = [aClosestNode getBackgroundColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self enumerateChildNodesWithName:kDataNodeName usingBlock:^(SKNode *node, BOOL *stop) {
        DataNode *aNode = (DataNode *) node;
        [aNode resetVisuals];
    }];
    
    [self clearDetailScreen];
}

- (void)clearDetailScreen {
    SKLabelNode *nodeTitle = (SKLabelNode *) [self childNodeWithName:kNodeTitleName];
    SKSpriteNode *largeVisual = (SKSpriteNode *) [self childNodeWithName:kLargeVisualName];
    
    nodeTitle.text = @"";
    largeVisual.color = [SKColor clearColor];
}

@end
