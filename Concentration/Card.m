//
//  CardView.m
//  Concentration
//
//  Created by Jessica Lachewitz on 4/18/15.
//  Copyright (c) 2015 Jessica Lachewitz. All rights reserved.
//

#import "Card.h"

static NSString* cardBackSideImageName = @"cardbacksideimage.png";

@implementation Card

# pragma mark Init and copy methods
- (id) initWithFrame:(CGRect)frame andName:(NSString*)name andCardFrontSideImageNamed:(NSString*)cardFrontSideImageName andDelegate:(id<CardDelegate>)delegate
{
    self.name = name;
    self.cardFrontSideImageName = cardFrontSideImageName;
    self.delegate = delegate;
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.isVisible = NO;
        self.isMatched = NO;
        
        int cardSideLength = (frame.size.width/[self.delegate getNumColumns]);
        CGRect newFrame = CGRectMake(0, 0, cardSideLength-5, cardSideLength-5);
        
        UIImage *cardImage = [UIImage imageNamed:cardBackSideImageName];
        self.cardButton = [[UIButton alloc] init];
        [self.cardButton setFrame:newFrame];
        [self.cardButton setImage:cardImage forState:UIControlStateNormal];
        [self.cardButton setAdjustsImageWhenHighlighted:NO];
        [self.cardButton addTarget:self action:@selector(toggleCardImageShowing:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.cardButton];
    }
    
    return self;
}

- (Card*) copyWithZone:(NSZone*)zone
{
    Card *card = [[Card alloc] initWithFrame:self.frame andName:self.name andCardFrontSideImageNamed:self.cardFrontSideImageName andDelegate:self.delegate];
    card.isMatched = NO;
    card.isVisible = NO;
    return card;
}

# pragma mark Show card face
- (void) toggleCardImageShowing:(id)sender
{
    if (!self.isVisible)
    {
        self.isVisible = YES;
        
        // we need to tell our delegate that we toggled the card, so that we can add it to our current guess and check for a match
        [self.delegate toggledCard:self];
    }
    else
    {
        // ignore this click, it's a bit cruel to count that as a guess since it could have been an accidental double-tap
    }
}

# pragma mark Toggle isVisible/isMatched
- (void) setIsVisible:(BOOL)isVisible
{
    _isVisible = isVisible;
    if (isVisible)
    {
        [self.cardButton setImage:[UIImage imageNamed:self.cardFrontSideImageName] forState:UIControlStateNormal];
    }
    else
    {
        [self.cardButton setImage:[UIImage imageNamed:cardBackSideImageName] forState:UIControlStateNormal];
    }
}

- (void) setIsMatched:(BOOL)isMatched
{
    _isMatched = isMatched;
    if (isMatched)
    {
        [self.cardButton setImage:nil forState:UIControlStateNormal];
    }
}

@end
