//
//  PKBible.m
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
#import "PKBible.h"
#import "PKSettings.h"
#import "PKDatabase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "PKConstants.h"
#import "searchutils.h"
#import "PKReference.h"
#import <Parse/Parse.h>
#import "PKLabel.h"
#import "UIFont+Utility.h"

@implementation PKBible

/**
 *
 * Returns YES if the text supports the display of morphology.
 *
 * TODO: make this dynamic.
 *
 */
+(BOOL) isMorphologySupportedByText: (int) theText
{
  if (theText == PK_BIBLETEXT_BYZP ||
      theText == PK_BIBLETEXT_TRP ||
      theText == PK_BIBLETEXT_WHP)
  {
    return YES;
  }
  return NO;
}

/**
 *
 * Returns YES if the text supports the display of interlinear
 * translations.
 *
 * TODO: make this dynamic.
 *
 */
+(BOOL) isTranslationSupportedByText: (int) theText
{
  if (theText == PK_BIBLETEXT_WHP ||
      theText == 901)
  {
    return YES;
  }
  return NO;
}

/**
 *
 * Returns YES if the text supports the display of Strong's
 * indexes.
 *
 * TODO: make this dynamic.
 *
 */
+(BOOL) isStrongsSupportedByText: (int) theText
{
  if (theText == PK_BIBLETEXT_BYZP ||
      theText == PK_BIBLETEXT_TRP ||
      theText == PK_BIBLETEXT_WHP ||
      theText == 901)
  {
    return YES;
  }
  return NO;
}


/**
 *
 * Return the database to use (built-in/user) based upon
 * the text ID. Text IDs<=100 always use the built-in
 * database. Text IDs>100 will use the user database.
 *
 */
+(FMDatabaseQueue *) bibleDatabaseForText: (int) theText
{
  if (theText <= 100) return [[PKDatabase instance] bible];
  return [[PKDatabase instance] userBible];
}

/**
 *
 * Return an array of the Bible databases.
 *
 */
+(NSArray *) bibleArray
{
  return @[ [[PKDatabase instance] bible],
            [[PKDatabase instance] userBible] ];
}

/**
 *
 * Returns the value for a particular column for a given text in the
 * specified database (built-in/user).
 *
 * Excludes KJV if in a crown-copyright area.
 *
 */
+(NSString *) text: (int) theText inDB: (FMDatabaseQueue *)db withColumn: (int) column
{
  // http://stackoverflow.com/questions/3940615/find-current-country-from-iphone-device
  NSLocale *currentLocale = [NSLocale currentLocale];    // get the current locale.
  NSString *countryCode   = [currentLocale objectForKey: NSLocaleCountryCode];
  
  __block NSString *theReturnValue = nil;

    [db inDatabase:^(FMDatabase *db)
      {
        FMResultSet *s          =
          [db executeQuery:
           @"select bibleAbbreviation, bibleAttribution, bibleSide, bibleID, bibleName, bibleParsedID from bibles where bibleID=? order by bibleAbbreviation", @(theText) ];

        if ([s next])
        {
          // make sure we don't add the KJV version if we're in the UK, or in the Euro-zone (since they
          // must respect the UK copyright)
          if ( !( ([@" GB AT BE BG CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE "
                    rangeOfString: [NSString stringWithFormat: @" %@ ", countryCode]].location != NSNotFound)
                  && [[s stringForColumnIndex: PK_TBL_BIBLES_ABBREVIATION] isEqualToString: @"KJV"] ) )
          {
            theReturnValue = [s objectForColumnIndex: column];
          }
        }
        [s close];
      }
    ];

  return theReturnValue;
}

/**
 *
 * Returns YES if a given text is in the built-in database.
 *
 */
+(BOOL) isTextBuiltIn: (int) theText
{
  return [self text: theText inDB:[[PKDatabase instance]bible] withColumn:PK_TBL_BIBLES_ID] != nil ? YES : NO;
}

/**
 *
 * Returns Yes if a given text is in the user database.
 *
 */
+(BOOL) isTextInstalled: (int) theText
{
  return [self text: theText inDB:[[PKDatabase instance]userBible] withColumn:PK_TBL_BIBLES_ID] != nil ? YES : NO;
}

/**
 *
 * Returns an array of the data in a specific column in a specific Bible database
 * (built-in/user). Used most often for displaying lists of available translations.
 *
 * Restricts KJV if in an area where it is crown-cypright.
 *
 */
