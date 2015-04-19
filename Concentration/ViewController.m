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
#import <sys/utsname.h>

@interface ViewController ()
{
    int matchedPairs;
    int guesses;
    int totalPairsToMatch;
    NSMutableArray* currentGuess;
    NSMutableArray* randomizedDeck;
}

@end

@implementation ViewController

# pragma mark Set up/reset game board
// initially we want to show the "how to" label and play button
-(void) viewDidLoad
{
    [super viewDidLoad];
    self.playButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.playButton.titleLabel.numberOfLines = 0;
    [self.howToPlayLabel setText:@"How to play:\nYou will have 90 seconds to find 14 pairs of images.  Good luck!"];
}

// set guesses, matched pairs, and total pairs to match to their default values; set up the timer for 90 seconds; create a new randomized deck of cards, and draw them to the screen
-(void) startGame
{
    currentGuess = [[NSMutableArray alloc] init];

    guesses = 0;
    matchedPairs = 0;
    totalPairsToMatch = 14;

    [self updateGuessesLabel];
    [self updateMatchesLabel];
    [self updateHighestScoreLabel];
    
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
    
    // if this is an iPad or an iPhone 4s, give it 6 columns
    float deviceHeight = self.view.frame.size.height;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad || (deviceHeight == 480 || deviceHeight == 960))
    {
        self.columns = 6;
    }
    else
    {
        self.columns = 5;
    }
    
    randomizedDeck = [self randomizedDeck];
    
    // create a grid of cards with the specified number of columns... we want more columns for ipad since we have more screen real estate to work with
    for (int i = 0; i < randomizedDeck.count; i++)
    {
        Card* card = randomizedDeck[i];
        
        int cardSideLength = card.cardButton.frame.size.width;
        CGRect cardFrame =
            CGRectMake((i%self.columns)*(cardSideLength+5)+2.5,
                       (i/self.columns)*(cardSideLength+5),
                       cardSideLength,
                       cardSideLength);
        card.frame = cardFrame;
        
        [self.cardsContainerView addSubview:card];
    }
}

