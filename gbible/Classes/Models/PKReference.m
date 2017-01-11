//
//  PKReference.m
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

#import "PKReference.h"
#import "PKBible.h"

@implementation PKReference

/*
@synthesize book = _book;
@synthesize chapter = _chapter;
@synthesize verse = _verse;
*/

+(PKReference *)referenceWithBook: (NSUInteger)theBook andChapter:(NSUInteger)theChapter andVerse:(NSUInteger)theVerse
{
  PKReference *aReference = [PKReference new];
  aReference.book = theBook;
  aReference.chapter = theChapter;
  aReference.verse = theVerse;
  return aReference;
}

+(PKReference *)referenceWithString: (NSString *)theRef
{
  PKReference *aReference = [PKReference new];
  aReference.reference = theRef;
  return aReference;
}

+(NSComparisonResult) compare: (PKReference *)obj1 with: (PKReference *)obj2 {
  return [obj1 compare:obj2];
}

/**
 *
 * Returns the numerical 3-letter code for the given book. For example, 40 = 40N, 10 = 10O
 *
 */
+(NSString *) numericalThreeLetterCodeForBook: (NSUInteger) theBook
{
  static dispatch_once_t once;
  static NSArray *bookList;
  
  dispatch_once(&once, ^{
      bookList = @[
                       @"01O", @"02O", @"03O", @"04O", @"05O", @"06O", @"07O", @"08O",
                       @"09O", @"10O", @"11O", @"12O", @"13O", @"14O",
                       @"15O", @"16O", @"17O", @"18O", @"19O", @"20O", @"21O",
                       @"22O", @"23O", @"24O", @"25O", @"26O", @"27O",
                       @"28O", @"29O", @"30O", @"31O", @"32O", @"33O", @"34O", @"35O",
                       @"36O", @"37O", @"38O", @"39O",
                       // New Testament
                       @"40N", @"41N", @"42N", @"43N", @"44N", @"45N", @"46N",
                       @"47N", @"48N", @"49N", @"50N", @"51N",
                       @"52N", @"53N", @"54N", @"55N", @"56N",
                       @"57N", @"58N", @"59N", @"60N", @"61N", @"62N", @"63N",
                       @"64N", @"65N", @"66N"];
  });
  if (theBook < 1 || theBook > 66) {
    theBook = 40;
  }
  return bookList[theBook - 1];
}

/**
 *
 * Returns a string for the given passage. For example, for Matthew(book 40), Chapter 1, Verse 1
 * we return 40N.1.1 . Most useful when maintaining dictionary keys. Otherwise, it is better
 * and faster to use the book/chapter/verse method.
 *
 */
+(NSString *) referenceStringFromBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter forVerse: (NSUInteger) theVerse
{
  NSString *theString;
  theString = [NSString stringWithFormat:@"%@.%@.%@", [self numericalThreeLetterCodeForBook:theBook],
                                                      @(theChapter), @(theVerse)];
  return theString;
}

+(NSString *) paddedReferenceStringFromBook:(NSUInteger)theBook forChapter:(NSUInteger)theChapter forVerse:(NSUInteger)theVerse {
  NSString *theString;
  theString = [NSString stringWithFormat:@"%@.%03i.%03i", [self numericalThreeLetterCodeForBook:theBook],
               (int)theChapter, (int)theVerse];
  return theString;
}

/**
 *
 * Returns a shortened passage reference, containing the book and chapter. (No verse reference.)
 *
 * For example, given Matthew Chapter 1 (book 40), return 40N.1
 *
 */
+(NSString *) referenceStringFromBook: (NSUInteger) theBook forChapter: (NSUInteger) theChapter
{
  NSString *theString;
  theString = [NSString stringWithFormat:@"%@.%@", [self numericalThreeLetterCodeForBook:theBook],
                                                      @(theChapter)];
  return theString;
}

/**
 *
 * Returns the book portion of a string formatted by stringFromBook:forChapter:forVerse
 *
 * For example, given 40N.1.1, return 40
 *
 */
+(NSUInteger) bookFromReferenceString: (NSString *) theString
{
  return [theString intValue];
}

/**
 *
 * Returns the chapter portion of a string formatted by stringFromBook:forChapter:forVerse
 *
 * For example, given 40N.12.1, return 12
 *
 */
+(NSUInteger) chapterFromReferenceString: (NSString *) theString
{
  // return the chapter portion of a string
  NSUInteger firstPeriod  = [theString rangeOfString: @"."].location;
  NSUInteger secondPeriod =
    [theString rangeOfString: @"." options: 0 range: NSMakeRange( firstPeriod + 1, [theString length] -
                                                                  (firstPeriod + 1) )].location;

  return [[theString substringWithRange: NSMakeRange( firstPeriod + 1, secondPeriod - (firstPeriod + 1) )] intValue];
}

/**
 *
 * Returns the verse portion of a string formatted by stringfromBook:forChapter:forVerse
 *
 * For example, given 40N.12.1, returns 1
 *
 */
+(NSUInteger) verseFromReferenceString: (NSString *) theString
{
  // return the verse portion of a string
  NSUInteger firstPeriod  = [theString rangeOfString: @"."].location;
  NSUInteger secondPeriod =
    [theString rangeOfString: @"." options: 0 range: NSMakeRange( firstPeriod + 1, [theString length] -
                                                                  (firstPeriod + 1) )].location;

  return [[theString substringFromIndex: secondPeriod + 1] intValue];
}