+(NSArray *) availableTextsInDB: (FMDatabaseQueue *)db withColumn: (int) column
{
  // http://stackoverflow.com/questions/3940615/find-current-country-from-iphone-device
  NSLocale *currentLocale = [NSLocale currentLocale];    // get the current locale.
  NSString *countryCode   = [currentLocale objectForKey: NSLocaleCountryCode];
  
  NSMutableArray *texts   = [[NSMutableArray alloc] initWithCapacity: 4];

    [db inDatabase:^(FMDatabase *db)
      {
        FMResultSet *s          =
          [db executeQuery:
           @"select bibleAbbreviation, bibleAttribution, bibleSide, bibleID, bibleName, bibleParsedID from bibles order by bibleAbbreviation"];

        while ([s next])
        {
          // make sure we don't add the KJV version if we're in the UK, or in the Euro-zone (since they
          // must respect the UK copyright)
          if ( !( ([@" GB AT BE BG CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE "
                    rangeOfString: [NSString stringWithFormat: @" %@ ", countryCode]].location != NSNotFound)
                  && [[s stringForColumnIndex: PK_TBL_BIBLES_ABBREVIATION] isEqualToString: @"KJV"] ) )
          {
            [texts addObject: [s objectForColumnIndex: column]];
          }
        }
        [s close];
      }
    ];

  return texts;
}

/**
 *
 * Convenience method. Return the data from the specified column using the
 * built-in Bible database.
 *
 */
+(NSArray *) builtInTextsWithColumn: (int) column
{
  return [self availableTextsInDB:[[PKDatabase instance]bible] withColumn:column];
}

/**
 *
 * Convenience method. Return the data from the specified column using the
 * user Bible database.
 *
 */
+(NSArray *) installedTextsWithColumn: (int) column
{
  return [self availableTextsInDB:[[PKDatabase instance]userBible] withColumn:column];
}

/**
 *
 * Returns the available texts in both the User and Built-In Bible database
 * for the specific column and side (left/right).
 *
 * Excludes KJV where crown copyright.
 *
 */
+(NSArray *) availableTextsForSide: (NSString *) side andColumn: (int) column
{
  // http://stackoverflow.com/questions/3940615/find-current-country-from-iphone-device
  NSLocale *currentLocale = [NSLocale currentLocale];    // get the current locale.
  NSString *countryCode   = [currentLocale objectForKey: NSLocaleCountryCode];
  
  NSMutableArray *texts   = [[NSMutableArray alloc] initWithCapacity: 4];
  NSArray *theBibles = [self bibleArray];
  
  for (int i=0; i<theBibles.count; i++)
  {
    FMDatabaseQueue *db = theBibles[i];
    [db inDatabase:^(FMDatabase *db)
      {
        NSString *lside = @"";
        NSString *llside = @"";
        if ([side isEqualToString:@"greek"])  lside = @"leftSide";
        if ([side isEqualToString:@"english"])  lside = @"rightSide";
        if ([side isEqualToString:@"greek"])  llside = @"leftside";
        if ([side isEqualToString:@"english"])  llside = @"rightside";
        
        FMResultSet *s          =
          [db executeQuery:
           @"select bibleAbbreviation, bibleAttribution, bibleSide, bibleID, bibleName, bibleParsedID from bibles where bibleSide in (?,?,?) order by bibleAbbreviation",
           side, lside, llside];

        while ([s next])
        {
          // make sure we don't add the KJV version if we're in the UK, or in the Euro-zone (since they
          // must respect the UK copyright)
          if ( !( ([@" GB AT BE BG CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE "
                    rangeOfString: [NSString stringWithFormat: @" %@ ", countryCode]].location != NSNotFound)
                  && [[s stringForColumnIndex: PK_TBL_BIBLES_ABBREVIATION] isEqualToString: @"KJV"] ) )
          {
            [texts addObject: [s objectForColumnIndex: column]];
          }
        }
        [s close];
      }
    ];
  }
  return texts;
}

/**
 *
 * Returns the data for the specific column for those texts on the left/
 * "original" side.
 *
 */
+(NSArray *) availableOriginalTexts: (int) column
{
  return [PKBible availableTextsForSide: @"greek" andColumn: column];
}

/**
 *
 * Returns the data for the specific column for those texts on the right/
 * "english" side.
 *
 */
+(NSArray *) availableHostTexts: (int) column
{
  return [PKBible availableTextsForSide: @"english" andColumn: column];
  // really a misnomer; we should allow the reader to choose any language edition of their choosing.
}

/**
 *
 * Get the full Bible title for the text ID.
 *
 */
+(NSString *) titleForTextID: (int) theText
{
  FMDatabaseQueue *db = [self bibleDatabaseForText:theText];
  
  __block NSString *retValue = @"";
  
  [db inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s = [db executeQuery: @"select bibleName from bibles where bibleID=?", @ (theText)];

      if ([s next])
      {
        retValue = [s stringForColumnIndex: 0];
      }
      [s close];
    }
  ];
  
  return retValue;
}

/**
 *
 * Get the Bible's abbreviation for the text ID.
 *
 */
+(NSString *) abbreviationForTextID: (int) theText
{
  FMDatabaseQueue *db = [self bibleDatabaseForText:theText];
  
  __block NSString *retValue = @"";
  
  [db inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s = [db executeQuery: @"select bibleAbbreviation from bibles where bibleID=?", @ (theText)];

      if ([s next])
      {
        retValue = [s stringForColumnIndex: 0];
      }
      [s close];
    }
  ];
  
  return retValue;
}

