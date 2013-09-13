//
//  PKBible.h
//  gbible
//
//  Created by Kerri Shotts on 3/19/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
//
#import <UIKit/UIKit.h>
#import "PKDatabase.h"
#import "FMDatabaseQueue.h"

@interface PKBible : NSObject

+(BOOL) isMorphologySupportedByText: (NSUInteger) theText;
+(BOOL) isTranslationSupportedByText: (NSUInteger) theText;
+(BOOL) isStrongsSupportedByText: (NSUInteger) theText;


+(NSString *) text: (NSUInteger) theText inDB: (FMDatabaseQueue *)db withColumn: (int) column;
+(BOOL) isTextBuiltIn: (NSUInteger) theText;
+(BOOL) isTextInstalled: (NSUInteger) theText;


+(NSArray *) availableTextsInDB: (FMDatabaseQueue *)db withColumn: (int) column;
+(NSArray *) builtInTextsWithColumn: (int) column;
+(NSArray *) installedTextsWithColumn: (int) column;
+(NSArray *) bibleArray;

+(NSArray *)  availableOriginalTexts: (int) column;
+(NSArray *)  availableHostTexts: (int) column;
+(NSString *) titleForTextID: (NSUInteger) theText;
+(NSString *) abbreviationForTextID: (NSUInteger) theText;
+(NSString *) nameForBook: (NSUInteger) theBook;
+(NSString *) abbreviationForBookIfNecessary:(NSUInteger)theBook;

+(NSString *) abbreviationForBook: (NSUInteger) theBook;
+(NSUInteger)        countOfChaptersForBook: (NSUInteger) theBook;
+(NSUInteger)        countOfVersesForBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter;

+(NSArray *)  getTextForBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter
 forSide                    : (NSUInteger) theSide;

+(NSString *) getTextForBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter forVerse: (NSUInteger) theVerse
 forSide                    : (NSUInteger) theSide;


+(NSArray *)  passagesMatching: (NSString *) theTerm;
+(NSInteger)        parsedVariant: (NSUInteger) theBook;
+(BOOL)       checkParsingsForBook: (NSUInteger) theBook;
+(NSArray *)  passagesMatching: (NSString *) theTerm requireParsings: (BOOL) parsings;
+(NSArray *)  passagesMatching: (NSString *) theTerm withGreekBible: (NSUInteger) theGreekBible andEnglishBible: (NSUInteger) theEnglishBible;

// formatting routines
+(CGFloat)    formattedTextHeight: (NSArray *) theWordArray withParsings: (BOOL) parsed;
+(NSArray *)  formatText: (NSString *) theText forColumn: (NSUInteger) theColumn withBounds: (CGRect) theRect withParsings: (BOOL) parsed
 startingAt             : (CGFloat) initialY withCompression: (BOOL)compression;
+(CGFloat)    columnWidth: (NSUInteger) theColumn forBounds: (CGRect) theRect withCompression: (BOOL)compression;
+(NSString *) transliterate: (NSString *) theWord;
@end