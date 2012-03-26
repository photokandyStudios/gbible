//
//  PKSettings.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKSettings.h"
#import "PKConstants.h"
#import "PKDatabase.h"


@implementation PKSettings
    @synthesize textFontFace;
    @synthesize textLineSpacing;
    @synthesize textVerseSpacing;
    @synthesize layoutColumnWidths;
    @synthesize greekText;
    @synthesize englishText;
    @synthesize transliterateText;
    @synthesize showNotesInline;
    @synthesize useICloud;
    @synthesize textFontSize;
    @synthesize showMorphology;
    
    @synthesize currentBook;
    @synthesize currentChapter;
    @synthesize currentVerse;
    @synthesize topVerse;
    @synthesize noteBook;
    @synthesize noteChapter;
    @synthesize noteVerse;
    @synthesize currentTextHighlight;
    @synthesize lastStrongsLookup;
    @synthesize lastSearch;
    @synthesize oldNote;
    @synthesize currentNote;
    
    static id _instance;

    +(id) instance
    {
        @synchronized (self)
        {
            if (!_instance)
            {
                _instance = [[self alloc] init];
            }
        }
        return _instance;
    }
    
    -(void) reloadSettings
    {
        // create settings if they don't exist...
        [self createDefaultSettings];
        
        // now, load up our settings
        textFontFace    = [self loadSetting: PK_SETTING_FONTFACE];
        textFontSize    = [[self loadSetting: PK_SETTING_FONTSIZE] intValue];
        textLineSpacing = [[self loadSetting: PK_SETTING_LINESPACING] intValue];
        textVerseSpacing= [[self loadSetting: PK_SETTING_VERSESPACING] intValue];
        layoutColumnWidths=[[self loadSetting: PK_SETTING_COLUMNWIDTHS] intValue];
        greekText       = [[self loadSetting: PK_SETTING_GREEKTEXT] intValue];
        englishText     = [[self loadSetting: PK_SETTING_ENGLISHTEXT] intValue];
        transliterateText=[[self loadSetting: PK_SETTING_TRANSLITERATE] boolValue];
        showNotesInline = [[self loadSetting: PK_SETTING_INLINENOTES] boolValue];
        showMorphology  = [[self loadSetting: PK_SETTING_SHOWMORPHOLOGY] boolValue];
        useICloud       = [[self loadSetting: PK_SETTING_USEICLOUD] boolValue];
        
        currentBook     = [[self loadSetting: @"current-book"] intValue];
        currentChapter  = [[self loadSetting: @"current-chapter"] intValue];
        currentVerse    = [[self loadSetting: @"current-verse"] intValue];
        
        topVerse        = [[self loadSetting: @"top-verse"] intValue];
        
        noteBook        = [[self loadSetting: @"note-book"] intValue];
        noteChapter     = [[self loadSetting: @"note-chapter"] intValue];
        noteVerse       = [[self loadSetting: @"note-verse"] intValue];
        
        currentTextHighlight = [self loadSetting: @"current-text-highlight"];
        lastStrongsLookup    = [self loadSetting: @"last-strongs-lookup"];
        lastSearch           = [self loadSetting: @"last-search"];
        
        oldNote              = [self loadSetting: @"old-note"];
        currentNote          = [self loadSetting: @"current-note"];
        
    }
    
    -(NSString *) loadSetting: (NSString *)theSetting
    {
        NSString *theResult;
        FMDatabase *content = ((PKDatabase*) [PKDatabase instance]).content;
        FMResultSet *s = [content executeQuery:@"SELECT value FROM settings \
                                                 WHERE setting=?", theSetting];
        if ([s next])
        {
            theResult = [s stringForColumnIndex:0];
        }
        
        return theResult;
        
    }
    
    -(void) saveCurrentReference
    {
        [self saveSetting: @"current-book" valueForSetting:[NSString stringWithFormat:@"%i", currentBook]];
        [self saveSetting: @"current-chapter" valueForSetting:[NSString stringWithFormat:@"%i", currentChapter]];
        [self saveSetting: @"current-verse" valueForSetting:[NSString stringWithFormat:@"%i", currentVerse]];
        [self saveSetting: @"top-verse" valueForSetting:[NSString stringWithFormat:@"%i", topVerse]];
    }
    -(void) saveSettings
    {
        [self saveSetting: PK_SETTING_FONTFACE valueForSetting: textFontFace];
        [self saveSetting: PK_SETTING_FONTSIZE valueForSetting: [NSString stringWithFormat:@"%i",textFontSize]];
        [self saveSetting: PK_SETTING_LINESPACING valueForSetting: [NSString stringWithFormat:@"%i",textLineSpacing]];
        [self saveSetting: PK_SETTING_VERSESPACING valueForSetting: [NSString stringWithFormat:@"%i",textVerseSpacing]];
        [self saveSetting: PK_SETTING_COLUMNWIDTHS valueForSetting: [NSString stringWithFormat:@"%i",layoutColumnWidths]];
        [self saveSetting: PK_SETTING_GREEKTEXT valueForSetting: [NSString stringWithFormat:@"%i",greekText]];
        [self saveSetting: PK_SETTING_ENGLISHTEXT valueForSetting: [NSString stringWithFormat:@"%i",englishText]];
        [self saveSetting: PK_SETTING_TRANSLITERATE valueForSetting: (transliterateText ? @"YES" : @"NO") ];
        [self saveSetting: PK_SETTING_INLINENOTES valueForSetting: (showNotesInline ? @"YES" : @"NO") ];
        [self saveSetting: PK_SETTING_SHOWMORPHOLOGY valueForSetting: (showMorphology ? @"YES" : @"NO") ];
        [self saveSetting: PK_SETTING_USEICLOUD valueForSetting: (useICloud ? @"YES" : @"NO") ];
        
        [self saveSetting: @"current-book" valueForSetting:[NSString stringWithFormat:@"%i", currentBook]];
        [self saveSetting: @"current-chapter" valueForSetting:[NSString stringWithFormat:@"%i", currentChapter]];
        [self saveSetting: @"current-verse" valueForSetting:[NSString stringWithFormat:@"%i", currentVerse]];

        [self saveSetting: @"top-verse" valueForSetting:[NSString stringWithFormat:@"%i", topVerse]];

        [self saveSetting: @"note-book" valueForSetting:[NSString stringWithFormat:@"%i", noteBook]];
        [self saveSetting: @"note-chapter" valueForSetting:[NSString stringWithFormat:@"%i", noteChapter]];
        [self saveSetting: @"note-verse" valueForSetting:[NSString stringWithFormat:@"%i", noteVerse]];
        
        [self saveSetting: @"current-text-highlight" valueForSetting:currentTextHighlight];
        [self saveSetting: @"last-strongs-lookup" valueForSetting:lastStrongsLookup];
        [self saveSetting: @"last-search" valueForSetting:lastSearch];

        [self saveSetting: @"old-note" valueForSetting:oldNote];
        [self saveSetting: @"current-note" valueForSetting:currentNote];
        
    }
    
    -(void) saveSetting: (NSString *)theSetting valueForSetting: (NSString *)theValue
    {
        FMDatabase *content = ((PKDatabase*) [PKDatabase instance]).content;
        BOOL theResult = YES;
        FMResultSet *resultSet;
        int rowCount = 0;
        
        theResult = [content executeUpdate:@"UPDATE settings SET value=? WHERE setting=?",
                             theValue, theSetting ];
                             
        // theResult is almost always TRUE -- so we need to query the db for the value we just set...
        resultSet = [content executeQuery:@"SELECT * FROM settings WHERE setting=?",theSetting];
        if ([resultSet next])
        {
            rowCount++;
        }
        if (rowCount<1)
        {
            // updating didn't work -- insert the value instead.
            theResult = [content executeUpdate:@"INSERT INTO settings VALUES (?,?)",
                             theSetting, theValue ];
        }
        if (!theResult)
        {
            NSLog(@"Couldn't save %@ into %@", theValue, theSetting);
        }
    }
    -(BOOL) createDefaultSettings
    {
        BOOL returnVal = YES;
        // get local versions of our databases
        FMDatabase *content = ((PKDatabase*) [PKDatabase instance]).content;
        
        // create our settings table
        // it's really just a key-value store
        returnVal = [content executeUpdate:@"CREATE TABLE settings ( \
                                                 setting VARCHAR(255), \
                                                 value   VARCHAR(4096) \
                                             )"];
        if (returnVal)
        {
            textFontSize = 12;  // 12pt default font size
            textLineSpacing = PK_LS_NORMAL;
            textVerseSpacing = PK_VS_NONE;
            layoutColumnWidths = PK_CW_WIDEGREEK;
            greekText = PK_BIBLETEXT_BYZP;
            englishText=PK_BIBLETEXT_YLT;
            transliterateText = NO;
            showNotesInline = NO;
            showMorphology = YES;
            useICloud = NO;
            textFontFace = @"Helvetica";
            
            currentBook = 40;   // Matthew
            currentChapter = 1; // Chapter 1
            currentVerse = 1;   // Verse 1
            topVerse = 1;       // Top visible verse is 1
            noteBook = 0;       // no note
            noteChapter = 0;    // "
            noteVerse = 0;      // "
            currentTextHighlight = @"";
            lastStrongsLookup = @"";
            lastSearch = @"";
            oldNote = @"";
            currentNote = @"";
            
            [self saveSettings];
            // done, return success or failure
        }
        return returnVal;
    }
    
    -(void) dealloc
    {
        textFontFace = nil;
    }
@end
