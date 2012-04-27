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
#import "FMResultSet.h"

@implementation PKBible

/**
 *
 * Returns the canonical name for a Bible book, given the book number. For example, 40=Matthew
 *
 */
    +(NSString *) nameForBook: (int)theBook
    {
    //
    // Books of the bible and chapter count obtained from http://www.deafmissions.com/tally/bkchptrvrs.html
    //
        NSArray *bookList = [NSArray arrayWithObjects: 
                      @"Genesis", @"Exodus", @"Leviticus", @"Numbers", @"Deuteronomy", @"Joshua", @"Judges", @"Ruth",
                      @"1 Samuel", @"2 Samuel", @"1 Kings", @"2 Kings", @"1 Chronicles", @"2 Chronicles",
                      @"Ezra", @"Nehemia", @"Esther", @"Job", @"Psalms", @"Proverbs", @"Ecclesiastes",
                      @"Song of Solomon", @"Isaiah", @"Jeremiah", @"Lamentations", @"Ezekial", @"Daniel",
                      @"Hosea", @"Joel", @"Amos", @"Obadiah", @"Jonah", @"Micah", @"Nahum", @"Habakkuk",
                      @"Zephaniah", @"Haggai", @"Zechariah", @"Malachi",
                      // New Testament
                      @"Matthew", @"Mark", @"Luke", @"John", @"Acts", @"Romans", @"1 Corinthians",
                      @"2 Corinthians", @"Galations", @"Ephesians", @"Philippians", @"Colossians",
                      @"1 Thessalonians", @"2 Thessalonians", @"1 Timothy", @"2 Timothy", @"Titus",
                      @"Philemon", @"Hebrews", @"James", @"1 Peter", @"2 Peter", @"1 John", @"2 John",
                      @"3 John", @"Jude", @"Revelation", nil];
        return [bookList objectAtIndex:theBook-1];
    }
    
/**
 *
 * Returns the numerical 3-letter code for the given book. For example, 40 = 40N, 10 = 10O
 *
 */
    +(NSString *) numericalThreeLetterCodeForBook:(int)theBook
    {
        NSArray *bookList = [NSArray arrayWithObjects:
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
                          @"64N", @"65N", @"66N", nil];
        return [bookList objectAtIndex:theBook-1];
    }
    
/**
 *
 * Returns the 3-letter abbreviation for a given book. For example, 40 = Mat
 *
 */
    +(NSString *) abbreviationForBook:(int)theBook
    {
        NSArray *bookList = [NSArray arrayWithObjects:
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
                          @"3Jo", @"Jud", @"Rev", nil];
        return [bookList objectAtIndex:theBook-1];
    }
    
/**
 *
 * Returns the number of chapters in the given Bible book.
 *
 */
    +(int) countOfChaptersForBook:(int)theBook 
    {
        NSArray *chapterCountList = [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:50], 
                              [NSNumber numberWithInt:40], 
                              [NSNumber numberWithInt:27], 
                              [NSNumber numberWithInt:36], 
                              [NSNumber numberWithInt:34], 
                              [NSNumber numberWithInt:24], 
                              [NSNumber numberWithInt:21], 
                              [NSNumber numberWithInt:4], 
                              [NSNumber numberWithInt:31], 
                              [NSNumber numberWithInt:24], 
                              [NSNumber numberWithInt:22], 
                              [NSNumber numberWithInt:25], 
                              [NSNumber numberWithInt:29], 
                              [NSNumber numberWithInt:36], 
                              [NSNumber numberWithInt:10], 
                              [NSNumber numberWithInt:13], 
                              [NSNumber numberWithInt:10], 
                              [NSNumber numberWithInt:42], 
                              [NSNumber numberWithInt:150],
                              [NSNumber numberWithInt:31], 
                              [NSNumber numberWithInt:12] ,
                              [NSNumber numberWithInt:8] ,
                              [NSNumber numberWithInt:66] ,
                              [NSNumber numberWithInt:52], 
                              [NSNumber numberWithInt:5], 
                              [NSNumber numberWithInt:48], 
                              [NSNumber numberWithInt:12], 
                              [NSNumber numberWithInt:14], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:9], 
                              [NSNumber numberWithInt:1], 
                              [NSNumber numberWithInt:4], 
                              [NSNumber numberWithInt:7], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:2], 
                              [NSNumber numberWithInt:14], 
                              [NSNumber numberWithInt:4],
                              // New Testament
                              [NSNumber numberWithInt:28], 
                              [NSNumber numberWithInt:16], 
                              [NSNumber numberWithInt:24], 
                              [NSNumber numberWithInt:21], 
                              [NSNumber numberWithInt:28], 
                              [NSNumber numberWithInt:16], 
                              [NSNumber numberWithInt:16], 
                              [NSNumber numberWithInt:13], // re: issue #29
                              [NSNumber numberWithInt:6], 
                              [NSNumber numberWithInt:6], 
                              [NSNumber numberWithInt:4], 
                              [NSNumber numberWithInt:4], 
                              [NSNumber numberWithInt:5], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:6], 
                              [NSNumber numberWithInt:4], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:1], 
                              [NSNumber numberWithInt:13], 
                              [NSNumber numberWithInt:5], 
                              [NSNumber numberWithInt:5], 
                              [NSNumber numberWithInt:3], 
                              [NSNumber numberWithInt:5], 
                              [NSNumber numberWithInt:1], 
                              [NSNumber numberWithInt:1], 
                              [NSNumber numberWithInt:1], 
                              [NSNumber numberWithInt:22]
                              , nil ];
        return [[chapterCountList objectAtIndex:theBook-1] intValue];
    }
    
