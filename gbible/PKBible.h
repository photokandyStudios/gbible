//
//  PKBible.h
//  gbible
//
//  Created by Kerri Shotts on 3/19/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKBible : NSObject

    +(NSString *) nameForBook: (int)theBook;
    +(NSString *) numericalThreeLetterCodeForBook: (int)theBook;
    +(NSString *) abbreviationForBook: (int)theBook;
    +(int) countOfChaptersForBook: (int)theBook;
    +(int) countOfVersesForBook: (int)theBook forChapter: (int) theChapter;
    
    +(NSArray *) getTextForBook: (int)theBook forChapter: (int)theChapter
                                               forSide: (int)theSide;

    +(NSString *) getTextForBook: (int)theBook forChapter: (int)theChapter forVerse: (int)theVerse
                                               forSide: (int)theSide;
    
    +(NSString *) stringFromBook: (int)theBook forChapter: (int)theChapter;
    +(NSString *) stringFromBook: (int)theBook forChapter: (int)theChapter forVerse: (int)theVerse;
    +(int) bookFromString: (NSString *)theString;
    +(int) chapterFromString: (NSString *)theString;
    +(int) verseFromString: (NSString *)theString;

    // formatting routines
    +(CGFloat)formattedTextHeight: (NSArray *)theWordArray withParsings:(BOOL)parsed;
    +(NSArray *)formatText: (NSString *)theText forColumn: (int)theColumn withBounds: (CGRect)theRect withParsings: (BOOL)parsed;
    +(CGFloat) columnWidth: (int) theColumn forBounds: (CGRect)theRect;
    
@end
