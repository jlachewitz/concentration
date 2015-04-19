//
//  ViewController.m
//  Concentration
//
//  Created by Jessica Lachewitz on 4/18/15.
//  Copyright (c) 2015 Jessica Lachewitz. All rights reserved.
//

#import "ViewController.h"
#import "Card.h"
#import "NSMutableArray+Shuffling.h"
#import "CircularTimer.h"
#import "DTAlertView.h"

@interface ViewController ()
{
    //Card* selectedCard;
    int matchedPairs;
    int guesses;
    int totalPairsToMatch;
    NSMutableArray* currentGuess;
    NSMutableArray* randomizedDeck;

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startGame];
}

- (void) startGame
{
    matchedPairs = 0;
    guesses = 0;
    [self updateGuessesLabel];
    totalPairsToMatch = 14;
    [self updateMatchesLabel];
    [self updateHighestScoreLabel];
    
    [[self.cardsContainerView subviews]
                             makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDate *now = [NSDate date];
    NSDate *nowPlusOneMinute = [now dateByAddingTimeInterval:90];
    
    self.timer =
    [[CircularTimer alloc] initWithPosition:CGPointZero
                                     radius:self.timerContainerView.frame.size.width/2
                             internalRadius:self.timerContainerView.frame.size.width/2-20
                          circleStrokeColor:[UIColor purpleColor]
                    activeCircleStrokeColor:[UIColor whiteColor]
                                initialDate:now
                                  finalDate:nowPlusOneMinute
                              startCallback:^{
                                  //do something
                              }
                                endCallback:^{
                                    [self showLoseDialog];
                                }];
    [self.timerContainerView addSubview:self.timer];
    
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad)
    {
        self.columns = 5;
    }
    else
    {
        self.columns = 6;
    }
    currentGuess = [[NSMutableArray alloc] init];
    
    randomizedDeck = [self randomizedDeck];
    
    for (int i = 0; i < randomizedDeck.count; i++)
    {
        Card* card = randomizedDeck[i];
        int cardSideLength = card.cardButton.frame.size.width;
        CGRect cardFrame = CGRectMake((i%self.columns)*(cardSideLength+5)+2.5, (i/self.columns)*(cardSideLength+5), cardSideLength, cardSideLength);
        NSLog(@"%@", NSStringFromCGRect(cardFrame));
        card.frame = cardFrame;
        [self.cardsContainerView addSubview:card];
    }
}

- (NSMutableArray*) randomizedDeck
{
    NSMutableArray* deck = [[NSMutableArray alloc] init];
    id<CardDelegate> delegate = self;
    //delegate.numColumns = self.columns;
    for (int i = 1; i <= totalPairsToMatch; i++)
    {
        Card* newCard = [[Card alloc] initWithFrame:self.view.frame andName:[NSString stringWithFormat:@"%d", i%14+1] andCardFrontSideImageNamed:[NSString stringWithFormat:@"%d.jpg", i%14+1] andDelegate:delegate];
        [deck addObject:newCard];
        [deck addObject:[newCard copy]];
    }
    [deck shuffle];
    
    return deck;
}

- (void)toggledCard:(Card*)card
{
    // let's clear out the previous guess when the user chooses another card
    if (currentGuess.count == 2)
    {
        for (Card* c in currentGuess)
        {
            c.isVisible = NO;
        }
        
        [currentGuess removeAllObjects];
    }
    
    [currentGuess addObject:card];

    if (currentGuess.count == 2)
    {
        guesses++;
        [self updateGuessesLabel];
        NSLog(@"num of guesses: %d", guesses);
        
        if ([self matchFound:currentGuess])
        {
            matchedPairs++;
            [self updateMatchesLabel];
            NSLog(@"num of matches: %d", matchedPairs);

            [self setCurrentGuessToMatched:currentGuess];
            
            if (matchedPairs == totalPairsToMatch)
            {
                [self showWinDialog];
            }
        }
    }
}

- (BOOL) matchFound:(NSMutableArray*)withGuess
{
    if ([((Card*)withGuess[0]).name isEqualToString:((Card*)withGuess[1]).name])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) updateMatchesLabel
{
    self.matchesLabel.text = [NSString stringWithFormat:@"Pairs Left: %d", totalPairsToMatch-matchedPairs];
}

- (void) updateGuessesLabel
{
    self.guessesLabel.text = [NSString stringWithFormat:@"# Guesses: %d", guesses];
}

- (void) updateHighestScoreLabel
{
    int highScore = [self getUsersHighScore];
    if (highScore > -1)
    {
        self.highScoreLabel.hidden = NO;
        self.highScoreLabel.text = [NSString stringWithFormat:@"Best Game: %d guesses", highScore];
    }
    else
    {
        self.highScoreLabel.hidden = YES;
    }
}

- (void) setCurrentGuessToMatched:(NSMutableArray*)withGuess
{
    ((Card*)withGuess[0]).isMatched = ((Card*)withGuess[1]).isMatched = YES;
    [currentGuess removeAllObjects];
    
}

-(void) showWinDialog
{
    [self.timer stop];
    DTAlertViewButtonClickedBlock block = ^(DTAlertView *_alertView, NSUInteger buttonIndex, NSUInteger cancelButtonIndex){
        // You can get button title of clicked button.
        NSLog(@"%@", _alertView.clickedButtonTitle);
        [self startGame];
    };
    
    DTAlertView *alertView;
    if ([self isScoreUsersHighest])
    {
        alertView = [DTAlertView alertViewUseBlock:block title:@"WOW!" message:[NSString stringWithFormat:@"New high score! %d is the fewest guesses you've ever needed to win!", guesses] cancelButtonTitle:nil positiveButtonTitle:@"OK"];

    }
    else
    {
        alertView = [DTAlertView alertViewUseBlock:block title:@"You rock!" message:[NSString stringWithFormat:@"Yay, you won, and it only took you %d guesses!", guesses] cancelButtonTitle:nil positiveButtonTitle:@"OK"];
    }

    [alertView show];
}

-(BOOL) isScoreUsersHighest
{
    BOOL isScoreUsersHighest = NO;
    NSNumber* highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    if (highScore == nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:guesses] forKeyPath:@"highScore"];
        isScoreUsersHighest = YES;
    }
    else
    {
        if (highScore.intValue > guesses)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:guesses] forKeyPath:@"highScore"];
            isScoreUsersHighest = YES;
        }
        else
        {
            isScoreUsersHighest = NO;
        }
    }
    
    return isScoreUsersHighest;
}

-(int) getUsersHighScore
{
    NSNumber* highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];

    return highScore != nil ? highScore.intValue : -1;
}

-(void) showLoseDialog
{
    DTAlertViewButtonClickedBlock block = ^(DTAlertView *_alertView, NSUInteger buttonIndex, NSUInteger cancelButtonIndex){
        // You can get button title of clicked button.
        NSLog(@"%@", _alertView.clickedButtonTitle);
        [self startGame];
    };
    
    DTAlertView *alertView = [DTAlertView alertViewUseBlock:block title:@"Oh noes!" message:@"Time's up :( Try again!" cancelButtonTitle:nil positiveButtonTitle:@"OK"];
    
    [alertView show];
}

-(int) getNumColumns
{
    return self.columns;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