/**
 *
 * Returns the canonical name for a Bible book, given the book number. For example, 40=Matthew
 *
 */
+(NSString *) nameForBook: (int) theBook
{
  //
  // Books of the bible and chapter count obtained from http://www.deafmissions.com/tally/bkchptrvrs.html
  //
  static NSArray *bookList;
  @synchronized(bookList)
  {
    if (!bookList)
    {
      bookList = @[
                         __T(@"Genesis"),         __T(@"Exodus"),   __T(@"Leviticus"), __T(@"Numbers"),
                         __T(@"Deuteronomy"),     __T(@"Joshua"),   __T(@"Judges"),    __T(@"Ruth"),
                         __T(@"1 Samuel"),        __T(@"2 Samuel"), __T(@"1 Kings"),   __T(@"2 Kings"),
                         __T(@"1 Chronicles"),    __T(@"2 Chronicles"),
                         __T(@"Ezra"),            __T(@"Nehemia"),  __T(@"Esther"),    __T(@"Job"),
                         __T(@"Psalms"),          __T(@"Proverbs"), __T(@"Ecclesiastes"),
                         __T(@"Song of Solomon"), __T(@"Isaiah"),   __T(@"Jeremiah"),  __T(@"Lamentations"),
                         __T(@"Ezekial"),         __T(@"Daniel"),
                         __T(@"Hosea"),           __T(@"Joel"),     __T(@"Amos"),      __T(@"Obadiah"),
                         __T(@"Jonah"),           __T(@"Micah"),    __T(@"Nahum"),     __T(@"Habakkuk"),
                         __T(@"Zephaniah"),       __T(@"Haggai"),   __T(@"Zechariah"), __T(@"Malachi"),
                         // New Testament
                         __T(@"Matthew"),         __T(@"Mark"),            __T(@"Luke"),          __T(@"John"),
                         __T(@"Acts"),            __T(@"Romans"),          __T(@"1 Corinthians"),
                         __T(@"2 Corinthians"),   __T(@"Galatians"), // FIX ISSUE #44
                         __T(@"Ephesians"),       __T(@"Philippians"),     __T(@"Colossians"),
                         __T(@"1 Thessalonians"), __T(@"2 Thessalonians"), __T(@"1 Timothy"),     __T(@"2 Timothy"), __T(@"Titus"),
                         __T(@"Philemon"),        __T(@"Hebrews"),         __T(@"James"),         __T(@"1 Peter"),   __T(@"2 Peter"),
                         __T(@"1 John"),          __T(@"2 John"),
                         __T(@"3 John"),          __T(@"Jude"),            __T(@"Revelation") ];
    }
    if (theBook<1)
    {
      return @"";
    }
    return [bookList objectAtIndex: theBook - 1];
  }
}


/**
 *
 * Returns the 3-letter abbreviation for a given book. For example, 40 = Mat
 *
 */
+(NSString *) abbreviationForBook: (int) theBook
{
  static NSArray *bookList;
  @synchronized(bookList)
  {
    if (!bookList)
    {
       bookList = @[
                       @"Gen", @"Exo", @"Lev", @"Num", @"Deu", @"Jos", @"Jdg", @"Rut",
                       @"1Sa", @"2Sa", @"1Ki", @"2Ki", @"1Ch", @"2Ch",
                       @"Ezr", @"Neh", @"Est", @"Job", @"Psa", @"Pro", @"Ecc",
                       @"Sos", @"Isa", @"Jer", @"Lam", @"Eze", @"Dan",
                       @"Hos", @"Joe", @"Amo", @"Oba", @"Jon", @"Mic", @"Nah", @"Hab",
                       @"Zep", @"Hag", @"Zec", @"Mal",
                       // New Testament
                       @"Mat", @"Mar", @"Luk", @"Joh", @"Act", @"Rom", @"1Co",
                       @"2Co", @"Gal", @"Eph", @"Phi", @"Col",
                       @"1Th", @"2Th", @"1Ti", @"2Ti", @"Tit",
                       @"Phl", @"Heb", @"Jas", @"1Pe", @"2Pe", @"1Jo", @"2Jo",
                       @"3Jo", @"Jud", @"Rev"];
    }
    return [bookList objectAtIndex: theBook - 1];
  }
}

/**
 *
 * Returns the number of chapters in the given Bible book.
 *
 */
+(int) countOfChaptersForBook: (int) theBook
{
  static int chapterCountList[]   = {50,40,27,36,34,24,21,4,31,24,22,25,
                                     29,36,10,13,10,42,150,31,12,8,66,52,
                                     5,48,12,14,3,9,1,4,7,3,3,3,2,14,4,
                                     // New Testament
                                     28,16,24,21,28,16,16,13, // re: issue #29
                                     6,6,4,4,5,3,6,4,3,1,13,5,5,3,5,1,1,
                                     1,22};
  return chapterCountList[theBook -1];
}

