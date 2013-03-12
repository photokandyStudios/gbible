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

@synthesize book = _book;
@synthesize chapter = _chapter;
@synthesize verse = _verse;

+(PKReference *)referenceWithBook: (int)theBook andChapter:(int)theChapter andVerse:(int)theVerse
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

/**
 *
 * Returns the numerical 3-letter code for the given book. For example, 40 = 40N, 10 = 10O
 *
 */
+(NSString *) numericalThreeLetterCodeForBook: (int) theBook
{
  static NSArray *bookList;
  @synchronized(bookList)
  {
    if (!bookList)
    {
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
    }
    return [bookList objectAtIndex: theBook - 1];
  }
}

/**
 *
 * Returns a string for the given passage. For example, for Matthew(book 40), Chapter 1, Verse 1
 * we return 40N.1.1 . Most useful when maintaining dictionary keys. Otherwise, it is better
 * and faster to use the book/chapter/verse method.
 *
 */
+(NSString *) referenceStringFromBook: (int) theBook forChapter: (int) theChapter forVerse: (int) theVerse
{
  NSString *theString;
  theString = [[[[[self numericalThreeLetterCodeForBook: theBook] stringByAppendingString: @"."]
                 stringByAppendingFormat: @"%i", theChapter] stringByAppendingString: @"."]
               stringByAppendingFormat: @"%i", theVerse];
  return theString;
}

/**
 *
 * Returns a shortened passage reference, containing the book and chapter. (No verse reference.)
 *
 * For example, given Matthew Chapter 1 (book 40), return 40N.1
 *
 */
+(NSString *) referenceStringFromBook: (int) theBook forChapter: (int) theChapter
{
  NSString *theString;
  theString = [[[self numericalThreeLetterCodeForBook: theBook] stringByAppendingString: @"."]
               stringByAppendingFormat: @"%i", theChapter];
  return theString;
}

/**
 *
 * Returns the book portion of a string formatted by stringFromBook:forChapter:forVerse
 *
 * For example, given 40N.1.1, return 40
 *
 */
+(int) bookFromReferenceString: (NSString *) theString
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
+(int) chapterFromReferenceString: (NSString *) theString
{
  // return the chapter portion of a string
  int firstPeriod  = [theString rangeOfString: @"."].location;
  int secondPeriod =
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
+(int) verseFromReferenceString: (NSString *) theString
{
  // return the verse portion of a string
  int firstPeriod  = [theString rangeOfString: @"."].location;
  int secondPeriod =
    [theString rangeOfString: @"." options: 0 range: NSMakeRange( firstPeriod + 1, [theString length] -
                                                                  (firstPeriod + 1) )].location;

  return [[theString substringFromIndex: secondPeriod + 1] intValue];
}


-(NSString *) getReference
{
  return [PKReference referenceStringFromBook:_book forChapter:_chapter forVerse:_verse];
}

-(void) setReference: (NSString *)theReference
{
  _book = [PKReference bookFromReferenceString:theReference];
  _chapter = [PKReference chapterFromReferenceString:theReference];
  _verse = [PKReference verseFromReferenceString:theReference];
}

-(NSString *)description
{
  return [NSString stringWithFormat:@"PKReference: %@", self.reference];
}

-(NSString *)prettyReference
{
  return [NSString stringWithFormat: @"%@ %i:%i",
                                [PKBible nameForBook: _book], _chapter, _verse];
}


@end
