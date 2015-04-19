//
//  NSMutableArray+Shuffling.h
//  Concentration
//
//  Created by Jessica Lachewitz on 4/18/15.
//  Copyright (c) 2015 Jessica Lachewitz. All rights reserved.
//

#import <Foundation/Foundation.h>

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end