/**
 *
 * Returns the number of verses for the given book and chapter.
 *
 */
+(int) countOfVersesForBook: (int) theBook forChapter: (int) theChapter
{
  int totalCount;
  NSString *theSQL        = @"SELECT count(*) FROM content WHERE bibleID=? AND bibleBook = ? AND bibleChapter = ?";

  int currentGreekBible   = [[PKSettings instance] greekText];
  int currentEnglishBible = [[PKSettings instance] englishText];

  NSArray *theDBs = @[ [self bibleDatabaseForText:currentGreekBible], [self bibleDatabaseForText:currentEnglishBible] ];
  NSMutableArray* theCounts = [ @[ @0, @0 ] mutableCopy];
  
  for (int i=0; i<2; i++)
  {
    FMDatabaseQueue *db = theDBs[i];
    [db inDatabase:^(FMDatabase *db)
      {
        FMResultSet *s          = [db executeQuery: theSQL, [NSNumber numberWithInt: (i==0?currentGreekBible:currentEnglishBible)],
                                   [NSNumber numberWithInt: theBook],
                                   [NSNumber numberWithInt: theChapter]];

        while ([s next])
        {
          theCounts[i] = @([s intForColumnIndex: 0]);
        }
        [s close];
      }
    ];
  }

  totalCount = MAX([theCounts[0] intValue], [theCounts[1] intValue]);

  return totalCount;
}

+(NSString *) handleGlobalStringReplacements: (NSString *)theText
{
  NSMutableString *text = [theText mutableCopy];
  
  // italics
  [text replaceOccurrencesOfString:@"<i>" withString:@"/" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"</i>" withString:@"/" options:0 range:NSMakeRange(0, [text length])];
  
  // superscripts
  [text replaceOccurrencesOfString:@"<sup>0</sup>" withString:@"⁰" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>1</sup>" withString:@"¹" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>2</sup>" withString:@"²" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>3</sup>" withString:@"³" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>4</sup>" withString:@"⁴" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>5</sup>" withString:@"⁵" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>6</sup>" withString:@"⁶" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>7</sup>" withString:@"⁷" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>8</sup>" withString:@"⁸" options:0 range:NSMakeRange(0, [text length])];
  [text replaceOccurrencesOfString:@"<sup>9</sup>" withString:@"⁹" options:0 range:NSMakeRange(0, [text length])];

  return text;
}

/**
 *
 * Returns the text for a given reference (book chapter:verse) and side (1=greek,2=english)
 *
 * Note: adds the verse # to the english side. TODO?: Add to greek side too?
 *
 */
+(NSString *) getTextForBook: (int) theBook forChapter: (int) theChapter forVerse: (int) theVerse forSide: (int) theSide
{
  int currentBible = (theSide == 1 ? [[PKSettings instance] greekText] : [[PKSettings instance] englishText]);
  FMDatabaseQueue *db   = [self bibleDatabaseForText:currentBible];
  NSString *theSQL = @"SELECT bibleText FROM content WHERE bibleID=? AND bibleBook=? AND bibleChapter=? AND bibleVerse=?";
  __block NSString *theText;
  NSString *theRef = [NSString stringWithFormat: @"%i ", theVerse];
  
  [db inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s   = [db executeQuery: theSQL, [NSNumber numberWithInt: currentBible],
                          [NSNumber numberWithInt: theBook],
                          [NSNumber numberWithInt: theChapter],
                          [NSNumber numberWithInt: theVerse]];

      while ([s next])
      {
        theText = [s stringForColumnIndex: 0];
      }
      [s close];
    }
  ];

  if (theText != nil)
  {
    theText = [PKBible handleGlobalStringReplacements:theText];
    theText = [theRef stringByAppendingString: theText];
  }
  else
  {
    theText = theRef;
  }
  theText = [theText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

  if ([[PKSettings instance] transliterateText])
  {
    theText = [self transliterate: theText];
  }

  return theText;
}

/**
 *
 * Return the text for a given chapter (book chapter) and side (1=greek, 2=english). Note that
 * the english text has verse #s prepended to the text. Also note that is entirely possible
 * for the array on one side to be of a different length than the other side (Notably, Romans 13,16)
 *
 */
