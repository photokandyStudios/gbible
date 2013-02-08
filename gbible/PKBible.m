//
//  PKBible.m
//  gbible
//
//  Created by Kerri Shotts on 3/19/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBible.h"
#import "PKSettings.h"
#import "PKDatabase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "PKConstants.h"
#import "searchutils.h"
#import <Parse/Parse.h>

@implementation PKBible

+(FMDatabaseQueue *) bibleDatabaseForText: (int) theText
{
  if (theText <= 100) return [[PKDatabase instance] bible];
  return [[PKDatabase instance] userBible];
}

+(NSArray *) bibleArray
{
  return @[ [[PKDatabase instance] bible],
            [[PKDatabase instance] userBible] ];
}

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

+(BOOL) isTextBuiltIn: (int) theText
{
  return [self text: theText inDB:[[PKDatabase instance]bible] withColumn:PK_TBL_BIBLES_ID] != nil ? YES : NO;
}

+(BOOL) isTextInstalled: (int) theText
{
  return [self text: theText inDB:[[PKDatabase instance]userBible] withColumn:PK_TBL_BIBLES_ID] != nil ? YES : NO;
}

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

+(NSArray *) builtInTextsWithColumn: (int) column
{
  return [self availableTextsInDB:[[PKDatabase instance]bible] withColumn:column];
}

+(NSArray *) installedTextsWithColumn: (int) column
{
  return [self availableTextsInDB:[[PKDatabase instance]userBible] withColumn:column];
}

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
        if ([side isEqualToString:@"greek"])  lside = @"leftSide";
        if ([side isEqualToString:@"english"])  lside = @"rightSide";
        
        FMResultSet *s          =
          [db executeQuery:
           @"select bibleAbbreviation, bibleAttribution, bibleSide, bibleID, bibleName, bibleParsedID from bibles where bibleSide in (?,?) order by bibleAbbreviation",
           side, lside];

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

+(NSArray *) availableOriginalTexts: (int) column
{
  return [PKBible availableTextsForSide: @"greek" andColumn: column];
}

+(NSArray *) availableHostTexts: (int) column
{
  return [PKBible availableTextsForSide: @"english" andColumn: column];
  // really a misnomer; we should allow the reader to choose any language edition of their choosing.
}

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
 * Returns a string for the given passage. For example, for Matthew(book 40), Chapter 1, Verse 1
 * we return 40N.1.1 . Most useful when maintaining dictionary keys. Otherwise, it is better
 * and faster to use the book/chapter/verse method.
 *
 */
+(NSString *) stringFromBook: (int) theBook forChapter: (int) theChapter forVerse: (int) theVerse
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
+(NSString *) stringFromBook: (int) theBook forChapter: (int) theChapter
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
+(int) bookFromString: (NSString *) theString
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
+(int) chapterFromString: (NSString *) theString
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
+(int) verseFromString: (NSString *) theString
{
  // return the verse portion of a string
  int firstPeriod  = [theString rangeOfString: @"."].location;
  int secondPeriod =
    [theString rangeOfString: @"." options: 0 range: NSMakeRange( firstPeriod + 1, [theString length] -
                                                                  (firstPeriod + 1) )].location;

  return [[theString substringFromIndex: secondPeriod + 1] intValue];
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
                                         size: [[PKSettings instance] textFontSize]];
  // we need to know the height of an M (* the setting...)
  CGFloat lineHeight   = [@"M" sizeWithFont: theFont].height;
  lineHeight    = lineHeight * ( (float)[[PKSettings instance] textLineSpacing] / 100.0 );
  // determine the maximum size of the column (1 line, 2 lines, 3 lines?)
  CGFloat columnHeight = lineHeight;
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
 * column settings. TODO: Doesn't feel quite right on a smaller screen, though
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

//  if (( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
//       && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ) || (compression))
  if (compression)
  {
    return (theRect.size.width);
//          return ((theRect.size.width) - (theMargin));
  }

  // define our column (based on incoming rect)
  float columnMultiplier = 1;
  int columnSetting      = [[PKSettings instance] layoutColumnWidths];

  if (columnSetting == 0)       // 600930
  {
    if (theColumn == 1)
    {
      columnMultiplier = 1.75;
    }

    if (theColumn == 2)
    {
      columnMultiplier = 1.25;
    }
  }

  if (columnSetting == 1)       // 300960
  {
    if (theColumn == 1)
    {
      columnMultiplier = 1.25;
    }

    if (theColumn == 2)
    {
      columnMultiplier = 1.75;
    }
  }

  if (columnSetting == 2)       // 600930
  {
    columnMultiplier = 1.5;
  }

  if (theColumn == 3)
  {
    columnMultiplier = 0.25;
  }
  columnMultiplier = columnMultiplier / 3;

  CGFloat columnWidth = ( (theRect.size.width) - (theMargin) ) * columnMultiplier;

  return columnWidth;
}

