//
//  PKHistory.h
//  gbible
//
//  Created by Kerri Shotts on 4/7/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKHistory : NSObject

    +(id) instance;
    -(NSMutableArray *)mostRecentPassages;
    -(NSMutableArray *)mostRecentPassagesWithLimit: (int) theLimit;
    -(void) addPassage: (NSString *)thePassage;
    -(void) addPassagewithBook: (int) theBook andChapter: (int) theChapter andVerse: (int) theVerse;
    -(void) createSchema;

@end