+(NSArray *) getTextForBook: (int) theBook forChapter: (int) theChapter forSide: (int) theSide
{
  int currentBible         = (theSide == 1 ? [[PKSettings instance] greekText] : [[PKSettings instance] englishText]);
  FMDatabaseQueue *db   = [self bibleDatabaseForText:currentBible];

  NSString *theSQL         = @"SELECT bibleText FROM content WHERE bibleID=? AND bibleBook = ? AND bibleChapter = ?";
  NSMutableArray *theArray = [[NSMutableArray alloc] init];

  [db inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s           = [db executeQuery: theSQL, [NSNumber numberWithInt: currentBible],
                                  [NSNumber numberWithInt: theBook],
                                  [NSNumber numberWithInt: theChapter]];
      int i                    = 1;

      while ([s next])
      {
        NSString *theText = [s stringForColumnIndex: 0];
        NSString *theRef  = [NSString stringWithFormat: @"%i ", i];
        // if (theSide == 2)
        // {
        theText = [PKBible handleGlobalStringReplacements:theText];
        theText = [theRef stringByAppendingString: theText];
        // }
        theText = [theText stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

        if ([[PKSettings instance] transliterateText])
        {
          theText = [self transliterate: theText];
        }
        [theArray addObject: theText];
        i++;
      }
      [s close];
    }
  ];

  return theArray;
}


/**
 *
 * Return the maximum height of the desired formatted text (in theWordArray). If withParsings
 * is YES, we include the height of the Strong's Numbers and (potentially) the Morphology.
 *
 */
+(CGFloat)formattedTextHeight: (NSArray *) theWordArray withParsings: (BOOL) parsed
{
  // this is our font
  UIFont *theFont      = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                      andSize: [[PKSettings instance] textFontSize]];
  // we need to know the height of an M (* the setting...)
  CGFloat lineHeight   = [@"M" sizeWithFont: theFont].height;
  lineHeight    = lineHeight * ( (float)[[PKSettings instance] textLineSpacing] / 100.0 );
  // determine the maximum size of the column (1 line, 2 lines, 3 lines?)
  
  /*CGFloat columnHeight = lineHeight;
  columnHeight += (lineHeight * [[PKSettings instance] textVerseSpacing]);

  if (parsed)
  {
    // are we going to show morphology?
    if ([[PKSettings instance] showMorphology])
    {
      columnHeight += lineHeight;
    }
    columnHeight += lineHeight;         // for G#s
  }
  */

  CGFloat maxY = 0.0;

  for (int i = 0; i < [theWordArray count]; i++)
  {
    NSArray *theWordElement = [theWordArray objectAtIndex: i];
    //NSString *theWord = [theWordElement objectAtIndex:0];
    //int theWordType = [[theWordElement objectAtIndex:1] intValue];
    //CGFloat wordX = [[theWordElement objectAtIndex:2] floatValue];
    CGFloat wordY = [[theWordElement objectAtIndex: 3] floatValue];

    if (wordY > maxY)
    {
      maxY = wordY;
    }
  }

  //maxY += columnHeight + lineHeight;
  maxY += lineHeight + (lineHeight / 2);       //RE: ISSUE # 5

  return maxY;
}

/**
 *
 * Return the width of a given column for the given bounds, based upon the user's
 * column settings. 
 *
 */
+(CGFloat) columnWidth: (int) theColumn forBounds: (CGRect) theRect withCompression: (BOOL)compression
{
  // set Margin
  CGFloat theMargin = 5;

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && !compression)
  {
    // iPad gets wider margins
    theMargin = 44;
  }

  if (compression)
  {
    return (theRect.size.width);
  }

  // define our column (based on incoming rect)
  int columnSetting      = [[PKSettings instance] layoutColumnWidths];
  
  static float columnWidths[3][2] = { {1.75f, 1.25f},
                                      {1.25f, 1.75f},
                                      {1.50f, 1.50f} };

  float columnMultiplier = columnWidths[columnSetting][theColumn-1] / 3;

  CGFloat columnWidth = ( (theRect.size.width) - (theMargin) ) * columnMultiplier;

  return columnWidth;
}

/**
 *
 * Returns YES if the word is a Morphology term.
 *
 */
+(BOOL) isMorphology: (NSString *) theWord
{
  // there's no easy way to determine if a word is a morphology word. Instead, let's encode
  // the various options
  
  CFStringRef strDash = CFSTR ("-");
  
  CFStringRef theCFString = (__bridge CFStringRef)(theWord);

  if (CFStringFind(theCFString, strDash, 0).location != kCFNotFound)
    return YES;

  CFStringRef morphWords = CFSTR(" Adv Adj N V Heb Conj Prep Prtcl Prt Cond Inj ADV ADJ HEB CONJ PREP PRTCL PRT COND ARAM INJ ");

  NSString *theSpacedWord = [[@" " stringByAppendingString: theWord] stringByAppendingString: @" "];
  if ( CFStringFind(morphWords, (__bridge CFStringRef)(theSpacedWord), 0).location != kCFNotFound )
  {
    return YES;
  }
  return NO;
}

/**
 *
 * Returns the transliteration of the supplied word.
 *
 */
+(NSString *)transliterate: (NSString *) theWord
{
  // See what we can do about using CFStringTransform...
  NSMutableString *myMString    = [theWord mutableCopy];
  CFMutableStringRef myCFString = (__bridge CFMutableStringRef)myMString;
  CFStringTransform(myCFString, NULL, kCFStringTransformToLatin, false);

  return myMString;
}