-(NSString *) getReference
{
  return [PKReference referenceStringFromBook:_book forChapter:_chapter forVerse:_verse];
}

-(NSString *) getPaddedReference {
  return [PKReference paddedReferenceStringFromBook:_book forChapter:_chapter forVerse:_verse];
}

-(void) setReference: (NSString *)theReference
{
  _book = [PKReference bookFromReferenceString:theReference];
  _chapter = [PKReference chapterFromReferenceString:theReference];
  _verse = [PKReference verseFromReferenceString:theReference];
}

-(NSComparisonResult) compare: (PKReference *)bReference {
  return [[self getPaddedReference] compare:[bReference getPaddedReference]];
}

-(BOOL) isEqual: (PKReference *)bReference {
  return [[self getPaddedReference] isEqualToString:[bReference getPaddedReference]];
}

-(NSString *)description
{
  return [NSString stringWithFormat:@"PKReference: %@", self.reference];
}

-(NSString *)prettyReference
{
  return [NSString stringWithFormat: @"%@ %@:%@",
                                [PKBible nameForBook: _book], @(_chapter), @(_verse)];
}

-(NSString *)prettyShortReference
{
  return [NSString stringWithFormat: @"%@. %@:%@",
                                [PKBible abbreviationForBook: _book], @(_chapter), @(_verse)];
}

-(NSString *)prettyShortReferenceIfNecessary
{

  if (viewportIsNarrow())
  {
    return [self prettyShortReference];
  }
  else
  {
    return [self prettyReference];
  }


}

// canonical representations of verses, chapters, and books, even if it is wordier.
+(NSString *) stringFromVerseNumber: (NSUInteger)theVerse
{
  return [@(theVerse) stringValue];
}

+(NSString *) stringFromChapterNumber: (NSUInteger)theChapter
{
  return [@(theChapter) stringValue];
}

+(NSString *) stringFromBookNumber: (NSUInteger)theBook
{
  return [@(theBook) stringValue];
}

+(NSString *) stringFromChapterNumber: (NSUInteger) theChapter andVerseNumber: (NSUInteger) theVerse
{
  return [NSString stringWithFormat:@"%@:%@", [PKReference stringFromChapterNumber:theChapter],
                                              [PKReference stringFromVerseNumber:theVerse]];
}

-(NSString *) stringFromVerseNumber
{
  return [PKReference stringFromVerseNumber:_verse];
}

-(NSString *) stringFromChapterNumber
{
  return [PKReference stringFromChapterNumber:_chapter];
}

-(NSString *) stringFromBookNumber
{
  return [PKReference stringFromBookNumber:_book];
}

-(NSString *) stringFromChapterNumberAndVerseNumber
{
  return [PKReference stringFromChapterNumber:_chapter andVerseNumber:_verse];
}

-(NSString *) format: (NSString *)theFormat, ...
{
  // This just formats references
  // using special tokens, and then passes it on to NSString stringWithFormat to do the
  // rest.
  //
  // @ signals format
  // b == book number; c == chapter number; v == verse
  // # == number; N == name; C == code
  //               S == short; 3 == 3-letter
  //               ? == if necessary
  //
  //
  // SO: @bNS? @c#:@v# would return "Matthew 12:10" or "Mat. 12:10" depending on the device's screen size.
  //
  

  NSMutableString *s = [theFormat mutableCopy];
  
  // book
  if ([s rangeOfString:@"%bNS?."].location != NSNotFound)
  {
    if (viewportIsNarrow())
      [s replaceOccurrencesOfString:@"%bNS?." withString:[[PKBible abbreviationForBook:self.book] stringByAppendingString:@"."] options:0 range:NSMakeRange(0, [s length])];
    else
      [s replaceOccurrencesOfString:@"%bNS?." withString:[PKBible nameForBook:self.book ] options:0 range:NSMakeRange(0, [s length])];
  }
  if ([s rangeOfString:@"%bNS?"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%bNS?" withString:[PKBible abbreviationForBookIfNecessary:self.book] options:0 range:NSMakeRange(0, [s length])];
  if ([s rangeOfString:@"%bNS"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%bNS" withString:[PKBible abbreviationForBook:self.book] options:0 range:NSMakeRange(0, [s length])];
  if ([s rangeOfString:@"%bC3"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%bC3" withString:[PKReference numericalThreeLetterCodeForBook:self.book] options:0 range:NSMakeRange(0, [s length])];
  if ([s rangeOfString:@"%bN"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%bN" withString:[PKBible nameForBook:self.book ] options:0 range:NSMakeRange(0, [s length])];
  if ([s rangeOfString:@"%b#"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%b#" withString:[self stringFromBookNumber] options:0 range:NSMakeRange(0, [s length])];

  // chapter
  if ([s rangeOfString:@"%c#"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%c#" withString:[self stringFromChapterNumber] options:0 range:NSMakeRange(0, [s length])];
  
  // verse
  if ([s rangeOfString:@"%v#"].location != NSNotFound)
    [s replaceOccurrencesOfString:@"%v#" withString:[self stringFromVerseNumber] options:0 range:NSMakeRange(0, [s length])];

  va_list args;
  va_start(args, theFormat);
  NSString *swf = [[NSString alloc] initWithFormat:s arguments:args];
  va_end(args);
  
  return swf;
}

@end
