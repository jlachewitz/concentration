//
//  CardView.h
//  Concentration
//
//  Created by Jessica Lachewitz on 4/18/15.
//  Copyright (c) 2015 Jessica Lachewitz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Card;

@protocol CardDelegate <NSObject>

-(void) toggledCard:(Card*)card;
-(int) getNumColumns;

@end

@interface Card : UIView <NSCopying>

- (id)initWithFrame:(CGRect)frame andName:(NSString*)name andCardFrontSideImageNamed:(NSString*)cardFrontSideImageName andDelegate:(id<CardDelegate>)delegate;

@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isMatched;
@property NSString* name;
@property NSString* cardFrontSideImageName;
@property UIButton* cardButton;

@property (nonatomic,assign) id<CardDelegate> delegate;

@end