/**
 *
 * Formats the supplied text into an array of positions and types that will fit
 * within the given column's width and perform word-wrap where necessary.
 *
 */
+(NSArray *)formatText: (NSString *) theText forColumn: (int) theColumn withBounds: (CGRect) theRect withParsings: (BOOL) parsed
            startingAt: (CGFloat) initialY withCompression: (BOOL)compression
{
  // should we include the morphology?
  BOOL showMorphology  = [[PKSettings instance] showMorphology];
  BOOL showStrongs     = [[PKSettings instance] showStrongs];
  BOOL showInterlinear = [[PKSettings instance] showInterlinear];
  BOOL compressRightSide=[[PKSettings instance] compressRightSideText];
  
  // what greek text are we?
  int whichGreekText          = [[PKSettings instance] greekText];
  BOOL supportsMorphology = [PKBible isMorphologySupportedByText:whichGreekText];
  BOOL supportsStrongs = [PKBible isStrongsSupportedByText:whichGreekText];
  BOOL supportsTranslation = [PKBible isTranslationSupportedByText:whichGreekText];
  
  // this array will contain the word elements
  NSMutableArray *theWordArray = [[NSMutableArray alloc] init];

  // this is our font
  UIFont *theFont              = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                              andSize: [[PKSettings instance] textFontSize]];

  UIFont *theBoldFont = [UIFont fontWithName: [[PKSettings instance] textGreekFontFace]
                                     andSize: [[PKSettings instance] textFontSize]];

  if (theBoldFont == nil)           // just in case there's no alternate
  {
    theBoldFont = theFont;
  }

  // set Margin
  CGFloat theMargin = 5;

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad  &&!compression)
  {
    // iPad gets wider margins
    theMargin = 44;
  }
  // set starting points
  CGFloat startX      = theRect.origin.x + theMargin;  // some margin
  CGFloat startY      = 0;  //theRect.origin.y;

  CGFloat curX        = startX;
  CGFloat curY;

  // maximum point
  CGFloat endX;

  CGFloat columnWidth = [self columnWidth: theColumn forBounds: theRect withCompression:compression];     // (theRect.size.width) * columnMultiplier;

  // new maximum point
  endX = startX + columnWidth;

  if (theColumn == 2)
  {
    endX = endX - theMargin;
  }
  else
  {
    endX = endX - (theMargin / 2);
  }

  NSMutableString *theFixedText = [theText mutableCopy];
  [theFixedText replaceOccurrencesOfString: @" ) " withString: @") " options: 0 range: NSMakeRange(0,  [theFixedText length])];
  // split by spaces
  NSArray *matches              = [theFixedText componentsSeparatedByString: @" "];

  // we need to know the width of a space
  CGFloat spaceWidth            = [@" " sizeWithFont: theFont].width;
  // we need to know the height of an M (* the setting...)
  CGFloat lineHeight            = [@"M" sizeWithFont: theFont].height;
  lineHeight    = lineHeight * ( (float)[[PKSettings instance] textLineSpacing] / 100.0 );
  // determine the maximum size of the column (1 line, 2 lines, 3 lines?)
  CGFloat columnHeight          = lineHeight;
  columnHeight += (lineHeight * [[PKSettings instance] textVerseSpacing]);

  if ( theColumn == 1 || !compression)
  {
    if (parsed)
    {
      // are we going to show morphology?
      if ([[PKSettings instance] showMorphology] && supportsMorphology)
      {
        columnHeight += lineHeight;
      }

      if (showStrongs && supportsStrongs)
      {
        columnHeight += lineHeight;         // for G#s
      }

      if (supportsTranslation && showInterlinear)
      {
        columnHeight += lineHeight;
      }
    }
  }
  
  if ( theColumn == 2 && compressRightSide )
  {
    columnHeight          = lineHeight;
    columnHeight += (lineHeight * [[PKSettings instance] textVerseSpacing]);
  }

  CGFloat yOffset = 0.0;
  CGFloat strongsOffset = lineHeight * 1;
  CGFloat morphologyOffset = lineHeight * 2;
  CGFloat translationOffset = lineHeight * 3;
  
  if (!showStrongs || !supportsStrongs)
  {
    strongsOffset = 0.0;
    morphologyOffset -= lineHeight;
    translationOffset -= lineHeight;
  }
  
  if (!showMorphology || !supportsMorphology)
  {
    morphologyOffset -= lineHeight;
    translationOffset -= lineHeight;
  }
  
  if (!showInterlinear || !supportsTranslation)
  {
    translationOffset -= lineHeight;
  }

  // give us some margin at the top
  startY  = lineHeight / 2;      //RE: ISSUE # 5
  startY += initialY;       // new formatting for iPhone;
  curY    = startY;    //RE: ISSUE # 5

  // iterate through each word and wrap where necessary, building an
  // array of x, y points and words.

  int thePriorWordType       = -1;
  int theWordType            = -1;
  NSString *theWord;
  NSString *thePriorWord;
  NSArray *thePriorWordArray = @[];
  int thePriorWordArrayIndex = -1;

  CGFloat maxX               = 0.0;

  for (int i = 0; i < [matches count]; i++)
  {
    // move priors
    thePriorWordType = theWordType;
    thePriorWord     = theWord;

    // got the current word
    NSString *theOriginalWord = [matches objectAtIndex: i];
    theWord = [matches objectAtIndex: i];

    // obtain the prior word array
    if (thePriorWordType == 0)
    {
      thePriorWordArray = [theWordArray lastObject];
      thePriorWordArrayIndex = theWordArray.count-1;
    }

    // and its size
    CGSize theSize;

    // determine the type of the word
    theWordType = 0;            // by default, we're a regular word
    yOffset     = 0.0;

    if (theColumn == 1)          // we only do this for greek text
    {
      // originally we used regular expressions, but they are SLOW
      // G#s are of the form G[0-9]+

      if ( (theOriginalWord.length > 1
            && [theOriginalWord hasPrefix: @"G"]
            && [[theOriginalWord substringFromIndex: 1] intValue] > 0) || [theOriginalWord hasPrefix:@"G*"] )
      {
        // we're a G#
        theWordType = 10;
        yOffset     = strongsOffset;

        if ([[theOriginalWord substringFromIndex: 1] intValue] > 5624)
        {
          theWord = [NSString stringWithFormat:@"M%i", [[theOriginalWord substringFromIndex: 1] intValue]];
            theWord = @"";
          theWordType =19;
          yOffset     = morphologyOffset;
          if (!showMorphology)
          {
            theWord = @"";
            yOffset -= lineHeight;
          }
        }

        if (!showStrongs) //  || [[theOriginalWord substringFromIndex: 1] intValue] > 5624)
        {
          theWord = @"";
//          theWordType = -1;
        }

        // add the G# to the previous word if it was a greek word --
        // this lets us get to the Strong's # from the greek word too.
        if (thePriorWordArray != nil
            && thePriorWordArray.count > 0
            && [[theOriginalWord substringFromIndex: 1] intValue] <= 5624
            )
        {
          int theIndex = thePriorWordArrayIndex; //[theWordArray indexOfObject: thePriorWordArray];

          if (theIndex > -1
              && theIndex < theWordArray.count)
          {
            NSMutableArray *theNewPriorWordArray = [thePriorWordArray mutableCopy];
            theNewPriorWordArray[6] = @ ([[theOriginalWord substringFromIndex: 1] intValue]);
            [theWordArray replaceObjectAtIndex: theIndex withObject: [theNewPriorWordArray copy]];
          }
        }
      }
      else
      {
        // are we a (interlinear word)?
        if ( theOriginalWord.length > 1
             && (
               [theOriginalWord hasPrefix: @"("]
               || [theOriginalWord hasSuffix: @")"]) )
        {
          theWordType = 5;
          yOffset     = translationOffset;

/*          if (!showMorphology)
          {
            yOffset -= lineHeight;
          }

          if (!showStrongs)
          {
            yOffset -= lineHeight;
          }*/

          if ([[theWord substringToIndex: 1] isEqualToString: @"("])
          {
            theWord = [theWord substringFromIndex: 1];
          }

          if ([[theWord substringFromIndex: [theWord length] - 1] isEqualToString: @")"])
          {
            theWord = [theWord substringToIndex: [theWord length] - 1];
          }

          if (!showInterlinear)
          {
            theWord = @"";
          }
        }
        else
        {
          // are we a VARiant? (regex: VAR[0-9]
          if ( theOriginalWord.length > 1
              && [theOriginalWord hasPrefix: @"VAR"])
          {
            theWordType = 0;                 // we're really just a regular word.
            yOffset     = 0.0;
          }
          else
          {
            // are we a morphology word? [A-Z]+[A-Z0-9\\-]+
            if ([PKBible isMorphology: theWord])                  //[[theWord uppercaseString] isEqualToString:theWord]
            /*([theOriginalWord characterAtIndex:0] >= 'A' &&
               [theOriginalWord characterAtIndex:0] <= 'Z')
               &&
               thePriorWordType >= 10 && thePriorWordType <20) */
            {
              // we are!
              theWordType = 20;
              yOffset     = morphologyOffset;

/*              if (!showStrongs)
              {
                yOffset -= lineHeight;
              }

              if (!showMorphology)
              {
                theWord = @"";
              }*/
            }
          }
        }
      }
    }

    if (theColumn == 1
        && theWordType == 0)
    {
      theSize = [theWord sizeWithFont: theBoldFont];
    }
    else
    {
      theSize = [theWord sizeWithFont: theFont];
    }

    // determine this word's position, and if we should word-wrap or not.
    if ( theWordType <= thePriorWordType
         || (theColumn == 2
             && i > 0) )
    {
      // we're a new variation on the column. curX can move foward by maxX
      curX += maxX + ( ![theWord isEqualToString:@""] ?spaceWidth : 0 );

      if (curX + theSize.width > endX - maxX ) //- spaceWidth)
      {
        curX  = startX;
        curY += columnHeight;
      }
      maxX = 0.0;           // reset maximum width
    }

    if (theSize.width > maxX)
    {
      maxX = theSize.width;
    }

    // start creating our word element
    NSArray *theWordElement = [NSArray arrayWithObjects: theWord,
                               [NSNumber numberWithInt: theWordType],
                               [NSNumber numberWithFloat: curX],
                               [NSNumber numberWithFloat: (curY + yOffset)],
                               [NSNumber numberWithFloat: theSize.width],
                               [NSNumber numberWithFloat: theSize.height],
                               @ - 1,                                 // G# placeholder
                               nil];

    if ( ( showMorphology
           || (theWordType < 20
               && !showMorphology) )
         && ( showStrongs
              || (theWordType != 10
                  && !showStrongs) )
         && ( showInterlinear
              || (theWordType != 5
                  && !showInterlinear) ) )
    {
      [theWordArray addObject: theWordElement];
    }
  }

  return theWordArray;
}

