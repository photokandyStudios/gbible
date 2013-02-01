//
//  PKBible.h
//  gbible
//
//  Created by Kerri Shotts on 3/19/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKDatabase.h"
#import "FMDatabaseQueue.h"

@interface PKBible : NSObject

+(NSString *) text: (int) theText inDB: (FMDatabaseQueue *)db withColumn: (int) column;
+(BOOL) isTextBuiltIn: (int) theText;
+(BOOL) isTextInstalled: (int) theText;


+(NSArray *) availableTextsInDB: (FMDatabaseQueue *)db withColumn: (int) column;
+(NSArray *) builtInTextsWithColumn: (int) column;
+(NSArray *) installedTextsWithColumn: (int) column;
+(NSArray *) bibleArray;

+(NSArray *)  availableOriginalTexts: (int) column;
+(NSArray *)  availableHostTexts: (int) column;
+(NSString *) titleForTextID: (int) theText;
+(NSString *) abbreviationForTextID: (int) theText;
+(NSString *) nameForBook: (int) theBook;
+(NSString *) numericalThreeLetterCodeForBook: (int) theBook;
+(NSString *) abbreviationForBook: (int) theBook;
+(int)        countOfChaptersForBook: (int) theBook;
+(int)        countOfVersesForBook: (int) theBook forChapter: (int) theChapter;

+(NSArray *)  getTextForBook: (int) theBook forChapter: (int) theChapter
 forSide                    : (int) theSide;

+(NSString *) getTextForBook: (int) theBook forChapter: (int) theChapter forVerse: (int) theVerse
 forSide                    : (int) theSide;

+(NSString *) stringFromBook: (int) theBook forChapter: (int) theChapter;
+(NSString *) stringFromBook: (int) theBook forChapter: (int) theChapter forVerse: (int) theVerse;
+(int)        bookFromString: (NSString *) theString;
+(int)        chapterFromString: (NSString *) theString;
+(int)        verseFromString: (NSString *) theString;

+(NSArray *)  passagesMatching: (NSString *) theTerm;
+(int)        parsedVariant: (int) theBook;
+(BOOL)       checkParsingsForBook: (int) theBook;
+(NSArray *)  passagesMatching: (NSString *) theTerm requireParsings: (BOOL) parsings;
+(NSArray *)  passagesMatching: (NSString *) theTerm withGreekBible: (int) theGreekBible andEnglishBible: (int) theEnglishBible;

// formatting routines
+(CGFloat)    formattedTextHeight: (NSArray *) theWordArray withParsings: (BOOL) parsed;
+(NSArray *)  formatText: (NSString *) theText forColumn: (int) theColumn withBounds: (CGRect) theRect withParsings: (BOOL) parsed
 startingAt             : (CGFloat) initialY;
+(CGFloat)    columnWidth: (int) theColumn forBounds: (CGRect) theRect;
+(NSString *) transliterate: (NSString *) theWord;
@end