+(BOOL) isMorphology: (NSString *) theWord
{
  // there's no easy way to determine if a word is a morphology word. Instead, let's encode
  // the various options
  
  CFStringRef strDash = CFSTR ("-");
  
  CFStringRef theCFString = (__bridge CFStringRef)(theWord);

  if (CFStringFind(theCFString, strDash, 0).location != kCFNotFound)
    return YES;
  
/*  if ([theWord hasPrefix: @"A-"])
    return YES;

  if ([theWord hasPrefix: @"C-"])
    return YES;

  if ([theWord hasPrefix: @"D-"])
    return YES;

  if ([theWord hasPrefix: @"F-"])
    return YES;

  if ([theWord hasPrefix: @"I-"])
    return YES;

  if ([theWord hasPrefix: @"K-"])
    return YES;

  if ([theWord hasPrefix: @"N-"])
    return YES;

  if ([theWord hasPrefix: @"P-"])
    return YES;

  if ([theWord hasPrefix: @"Q-"])
    return YES;

  if ([theWord hasPrefix: @"R-"])
    return YES;

  if ([theWord hasPrefix: @"S-"])
    return YES;

  if ([theWord hasPrefix: @"T-"])
    return YES;

  if ([theWord hasPrefix: @"V-"])
    return YES;

  if ([theWord hasPrefix: @"X-"])
    return YES;

  if ([theWord hasPrefix: @"Noun-"])
    return YES;

  if ([theWord hasPrefix: @"Art-"])
    return YES;

  if ([theWord hasPrefix: @"Adj-"])
    return YES;

  if ([theWord hasPrefix: @"Adv-"])
    return YES;

  if ([theWord hasPrefix: @"RefPro-"])
    return YES;

  if ([theWord hasPrefix: @"RelPro-"])
    return YES;

  if ([theWord hasPrefix: @"IPro-"])
    return YES;

  if ([theWord hasPrefix: @"DPro-"])
    return YES;

  if ([theWord hasPrefix: @"PPro-"])
    return YES;

  if ([theWord hasPrefix: @"Ppro-"])
    return YES;

  if ([theWord hasPrefix: @"Prtcl-"])
    return YES;

  if ([theWord hasPrefix: @"PRT-"])
    return YES;

  if ([theWord hasPrefix: @"ADV-"])
    return YES;

  if ([theWord hasPrefix: @"COND-"])
    return YES;*/

  CFStringRef morphWords = CFSTR(" Adv Adj N V Heb Conj Prep Prtcl Prt Cond Inj ADV ADJ HEB CONJ PREP PRTCL PRT COND ARAM INJ ");

  NSString *theSpacedWord = [[@" " stringByAppendingString: theWord] stringByAppendingString: @" "];
  if ( CFStringFind(morphWords, (__bridge CFStringRef)(theSpacedWord), 0).location != kCFNotFound )
  {
    return YES;
  }
//  if ([morphWords rangeOfString: [NSString stringWithFormat: @" %@ ", theWord]].location != NSNotFound)
//  {
//    return YES;
//  }
  return NO;
}

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

  // should we transliterate?
  //BOOL transliterate = [[PKSettings instance] transliterateText];

  // what greek text are we?
  BOOL whichGreekText          = [[PKSettings instance] greekText];

  // this array will contain the word elements
  NSMutableArray *theWordArray = [[NSMutableArray alloc] init];

  // this is our font
  UIFont *theFont              = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                 size: [[PKSettings instance] textFontSize]];

  if (theFont == nil)
  {
    theFont = [UIFont fontWithName: [NSString stringWithFormat: @"%@-Regular", [[PKSettings instance] textFontFace]]
                              size: [[PKSettings instance] textFontSize]];
  }

  if (theFont == nil)
  {
    theFont = [UIFont fontWithName: @"Helvetica"
                              size: [[PKSettings instance] textFontSize]];
  }

  UIFont *theBoldFont = [UIFont fontWithName: [[PKSettings instance] textGreekFontFace]
                                        size: [[PKSettings instance] textFontSize]];

  if (theBoldFont == nil)
  {
    theBoldFont = [UIFont fontWithName: [NSString stringWithFormat: @"%@-Regular", [[PKSettings instance] textGreekFontFace]]
                                  size: [[PKSettings instance] textFontSize]];
  }

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
  CGFloat curY        = startY;

  // maximum point
  CGFloat endX        = startX + theRect.size.width;

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
//  if ((
//      ( theColumn == 1
//       || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
//       || UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) )
//     ) && (!compression)
//     )
    
  {
    if (parsed)
    {
      // are we going to show morphology?
      if ([[PKSettings instance] showMorphology])
      {
        columnHeight += lineHeight;
      }

      if (showStrongs)
      {
        columnHeight += lineHeight;         // for G#s
      }

      if (whichGreekText == 7
          && showInterlinear)
      {
        columnHeight += lineHeight;
      }
    }
  }

  CGFloat yOffset = 0.0;

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

      if (theOriginalWord.length > 1
          && [theOriginalWord hasPrefix: @"G"]
          && [[theOriginalWord substringFromIndex: 1] intValue] > 0)
      {
        // we're a G#
        theWordType = 10;
        yOffset     = lineHeight;

        if ([[theOriginalWord substringFromIndex: 1] intValue] > 5624)
        {
          theWord = [NSString stringWithFormat:@"M%i", [[theOriginalWord substringFromIndex: 1] intValue]];
            theWord = @"";
          theWordType =19;
          yOffset     = lineHeight *2;
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
          yOffset     = lineHeight * 3;

          if (!showMorphology)
          {
            yOffset -= lineHeight;
          }

          if (!showStrongs)
          {
            yOffset -= lineHeight;
          }

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
              yOffset     = lineHeight * 2;

              if (!showStrongs)
              {
                yOffset -= lineHeight;
              }

              if (!showMorphology)
              {
                theWord = @"";
              }
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

+(NSArray *) passagesMatching: (NSString *) theTerm
{
  int currentGreekBible   = [[PKSettings instance] greekText];
  int currentEnglishBible = [[PKSettings instance] englishText];

  return [self passagesMatching: theTerm withGreekBible: currentGreekBible andEnglishBible: currentEnglishBible];
}

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

+(BOOL) checkParsingsForBook: (int) theBook
{
  return (theBook == [self parsedVariant: theBook]);
}

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
          NSString *thePassage = [PKBible stringFromBook: theBook forChapter: theChapter forVerse: theVerse];
          [theMatches addObject: thePassage];
        }
        [s close];
      }
    ];
  }

  return [theMatches copy];
}

@end