// reset everything!  that means hiding all the game-specific views (including the cards, if they're still showing!), and unhiding the "how to" label and play button
-(void) resetGameBoard
{
    self.timer.hidden = YES;
    self.guessesLabel.hidden = YES;
    self.matchesLabel.hidden = YES;
    self.highScoreLabel.hidden = YES;
    
    [[self.cardsContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.howToPlayLabel.hidden = NO;
    self.playButton.hidden = NO;
    [self.playButton setTitle:@"Play Again!" forState:UIControlStateNormal];
}

#pragma mark Play button callback
-(IBAction) playButtonClicked:(id)sender;
{
    self.playButton.hidden = YES;
    self.howToPlayLabel.hidden = YES;
    
    [self startGame];
}

// Create randomized deck of pairs of cards
-(NSMutableArray*) randomizedDeck
{
    NSMutableArray* deck = [[NSMutableArray alloc] init];
    id<CardDelegate> delegate = self;
    
    for (int i = 1; i <= totalPairsToMatch; i++)
    {
        Card* newCard = [[Card alloc] initWithFrame:self.view.frame andName:[NSString stringWithFormat:@"%d", i%14+1] andCardFrontSideImageNamed:[NSString stringWithFormat:@"%d.jpg", i%14+1] andDelegate:delegate];
        [deck addObject:newCard];
        [deck addObject:[newCard copy]];
    }
    
    [deck shuffle];
    return deck;
}

#pragma mark Update labels
-(void) updateMatchesLabel
{
    self.matchesLabel.hidden = NO;
    self.matchesLabel.text = [NSString stringWithFormat:@"Pairs Left: %d", totalPairsToMatch-matchedPairs];
}

-(void) updateGuessesLabel
{
    self.guessesLabel.hidden = NO;
    self.guessesLabel.text = [NSString stringWithFormat:@"# Guesses: %d", guesses];
}

-(void) updateHighestScoreLabel
{
    self.highScoreLabel.hidden = NO;
    NSNumber* highScore = [self getUsersHighScore];
    if (highScore != nil)
    {
        self.highScoreLabel.hidden = NO;
        self.highScoreLabel.text = [NSString stringWithFormat:@"Best Game: %d guesses", highScore.intValue];
    }
    else
    {
        self.highScoreLabel.hidden = YES;
    }
}

#pragma mark CardDelegate callbacks
-(void) toggledCard:(Card*)card
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
    
    // if we have a pair selected, let's check to see if we have a match
    if (currentGuess.count == 2)
    {
        guesses++;
        [self updateGuessesLabel];
        
        // if we have a match, update our labels and check to see if we've found all the pairs
        if ([self isMatchFound:currentGuess])
        {
            matchedPairs++;
            [self updateMatchesLabel];
            
            [self setCurrentGuessToMatched:currentGuess];
            
            if (matchedPairs == totalPairsToMatch)
            {
                [self showWinDialog];
            }
        }
    }
}

-(int) getNumColumns
{
    return self.columns;
}

# pragma mark Check to see if pairs are matches
// if the names of the cards in the guess match, we've found a match
-(BOOL) isMatchFound:(NSMutableArray*)withGuess
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

// set the two cards to isMatched, so that their images are taken off the screen; then clear out currentGuess
-(void) setCurrentGuessToMatched:(NSMutableArray*)withGuess
{
    ((Card*)withGuess[0]).isMatched = ((Card*)withGuess[1]).isMatched = YES;
    [currentGuess removeAllObjects];
}

#pragma mark Show win/lose dialogs
-(void) showLoseDialog
{
    DTAlertViewButtonClickedBlock block = ^(DTAlertView *_alertView, NSUInteger buttonIndex, NSUInteger cancelButtonIndex)
    {
        [self resetGameBoard];
    };
    
    DTAlertView *alertView = [DTAlertView alertViewUseBlock:block title:@"Oh noes!" message:@"Time's up :( Try again!" cancelButtonTitle:nil positiveButtonTitle:@"OK"];
    
    [alertView show];
}

-(void) showWinDialog
{
    // make sure we stop the timer!
    [self.timer stop];
    
    DTAlertViewButtonClickedBlock block = ^(DTAlertView *_alertView, NSUInteger buttonIndex, NSUInteger cancelButtonIndex)
    {
        [self resetGameBoard];
    };
    
    DTAlertView *alertView;
    if ([self isCurrentScoreUsersHighest])
    {
        // we got a new high score!  let's save it so we remember for later
        [self updateUsersHighScoreWithCurrentScore];
        alertView = [DTAlertView alertViewUseBlock:block title:@"WOW!" message:[NSString stringWithFormat:@"New high score! %d is the fewest guesses you've ever needed to win!", guesses] cancelButtonTitle:nil positiveButtonTitle:@"OK"];
    }
    else
    {
        alertView = [DTAlertView alertViewUseBlock:block title:@"You rock!" message:[NSString stringWithFormat:@"Yay, you won, and it only took you %d guesses!", guesses] cancelButtonTitle:nil positiveButtonTitle:@"OK"];
    }
    
    [alertView show];
}

# pragma mark Check and update high score
// get users high score from NSUserDefaults if it exists
-(NSNumber*) getUsersHighScore
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
}

// check to see if the score from the previous round is the highest the user has ever gotten
-(BOOL) isCurrentScoreUsersHighest
{
    BOOL isCurrentScoreUsersHighest = NO;
    NSNumber* highScore = [self getUsersHighScore];
    
    if (highScore == nil || highScore.intValue > guesses)
    {
        isCurrentScoreUsersHighest = YES;
    }
    else
    {
        isCurrentScoreUsersHighest = NO;
    }
    
    return isCurrentScoreUsersHighest;
}

// update the high score with the score from the previous round
-(void) updateUsersHighScoreWithCurrentScore
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:guesses] forKeyPath:@"highScore"];
}

NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* deviceName = [NSString stringWithCString:systemInfo.machine
                                              encoding:NSUTF8StringEncoding];
    NSLog(@"%@", deviceName);
    return deviceName;
}

# pragma mark Memory warning
-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