/**
 *
 * Return an array of references where the text matches the specific term.
 *
 */
+(NSArray *) passagesMatching: (NSString *) theTerm
{
  int currentGreekBible   = [[PKSettings instance] greekText];
  int currentEnglishBible = [[PKSettings instance] englishText];

  return [self passagesMatching: theTerm withGreekBible: currentGreekBible andEnglishBible: currentEnglishBible];
}

/**
 *
 * DEPRECATED.
 *
 * Returns the parsed variant of a non-parsed text.
 *
 */
+(int) parsedVariant: (int) theBook
{
  __block int theParsedBook = -1;       // return this if nothing matches
  FMDatabaseQueue *db    = [self bibleDatabaseForText:theBook];
  
  [db inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s    =
        [db executeQuery: @"SELECT IFNULL(bibleParsedID,-1) FROM bibles WHERE bibleID=?", [NSNumber numberWithInt: theBook]];

      if ([s next])
      {
        theParsedBook = [s intForColumnIndex: 0];
      }
      [s close];
    }
  ];
  return theParsedBook;
}

/**
 *
 * DEPRECATED.
 *
 */
+(BOOL) checkParsingsForBook: (int) theBook
{
  return (theBook == [self parsedVariant: theBook]);
}

/**
 *
 * Returns an array of references that match the term. requireParsings lets
 * us specify if the text needs to have a parsings or not.
 *
 */