/**
 *
 * Returns the number of verses for the given book and chapter.
 *
 */
    +(int) countOfVersesForBook:(int)theBook forChapter:(int)theChapter 
    {
        int totalGreekCount =0 ;
        int totalEnglishCount =0;
        int totalCount;
        NSString *theSQL = @"SELECT count(*) FROM content WHERE bibleID=? AND bibleBook = ? AND bibleChapter = ?";
    
        int currentGreekBible = [[PKSettings instance] greekText];
        int currentEnglishBible = [[PKSettings instance] englishText];
        FMDatabase *db = [[PKDatabase instance] bible];
        
        FMResultSet *s = [db executeQuery:theSQL, [NSNumber numberWithInt:currentGreekBible], 
                                                  [NSNumber numberWithInt:theBook],
                                                  [NSNumber numberWithInt:theChapter]];
        while ([s next])
        {
            totalGreekCount = [s intForColumnIndex:0];
        }

        s = [db executeQuery:theSQL, [NSNumber numberWithInt:currentEnglishBible], 
                                                  [NSNumber numberWithInt:theBook],
                                                  [NSNumber numberWithInt:theChapter]];
        while ([s next])
        {
            totalEnglishCount = [s intForColumnIndex:0];
        }
        
        totalCount = MAX(totalGreekCount, totalEnglishCount);
        
        return totalCount;
    }
    
