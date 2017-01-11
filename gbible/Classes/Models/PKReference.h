//
//  PKReference.h
//  gbible
//
//  Created by Kerri Shotts on 2/26/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
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

#import <Foundation/Foundation.h>

@interface PKReference : NSObject

@property NSUInteger book;
@property NSUInteger chapter;
@property NSUInteger verse;
@property (getter=getReference, setter=setReference:) NSString *reference;

+(PKReference *)referenceWithBook: (NSUInteger)theBook andChapter:(NSUInteger)theChapter andVerse:(NSUInteger)theVerse;
+(PKReference *)referenceWithString: (NSString *)theRef;
+(NSString *) paddedReferenceStringFromBook:(NSUInteger)theBook forChapter:(NSUInteger)theChapter forVerse:(NSUInteger)theVerse;
+(NSComparisonResult) compare: (PKReference *)obj1 with: (PKReference *)obj2;


-(NSString *)description;
-(NSString *)prettyReference;
-(NSString *)prettyShortReference;
-(NSString *)prettyShortReferenceIfNecessary;
-(NSString *) getPaddedReference;
-(NSComparisonResult) compare: (PKReference *)bReference;
-(BOOL) isEqual: (PKReference *)bReference;

// use only if necessary; you should try to use the regular object instead
+(NSString *) numericalThreeLetterCodeForBook: (NSUInteger) theBook;
+(NSString *) referenceStringFromBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter forVerse: (NSUInteger) theVerse;
+(NSString *) referenceStringFromBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter;
+(NSUInteger) bookFromReferenceString: (NSString *) theString;
+(NSUInteger) chapterFromReferenceString: (NSString *) theString;
+(NSUInteger) verseFromReferenceString: (NSString *) theString;

+(NSString *) stringFromVerseNumber: (NSUInteger)theVerse;
+(NSString *) stringFromChapterNumber: (NSUInteger)theChapter;
+(NSString *) stringFromBookNumber: (NSUInteger)theBook;
+(NSString *) stringFromChapterNumber: (NSUInteger) theChapter andVerseNumber: (NSUInteger) theVerse;
-(NSString *) stringFromVerseNumber;
-(NSString *) stringFromChapterNumber;
-(NSString *) stringFromBookNumber;
-(NSString *) stringFromChapterNumberAndVerseNumber;

-(NSString *) format: (NSString *)theFormat, ...;

@end