+(NSArray *) passagesMatching: (NSString *) theTerm requireParsings: (BOOL) parsings
{
  int currentGreekBible   = [[PKSettings instance] greekText];
  int currentEnglishBible = [[PKSettings instance] englishText];

  if (parsings)
  {
    int parsedGreekBible = [self parsedVariant: currentGreekBible];

    if (parsedGreekBible > -1)
    {
      currentGreekBible = parsedGreekBible;
    }
  }
  return [self passagesMatching: theTerm withGreekBible: currentGreekBible andEnglishBible: currentEnglishBible];
}

/**
 *
 * Searches for the term within the two supplied texts and returns an array of the matches.
 *
 */
+(NSArray *) passagesMatching: (NSString *) theTerm withGreekBible: (int) theGreekBible andEnglishBible: (int) theEnglishBible
{
  NSMutableArray *theMatches = [[NSMutableArray alloc] init];

  NSString *searchPhrase = convertSearchToSQL(theTerm, @"bibleText");

  NSArray *theDBs = @[ [self bibleDatabaseForText:theGreekBible], [self bibleDatabaseForText:theEnglishBible] ];
  
  for (int i=0; i<2; i++)
  {
    FMDatabaseQueue *db = theDBs[i];
    [db inDatabase:^(FMDatabase *db)
      {
        FMResultSet *s =
          [db executeQuery: [NSString stringWithFormat:
                             @"SELECT DISTINCT bibleBook, bibleChapter, bibleVerse FROM content WHERE bibleID = ? AND (%@) ORDER BY 1,2,3",
                             searchPhrase],
           [NSNumber numberWithInt: (i==0?theGreekBible:theEnglishBible)]];

        while ([s next])
        {
          int theBook          = [s intForColumnIndex: 0];
          int theChapter       = [s intForColumnIndex: 1];
          int theVerse         = [s intForColumnIndex: 2];
          PKReference *theReference = [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:theVerse];
          [theMatches addObject: theReference];
        }
        [s close];
      }
    ];
  }

  return [theMatches copy];
}

@end