/**
 *
 * Returns the text for a given reference (book chapter:verse) and side (1=greek,2=english)
 *
 * Note: adds the verse # to the english side. TODO?: Add to greek side too?
 *
 */
    +(NSString *) getTextForBook:(int)theBook forChapter:(int)theChapter forVerse:(int)theVerse forSide:(int)theSide
    {
        int currentBible = (theSide==1 ? [[PKSettings instance] greekText] : [[PKSettings instance] englishText]);
        FMDatabase *db = [[PKDatabase instance] bible];
        NSString *theSQL = @"SELECT bibleText FROM content WHERE bibleID=? AND bibleBook=? AND bibleChapter=? AND bibleVerse=?";
        NSString *theText;
        NSString *theRef = [NSString stringWithFormat:@"%i ", theVerse];
        
        FMResultSet *s = [db executeQuery:theSQL, [NSNumber numberWithInt:currentBible] , 
                                                  [NSNumber numberWithInt:theBook],
                                                  [NSNumber numberWithInt:theChapter],
                                                  [NSNumber numberWithInt:theVerse]];
        while ([s next])
        {
            theText = [s stringForColumnIndex:0];
        }
        
        if (theSide == 2)
        {
            if (theText != nil)
            {
                theText = [theRef stringByAppendingString:theText];
            }
            else 
            {
                theText = theRef;
            }
        }
        theText = [theText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return theText;
    }

/**
 *
 * Return the text for a given chapter (book chapter) and side (1=greek, 2=english). Note that
 * the english text has verse #s prepended to the text. Also note that is entirely possible
 * for the array on one side to be of a different length than the other side (Notably, Romans 13,16)
 *
 */
    +(NSArray *) getTextForBook:(int)theBook forChapter:(int)theChapter forSide:(int)theSide
    {
        int currentBible = (theSide==1 ? [[PKSettings instance] greekText] : [[PKSettings instance] englishText]);
        FMDatabase *db = [[PKDatabase instance] bible];
        
        NSString *theSQL = @"SELECT bibleText FROM content WHERE bibleID=? AND bibleBook = ? AND bibleChapter = ?";
        //NSArray *theArray = [[NSArray alloc] init];
        NSMutableArray *theArray = [[NSMutableArray alloc] init];
        
        FMResultSet *s = [db executeQuery:theSQL, [NSNumber numberWithInt:currentBible], 
                                                  [NSNumber numberWithInt:theBook],
                                                  [NSNumber numberWithInt:theChapter]];
        int i=1;
        while ([s next])
        {
            NSString *theText = [s stringForColumnIndex:0];
            NSString *theRef = [NSString stringWithFormat:@"%i ", i];
            if (theSide == 2)
            {
                theText = [theRef stringByAppendingString:theText];
            }
            theText = [theText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [theArray addObject:theText];
            i++;
        }
        
        return theArray;
    }

    
/**
 *
 * Returns a string for the given passage. For example, for Matthew(book 40), Chapter 1, Verse 1
 * we return 40N.1.1 . Most useful when maintaining dictionary keys. Otherwise, it is better
 * and faster to use the book/chapter/verse method.
 *
 */
    +(NSString *) stringFromBook:(int)theBook forChapter:(int)theChapter forVerse:(int)theVerse
    {
        NSString *theString;
        theString = [[[[[self numericalThreeLetterCodeForBook:theBook] stringByAppendingString:@"."]
                         stringByAppendingFormat:@"%i", theChapter] stringByAppendingString:@"."]
                         stringByAppendingFormat:@"%i", theVerse];
        return theString;
    }
    
/**
 *
 * Returns a shortened passage reference, containing the book and chapter. (No verse reference.)
 *
 * For example, given Matthew Chapter 1 (book 40), return 40N.1
 *
 */
    +(NSString *) stringFromBook:(int)theBook forChapter:(int)theChapter
    {
        NSString *theString;
        theString = [[[self numericalThreeLetterCodeForBook:theBook] stringByAppendingString:@"."] 
                       stringByAppendingFormat:@"%i", theChapter];
        return theString;
    }

/**
 *
 * Returns the book portion of a string formatted by stringFromBook:forChapter:forVerse
 *
 * For example, given 40N.1.1, return 40
 *
 */
    +(int) bookFromString:(NSString *)theString
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
    +(int) chapterFromString:(NSString *)theString
    {
    
        // return the chapter portion of a string
        int firstPeriod = [theString rangeOfString:@"."].location;
        int secondPeriod = [theString rangeOfString:@"." options:0 range:NSMakeRange(firstPeriod+1, [theString length]-(firstPeriod+1))].location;
        
        return [[theString substringWithRange:NSMakeRange(firstPeriod+1, secondPeriod-(firstPeriod+1))] intValue];
    }
    
/**
 *
 * Returns the verse portion of a string formatted by stringfromBook:forChapter:forVerse
 *
 * For example, given 40N.12.1, returns 1
 *
 */
    +(int) verseFromString:(NSString *)theString
    {
        // return the verse portion of a string
        int firstPeriod = [theString rangeOfString:@"."].location;
        int secondPeriod = [theString rangeOfString:@"." options:0 range:NSMakeRange(firstPeriod+1, [theString length]-(firstPeriod+1))].location;
        
        return [[theString substringFromIndex:secondPeriod+1] intValue];
    }
    
/**
 *
 * Return the maximum height of the desired formatted text (in theWordArray). If withParsings
 * is YES, we include the height of the Strong's Numbers and (potentially) the Morphology.
 *
 */
    +(CGFloat)formattedTextHeight: (NSArray *)theWordArray withParsings:(BOOL)parsed
    {
        // this is our font
        UIFont *theFont = [UIFont fontWithName:[[PKSettings instance] textFontFace]
                                          size:[[PKSettings instance] textFontSize]];
        // we need to know the height of an M (* the setting...)
        CGFloat lineHeight = [@"M" sizeWithFont:theFont].height;
        lineHeight = lineHeight * ((float)[[PKSettings instance] textLineSpacing] / 100.0);
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
            columnHeight += lineHeight; // for G#s
        }
        
        CGFloat maxY = 0.0;
        for (int i=0; i<[theWordArray count];i++)
        {
            NSArray *theWordElement = [theWordArray objectAtIndex:i];
            //NSString *theWord = [theWordElement objectAtIndex:0];
            //int theWordType = [[theWordElement objectAtIndex:1] intValue];
            //CGFloat wordX = [[theWordElement objectAtIndex:2] floatValue];
            CGFloat wordY = [[theWordElement objectAtIndex:3] floatValue];
            
            if (wordY > maxY)
            {
                maxY = wordY;
            }
        }
        
        //maxY += columnHeight + lineHeight;
        maxY += lineHeight + (lineHeight / 2); //RE: ISSUE # 5
        
        return maxY;
    }
    
/**
 *
 * Return the width of a given column for the given bounds, based upon the user's
 * column settings. TODO: Doesn't feel quite right on a smaller screen, though
 *
 */
    +(CGFloat) columnWidth: (int) theColumn forBounds: (CGRect)theRect
    {
        // define our column (based on incoming rect)
        float columnMultiplier = 1;
        int columnSetting = [[PKSettings instance] layoutColumnWidths];
        if (columnSetting == 0) // 600930
        {
            if (theColumn == 1) {   columnMultiplier = 1.75;    }
            if (theColumn == 2) {   columnMultiplier = 1.25;    }
        }
        if (columnSetting == 1) // 300960
        {
            if (theColumn == 1) {   columnMultiplier = 1.25;    }
            if (theColumn == 2) {   columnMultiplier = 1.75;    }
        }
        if (columnSetting == 2) // 600930
        {
            columnMultiplier = 1.5;
        }
        if (theColumn == 3) { columnMultiplier = 0.25; }
        columnMultiplier = columnMultiplier / 3;
        
        CGFloat columnWidth = (theRect.size.width) * columnMultiplier;
        
        return columnWidth;
    }
    
    +(NSString *)transliterate: (NSString*)theWord
    {
        NSMutableString *theNewWord = [theWord mutableCopy];
       
        [theNewWord replaceOccurrencesOfString:@"α" withString:@"a" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"β" withString:@"b" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"γ" withString:@"g" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"δ" withString:@"d" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ε" withString:@"e" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ζ" withString:@"z" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"η" withString:@"e" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"θ" withString:@"th" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ι" withString:@"i" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"κ" withString:@"k" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"λ" withString:@"l" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"μ" withString:@"m" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ν" withString:@"n" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ξ" withString:@"c" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ο" withString:@"o" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"π" withString:@"p" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ρ" withString:@"r" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"σ" withString:@"s" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ς" withString:@"s" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"τ" withString:@"t" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"υ" withString:@"u" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"φ" withString:@"ph" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"χ" withString:@"ch" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ψ" withString:@"ps" options:0 range:NSMakeRange(0,  [theNewWord length])];
        [theNewWord replaceOccurrencesOfString:@"ω" withString:@"o" options:0 range:NSMakeRange(0,  [theNewWord length])];
        
        return theNewWord;
    }
    
/**
 *
 * Formats the supplied text into an array of positions and types that will fit
 * within the given column's width and perform word-wrap where necessary. 
 *
 */
    +(NSArray *)formatText: (NSString *)theText forColumn: (int)theColumn withBounds: (CGRect)theRect withParsings: (BOOL)parsed
    {
        // should we include the morphology?
        BOOL showMorphology = [[PKSettings instance] showMorphology];
        
        // should we transliterate?
        BOOL transliterate = [[PKSettings instance] transliterateText];
    
        // this array will contain the word elements
        NSMutableArray *theWordArray = [[NSMutableArray alloc]init];
        
        // this is our font
        UIFont *theFont = [UIFont fontWithName:[[PKSettings instance] textFontFace]
                                          size:[[PKSettings instance] textFontSize]];
        if (theFont == nil)
        {
            theFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular", [[PKSettings instance] textFontFace]]
                                                  size:[[PKSettings instance] textFontSize]];
        }
        if (theFont == nil)
        {
            theFont = [UIFont fontWithName:@"Helvetica"
                                                  size:[[PKSettings instance] textFontSize]];
        }

        UIFont *theBoldFont = [UIFont fontWithName:[[PKSettings instance] textGreekFontFace]
                                              size:[[PKSettings instance] textFontSize]];
        
        if (theBoldFont == nil)
        {
            theBoldFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular", [[PKSettings instance] textGreekFontFace]]
                                          size:[[PKSettings instance] textFontSize]];
        }
        if (theBoldFont == nil)     // just in case there's no alternate
        {
            theBoldFont = theFont;
        }
        
        // set Margin
        CGFloat theMargin = 5;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            // iPad gets wider margins
            theMargin = 50;
        }
        // set starting points
        CGFloat startX = theRect.origin.x + theMargin; // some margin
        CGFloat startY = 0; //theRect.origin.y;
        
        CGFloat curX = startX;
        CGFloat curY = startY;
        
        // maximum point
        CGFloat endX   = startX + theRect.size.width;
        
        CGFloat columnWidth = [self columnWidth:theColumn forBounds:theRect]; // (theRect.size.width) * columnMultiplier;
        
        // new maximum point
        endX = startX + columnWidth;
        if (theColumn == 2)
        {
            endX = endX - theMargin;
        }
                                                  
        // split by spaces
        NSArray *matches = [theText componentsSeparatedByString:@" "];
        
        // we need to know the width of a space
        CGFloat spaceWidth = [@" " sizeWithFont:theFont].width;
        // we need to know the height of an M (* the setting...)
        CGFloat lineHeight = [@"M" sizeWithFont:theFont].height;
        lineHeight = lineHeight * ((float)[[PKSettings instance] textLineSpacing] / 100.0);
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
            columnHeight += lineHeight; // for G#s
        }
        CGFloat yOffset = 0.0;
        
        // give us some margin at the top
        startY = lineHeight / 2; //RE: ISSUE # 5
        curY = startY; //RE: ISSUE # 5
        
        // iterate through each word and wrap where necessary, building an
        // array of x, y points and words.
        
        int thePriorWordType = -1;
        int theWordType = -1;
        NSString *theWord;
        NSString *thePriorWord;
        
        CGFloat maxX = 0.0;
        
        for (int i=0; i<[matches count]; i++)
        {
            
            // move priors
            thePriorWordType = theWordType;
            thePriorWord = theWord;
            
            // got the current word
            theWord = [matches objectAtIndex:i];
            
            // transliterate?
            if (transliterate)
            {
                theWord = [self transliterate:theWord];
            }
            
            // and its size
            CGSize theSize;
            
            
            // determine the type of the word
            theWordType = 0;    // by default, we're a regular word
            yOffset = 0.0;
            
            
            if (theColumn == 1 && [theWord length]>1) // we only do this for greek text
            {
                // originally we used regular expressions, but they are SLOW
                // G#s are of the form G[0-9]+
                
                if ( [[theWord substringToIndex:1] isEqualToString:@"G"] &&
                     [[theWord substringFromIndex:1] intValue] > 0 )
                {
                    // we're a G#
                    theWordType = 10;
                    yOffset = lineHeight;
                }
                else 
                {
                    // are we a VARiant? (regex: VAR[0-9]
                    if ( [[theWord substringToIndex:2] isEqualToString:@"VAR"] )
                    {
                        theWordType = 0; // we're really just a regular word.
                        yOffset = 0.0;
                    }
                    else
                    {
                        // are we a morphology word? [A-Z]+[A-Z0-9\\-]+
                        if ( [[theWord uppercaseString] isEqualToString:theWord] 
                             && thePriorWordType >= 10)
                        {
                            // we are!
                            theWordType = 20;
                            yOffset = lineHeight *2;
                        }
                    }
                }
            }
            
            
            if (theColumn == 1 && theWordType == 0)
            {
                theSize = [theWord sizeWithFont:theBoldFont];
            }
            else
            {
                theSize  = [theWord sizeWithFont:theFont];
            }

            // determine this word's position, and if we should word-wrap or not.
            if (theWordType <= thePriorWordType || (theColumn == 2 && i>0))
            {
                // we're a new variation on the column. curX can move foward by maxX
                curX += maxX + spaceWidth;
                if (curX + theSize.width> endX-maxX-spaceWidth)
                {
                    curX = startX;
                    curY += columnHeight;
                }
                maxX = 0.0; // reset maximum width
            }
            
            if (theSize.width > maxX)
            {
                maxX = theSize.width;
            }
            
            // start creating our word element
            NSArray *theWordElement = [NSArray arrayWithObjects: theWord,
                                                                 [NSNumber numberWithInt:theWordType],
                                                                 [NSNumber numberWithFloat:curX],
                                                                 [NSNumber numberWithFloat:(curY + yOffset)], 
                                                                 [NSNumber numberWithFloat:theSize.width],
                                                                 [NSNumber numberWithFloat:theSize.height],
                                                                 nil];
            if ( showMorphology || (theWordType < 20 && !showMorphology) )
            {
                [theWordArray addObject:theWordElement]; 
            }
            
            
        }
        
        return theWordArray;
    }
    
    +(NSArray *) passagesMatching:(NSString *)theTerm
    {
        int currentGreekBible = [[PKSettings instance] greekText];
        int currentEnglishBible=[[PKSettings instance] englishText];
        
        return [self passagesMatching:theTerm withGreekBible:currentGreekBible andEnglishBible:currentEnglishBible];
    }
    
    +(int) parsedVariant: (int)theBook
    {
        int theParsedBook = -1; // return this if nothing matches
        FMDatabase *db = [[PKDatabase instance] bible];
        FMResultSet *s = [db executeQuery:@"SELECT IFNULL(bibleParsedID,-1) FROM bibles WHERE bibleID=?",[NSNumber numberWithInt:theBook]];
        if ([s next])
        {
            theParsedBook = [s intForColumnIndex:0];
        }
        return theParsedBook;
    }
    
    +(BOOL) checkParsingsForBook: (int)theBook
    {
        return (theBook == [self parsedVariant:theBook]);
    }
    
    +(NSArray *) passagesMatching:(NSString *)theTerm requireParsings: (BOOL)parsings
    {
        int currentGreekBible = [[PKSettings instance] greekText];
        int currentEnglishBible=[[PKSettings instance] englishText];
        
        if (parsings)
        {
            int parsedGreekBible = [self parsedVariant:currentGreekBible];
            if (parsedGreekBible>-1)
            {
                currentGreekBible = parsedGreekBible;
            }
        }
        return [self passagesMatching:theTerm withGreekBible:currentGreekBible andEnglishBible:currentEnglishBible];
    }
    

    +(NSArray *) passagesMatching: (NSString *)theTerm withGreekBible: (int)theGreekBible andEnglishBible: (int)theEnglishBible
    {
        NSMutableArray *theMatches = [[NSMutableArray alloc] init];
        FMDatabase *db = [[PKDatabase instance] bible];
        NSString *theLike = [NSString stringWithFormat:@"%%%@%%", [[theTerm lowercaseString] // RE: ISSUE #18
                                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        FMResultSet *s = [db executeQuery:@"SELECT bibleBook, bibleChapter, bibleVerse FROM content WHERE bibleID in (?,?) AND TRIM(LOWER(bibleText)) LIKE ? ORDER BY 1,2,3",
                                           [NSNumber numberWithInt:theGreekBible],
                                           [NSNumber numberWithInt:theEnglishBible],
                                           theLike];
        while ([s next])
        {
            int theBook = [s intForColumnIndex:0];
            int theChapter=[s intForColumnIndex:1];
            int theVerse=[s intForColumnIndex:2];
            NSString *thePassage = [PKBible stringFromBook:theBook forChapter:theChapter forVerse:theVerse];
            [theMatches addObject:thePassage];
        }
        
        return [theMatches copy];
    }



@end
