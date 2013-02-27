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

+(BOOL) isMorphologySupportedByText: (int) theText;
+(BOOL) isTranslationSupportedByText: (int) theText;
+(BOOL) isStrongsSupportedByText: (int) theText;


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

+(NSString *) abbreviationForBook: (int) theBook;
+(int)        countOfChaptersForBook: (int) theBook;
+(int)        countOfVersesForBook: (int) theBook forChapter: (int) theChapter;

+(NSArray *)  getTextForBook: (int) theBook forChapter: (int) theChapter
 forSide                    : (int) theSide;

+(NSString *) getTextForBook: (int) theBook forChapter: (int) theChapter forVerse: (int) theVerse
 forSide                    : (int) theSide;


+(NSArray *)  passagesMatching: (NSString *) theTerm;
+(int)        parsedVariant: (int) theBook;
+(BOOL)       checkParsingsForBook: (int) theBook;
+(NSArray *)  passagesMatching: (NSString *) theTerm requireParsings: (BOOL) parsings;
+(NSArray *)  passagesMatching: (NSString *) theTerm withGreekBible: (int) theGreekBible andEnglishBible: (int) theEnglishBible;

// formatting routines
+(CGFloat)    formattedTextHeight: (NSArray *) theWordArray withParsings: (BOOL) parsed;
+(NSArray *)  formatText: (NSString *) theText forColumn: (int) theColumn withBounds: (CGRect) theRect withParsings: (BOOL) parsed
 startingAt             : (CGFloat) initialY withCompression: (BOOL)compression;
+(CGFloat)    columnWidth: (int) theColumn forBounds: (CGRect) theRect withCompression: (BOOL)compression;
+(NSString *) transliterate: (NSString *) theWord;
@end