//
//  ViewController.h
//  Concentration
//
//  Created by Jessica Lachewitz on 4/18/15.
//  Copyright (c) 2015 Jessica Lachewitz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "CircularTimer.h"

@interface ViewController : UIViewController<CardDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *matchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *guessesLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *howToPlayLabel;
@property (weak, nonatomic) IBOutlet UIView *cardsContainerView;
@property (strong, nonatomic) IBOutlet UIView *timerContainerView;

@property (strong, nonatomic) CircularTimer *timer;
@property (assign, nonatomic) int columns;

-(IBAction) playButtonClicked:(id)sender;

@end

