//
//  PKSettings.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
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
#import "PKSettings.h"
#import "PKConstants.h"
#import "PKDatabase.h"

@implementation PKSettings
@synthesize textFontFace;
@synthesize textGreekFontFace;    //RE: ISSUE #6
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
@synthesize showStrongs;
@synthesize showInterlinear;
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
@synthesize lastNotesSearch;
@synthesize oldNote;
@synthesize currentNote;
@synthesize highlightColor;
@synthesize highlightTextColor;
@synthesize textTheme;
@synthesize usageStats;
@synthesize extendHighlights;
@synthesize compressRightSideText;

static id _instance;

/**
 *
 * Global instance for singletons
 *
 */
+(id) instance
{
  @synchronized(self) {
    if (!_instance)
    {
      _instance = [[self alloc] init];
    }
  }
  return _instance;
}

-(id) init
{
  self = [super init];

  if (self)
  {
    self.textTheme = 0;   // ensure that we've got a 0 here if no settings have been loaded
  }
  return self;
}

/**
 *
 * Reloads all the settings from the database. If the settings don't exist (this might be
 * our first run), call createDefaultSettings to create them.
 *
 */
-(void) reloadSettings
{
  // create settings if they don't exist...
  [self createDefaultSettings];

  // now, load up our settings
  textFontFace       = [self loadSetting: PK_SETTING_FONTFACE];
  textGreekFontFace  = [self loadSetting: @"greek-typeface"];   //RE: ISSUE #6
  textFontSize       = [[self loadSetting: PK_SETTING_FONTSIZE] intValue];
  textLineSpacing    = [[self loadSetting: PK_SETTING_LINESPACING] intValue];
  textVerseSpacing   = [[self loadSetting: PK_SETTING_VERSESPACING] intValue];
  layoutColumnWidths = [[self loadSetting: PK_SETTING_COLUMNWIDTHS] intValue];
  greekText          = [[self loadSetting: PK_SETTING_GREEKTEXT] intValue];
  englishText        = [[self loadSetting: PK_SETTING_ENGLISHTEXT] intValue];
  transliterateText  = [[self loadSetting: PK_SETTING_TRANSLITERATE] boolValue];
  showNotesInline    = [[self loadSetting: PK_SETTING_INLINENOTES] boolValue];
  showMorphology     = [[self loadSetting: PK_SETTING_SHOWMORPHOLOGY] boolValue];
  showStrongs        = [[self loadSetting: @"show-strongs"] boolValue];
  showInterlinear    = [[self loadSetting: @"show-interlinear"] boolValue];
  useICloud          = [[self loadSetting: PK_SETTING_USEICLOUD] boolValue];
  
  compressRightSideText= [[self loadSetting: @"compress-right-side"] boolValue];
  extendHighlights   = [[self loadSetting: @"extend-highlights"] boolValue];

  //if the Bible selected is one we no longer support, change it to the new
  //equivalent. Since these would all be non-parsed, turn strongs off.
  if (greekText == PK_BIBLETEXT_BYZ)
  {
    greekText   = PK_BIBLETEXT_BYZP;
    showStrongs = false;
  }

  if (greekText == PK_BIBLETEXT_TR)
  {
    greekText   = PK_BIBLETEXT_TRP;
    showStrongs = false;
  }

  if (greekText == PK_BIBLETEXT_WH)
  {
    greekText   = PK_BIBLETEXT_WHP;
    showStrongs = false;
  }

  currentBook          = [[self loadSetting: @"current-book"] intValue];
  currentChapter       = [[self loadSetting: @"current-chapter"] intValue];
  currentVerse         = [[self loadSetting: @"current-verse"] intValue];

  topVerse             = [[self loadSetting: @"top-verse"] intValue];

  noteBook             = [[self loadSetting: @"note-book"] intValue];
  noteChapter          = [[self loadSetting: @"note-chapter"] intValue];
  noteVerse            = [[self loadSetting: @"note-verse"] intValue];

  currentTextHighlight = [self loadSetting: @"current-text-highlight"];
  lastStrongsLookup    = [self loadSetting: @"last-strongs-lookup"];
  lastSearch           = [self loadSetting: @"last-search"];
  lastNotesSearch      = [self loadSetting: @"last-notes-search"];

  oldNote              = [self loadSetting: @"old-note"];
  currentNote          = [self loadSetting: @"current-note"];

  highlightTextColor   = [self loadSetting: @"highlight-text-color"];
  // load up highlight color
  NSString *theColorString;

  theColorString = [self loadSetting: @"highlight-color"];
  NSArray *theColorArray = [theColorString componentsSeparatedByString: @","];
  // there will always be 3 values; R=0, G=1, B=2
  highlightColor = [UIColor colorWithRed: [[theColorArray objectAtIndex: 0] floatValue]
                                   green: [[theColorArray objectAtIndex: 1] floatValue]
                                    blue: [[theColorArray objectAtIndex: 2] floatValue] alpha: 1.0];

  textTheme = [[self loadSetting: @"text-theme"] isEqual: @""] ? 0 :
              [[self loadSetting: @"text-theme"] intValue];

  if ([self loadSetting: @"usage-stats"])
  {
    usageStats = [[self loadSetting: @"usage-stats"] boolValue];
  }
  else
  {
    usageStats = YES;       // default;
    [self saveSettings];       // save it so the Settings page knows about it
  }
}

/**
 *
 * Loads a specific setting identified by the supplied setting key and returns it. As settings
 * are stored as strings in the database, it may be necessary to parse the return.
 *
 */
-(NSString *) loadSetting: (NSString *) theSetting
{
  __block NSString *theResult = @"";
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  
  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s      =
      [db executeQuery: @"SELECT value FROM settings \
                                                 WHERE setting=?", theSetting];
      if ([s next])
      {
        theResult = [s stringForColumnIndex: 0];
      }
      [s close];
  
    }
  ];

  return theResult;
}

/**
 *
 * Saves the variables containing the current reference (book,chapter,verse,top verse). Faster than
 * saving /all/ the settings every time the reference changes.
 *
 */
-(void) saveCurrentReference
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  [content inTransaction:^(FMDatabase *db, BOOL *rollback) {
    [self saveSetting: @"current-book" valueForSetting: [NSString stringWithFormat: @"%i", currentBook]];
    [self saveSetting: @"current-chapter" valueForSetting: [NSString stringWithFormat: @"%i", currentChapter]];
    [self saveSetting: @"current-verse" valueForSetting: [NSString stringWithFormat: @"%i", currentVerse]];
    [self saveSetting: @"top-verse" valueForSetting: [NSString stringWithFormat: @"%i", topVerse]];
  }];
}

/**
 *
 * Saves the current highlight setting. Faster than saving all settings.
 *
 */
-(void) saveCurrentHighlight
{
  // save the highlight color
  float red   = 0.0;
  float green = 0.0;
  float blue  = 0.0;
  float alpha = 0.0;

  if ([highlightColor respondsToSelector: @selector(getRed:green:blue:alpha:)])
  {
    [highlightColor getRed: &red green: &green blue: &blue alpha: &alpha];
  }
  else
  {
    const CGFloat *components = CGColorGetComponents([highlightColor CGColor]);
    red   = components[0];
    green = components[1];
    blue  = components[2];
    alpha = CGColorGetAlpha([highlightColor CGColor]);
  }

  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  [content inTransaction:^(FMDatabase *db, BOOL *rollback) {
    [self saveSetting: @"highlight-color" valueForSetting: [NSString stringWithFormat: @"%f,%f,%f",
                                                            red, green, blue]];

    [self saveSetting: @"highlight-text-color" valueForSetting: highlightTextColor];
  }];
}

/**
 *
 * Saves all our settings to the database.
 *
 */
-(void) saveSettings
{

  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  [content inTransaction:^(FMDatabase *db, BOOL *rollback) {
    [self saveSetting: PK_SETTING_FONTFACE valueForSetting: textFontFace];
    [self saveSetting: @"greek-typeface" valueForSetting: textGreekFontFace];     //RE: ISSUE #6
    [self saveSetting: PK_SETTING_FONTSIZE valueForSetting: [NSString stringWithFormat: @"%i", textFontSize]];
    [self saveSetting: PK_SETTING_LINESPACING valueForSetting: [NSString stringWithFormat: @"%i", textLineSpacing]];
    [self saveSetting: PK_SETTING_VERSESPACING valueForSetting: [NSString stringWithFormat: @"%i", textVerseSpacing]];
    [self saveSetting: PK_SETTING_COLUMNWIDTHS valueForSetting: [NSString stringWithFormat: @"%i", layoutColumnWidths]];
    [self saveSetting: PK_SETTING_GREEKTEXT valueForSetting: [NSString stringWithFormat: @"%i", greekText]];
    [self saveSetting: PK_SETTING_ENGLISHTEXT valueForSetting: [NSString stringWithFormat: @"%i", englishText]];
    [self saveSetting: PK_SETTING_TRANSLITERATE valueForSetting: (transliterateText ? @"YES": @"NO")];
    [self saveSetting: PK_SETTING_INLINENOTES valueForSetting: (showNotesInline ? @"YES": @"NO")];
    [self saveSetting: PK_SETTING_SHOWMORPHOLOGY valueForSetting: (showMorphology ? @"YES": @"NO")];
    [self saveSetting: @"show-strongs" valueForSetting: (showStrongs ? @"YES": @"NO")];
    [self saveSetting: @"show-interlinear" valueForSetting: (showInterlinear ? @"YES": @"NO")];
    [self saveSetting: PK_SETTING_USEICLOUD valueForSetting: (useICloud ? @"YES": @"NO")];

    [self saveSetting: @"compress-right-side" valueForSetting: (compressRightSideText ? @"YES": @"NO")];
    [self saveSetting: @"extend-highlights" valueForSetting: (extendHighlights ? @"YES": @"NO")];


    [self saveSetting: @"note-book" valueForSetting: [NSString stringWithFormat: @"%i", noteBook]];
    [self saveSetting: @"note-chapter" valueForSetting: [NSString stringWithFormat: @"%i", noteChapter]];
    [self saveSetting: @"note-verse" valueForSetting: [NSString stringWithFormat: @"%i", noteVerse]];

    [self saveSetting: @"current-text-highlight" valueForSetting: currentTextHighlight];
    [self saveSetting: @"last-strongs-lookup" valueForSetting: lastStrongsLookup];
    [self saveSetting: @"last-search" valueForSetting: lastSearch];
    [self saveSetting: @"last-notes-search" valueForSetting: lastNotesSearch];

    [self saveSetting: @"old-note" valueForSetting: oldNote];
    [self saveSetting: @"current-note" valueForSetting: currentNote];


    [self saveSetting: @"text-theme" valueForSetting: [NSString stringWithFormat: @"%i", textTheme]];
    [self saveSetting: @"usage-stats" valueForSetting: (usageStats ? @"YES": @"NO")];
    
  }];

  [self saveCurrentReference];
  [self saveCurrentHighlight];
}

/**
 *
 * Saves a setting for the given key value. Since all values are stored in the database as strings, some
 * parsing or conversion may be necessary prior to calling this function.
 *
 */
-(void) saveSetting: (NSString *) theSetting valueForSetting: (NSString *) theValue
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  FMDatabase *db = [content database];
  
//  [content inDatabase:^(FMDatabase *db)
//    {
      BOOL theResult      = YES;
      FMResultSet *resultSet;
      int rowCount        = 0;

      theResult = [db executeUpdate: @"UPDATE settings SET value=? WHERE setting=?",
                   theValue, theSetting];

      // theResult is almost always TRUE -- so we need to query the db for the value we just set...
      resultSet = [db executeQuery: @"SELECT * FROM settings WHERE setting=?", theSetting];

      if ([resultSet next])
      {
        rowCount++;
      }
      [resultSet close];

      if (rowCount < 1)
      {
        // updating didn't work -- insert the value instead.
        theResult = [db executeUpdate: @"INSERT INTO settings VALUES (?,?)",
                     theSetting, theValue];
      }

      if (!theResult)
      {
        NSLog(@"Couldn't save %@ into %@", theValue, theSetting);
      }
//    }
//  ];
}

/**
 *
 * Equivalent of createSchema in other models, this will create the settings' table
 * and insert some good defaults if they don't exist.
 *
 */
-(BOOL) createDefaultSettings
{
  __block BOOL returnVal      = YES;
  // get local versions of our databases
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      // create our settings table
      // it's really just a key-value store
      returnVal =
        [db executeUpdate:
         @"CREATE TABLE settings ( setting VARCHAR(255), \
                                   value   VARCHAR(4096) \
                                 )"
        ];
    }
   ];

  if (returnVal)
  {
    textFontSize         = 14;  // 14pt default font size
    textLineSpacing      = PK_LS_NORMAL;
    textVerseSpacing     = PK_VS_NONE;
    layoutColumnWidths   = PK_CW_WIDEGREEK;
    greekText            = PK_BIBLETEXT_BYZP;
    englishText          = PK_BIBLETEXT_YLT;
    transliterateText    = NO;
    showNotesInline      = NO;
    showMorphology       = YES;
    showStrongs          = YES;
    showInterlinear      = YES;
    useICloud            = NO;
    
    extendHighlights     = NO;
    compressRightSideText= NO;
    
    textFontFace         = @"Helvetica";
    textGreekFontFace    = @"Helvetica-Bold";     //RE: ISSUE #6

    currentBook          = 40;  // Matthew
    currentChapter       = 1;   // Chapter 1
    currentVerse         = 1;   // Verse 1
    topVerse             = 1;   // Top visible verse is 1
    noteBook             = 0;   // no note
    noteChapter          = 0;   // "
    noteVerse            = 0;   // "
    currentTextHighlight = @"";
    lastStrongsLookup    = @"";
    lastSearch           = @"";
    lastNotesSearch      = @"";
    oldNote              = @"";
    currentNote          = @"";
    highlightColor       = [PKSettings PKYellowHighlightColor];
    highlightTextColor   = __T(@"Yellow");
    textTheme            = 0;
    usageStats           = YES;

    [self saveSettings];
    // done, return success or failure
  }
  return returnVal;
}

/**
 *
 * Free up all our strings.
 *
 */
-(void) dealloc
{
  textFontFace         = nil;
  currentTextHighlight = nil;
  lastStrongsLookup    = nil;
  lastSearch           = nil;
  oldNote              = nil;
  currentNote          = nil;
  highlightColor       = nil;
  highlightTextColor   = nil;
  textGreekFontFace    = nil;
}

/**
 *
 * Class colors; specific to the theme
 *
 */

+(UIColor *)PKSidebarSelectionColor
{
  static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.8125 green: 0.800781 blue: 0.773437 alpha: 1.0],
                         [UIColor colorWithRed: 0.350 green: 0.600 blue: 0.850 alpha: 1.0],
                         [UIColor colorWithRed: 0.875 green: 0.9325 blue: 1.0 alpha: 1.0],
                         [UIColor colorWithRed: 0.875 green: 0.9325 blue: 1.0 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKSidebarPageColor
{
  static NSArray *theColors;
  if (!theColors) theColors =  @[[UIColor colorWithRed: 0.8125 green: 0.800781 blue: 0.773437 alpha: 1.0],
                         [UIColor colorWithWhite: 0.80 alpha: 1],
                         [UIColor colorWithWhite: 0.11 alpha: 1],
                         [UIColor colorWithWhite: 0.11 alpha: 1]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKSidebarTextColor
{
  static NSArray *theColors;
  if (!theColors) theColors =  @[[UIColor colorWithRed: 0.341176 green: 0.223529 blue: 0.125490 alpha: 1.0],
                         [UIColor colorWithWhite: 0.10 alpha: 1],
                         [UIColor colorWithWhite: 0.65 alpha: 1.0],
                         [UIColor colorWithRed: 0.65 green: 0.50 blue: 0.00 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKNavigationColor
{
  static NSArray *theColors;
  if (!theColors) theColors =  @[[UIColor colorWithRed: 0.341176 green: 0.223529 blue: 0.125490 alpha: 1.0],
                         [UIColor colorWithWhite: 0.10 alpha: 1],
                         [UIColor colorWithWhite: .11 alpha: 1.0],
                         [UIColor colorWithWhite: 0.11 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}
+(UIColor *)PKNavigationTextColor
{
  static NSArray *theColors;
  if (!theColors) theColors =  @[[UIColor whiteColor],
                         [UIColor whiteColor],
                         [UIColor colorWithWhite: 0.85 alpha: 1.0],
                         [UIColor colorWithWhite: 0.85 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}
+(UIColor *)PKBarButtonTextColor
{
  static NSArray *theColors;
  if (!theColors) theColors =  @[[UIColor colorWithRed: 0.341176 green: 0.223529 blue: 0.125490 alpha: 1.0],
                         [UIColor colorWithWhite: 0.25 alpha: 1.0],
                         [UIColor colorWithWhite: 0.85 alpha: 1.0],
                         [UIColor colorWithWhite: 0.85 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}


+(UIColor *)PKSelectionColor
{
  static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.8125 green: 0.800781 blue: 0.773437 alpha: 1.0],
                         [UIColor colorWithRed: 0.70 green: 0.80 blue: 0.900 alpha: 1.0],
                         [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.0],
                         [UIColor colorWithRed: 0.25 green: 0.20 blue: 0.10 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKWordSelectColor
{
  static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor whiteColor],
                         [UIColor whiteColor],
                         [UIColor whiteColor],
                         [UIColor whiteColor]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKSecondaryPageColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithWhite: 1.0 alpha: 1],
                         [UIColor colorWithWhite: 1.0 alpha: 1],
                         [UIColor colorWithWhite: 0.0 alpha: 1],
                         [UIColor colorWithWhite: 0.0 alpha: 1]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKPageColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.945098 green: 0.933333 blue: 0.898039 alpha: 1],
                         [UIColor colorWithWhite: 0.90 alpha: 1],
                         [UIColor colorWithWhite: 0.10 alpha: 1],
                         [UIColor colorWithWhite: 0.10 alpha: 1]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKTextColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.341176 green: 0.223529 blue: 0.125490 alpha: 1.0],
                         [UIColor colorWithWhite: 0.10 alpha: 1],
                         [UIColor colorWithWhite: 0.65 alpha: 1.0],
                         [UIColor colorWithRed: 0.65 green: 0.50 blue: 0.00 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKStrongsColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.125490 green: 0.250980 blue: 0.341176 alpha: 1.0],
                         [UIColor colorWithRed: 0.10 green: 0.10 blue: 0.4 alpha: 1.0],
                         [UIColor colorWithRed: 0.4 green: 0.4 blue: 0.65 alpha: 1.0],
                         [UIColor colorWithRed: 0.56 green: 0.43 blue: 0.0 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKMorphologyColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.188235 green: 0.341176 blue: 0.125490 alpha: 1.0],
                         [UIColor colorWithRed: 0.10 green: 0.4 blue: 0.10 alpha: 1.0],
                         [UIColor colorWithRed: 0.4 green: 0.65 blue: 0.4 alpha: 1.0],
                         [UIColor colorWithRed: 0.56 green: 0.43 blue: 0.0 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKInterlinearColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.333333 green: 0.333333 blue: 0.333333 alpha: 1.0],
                         [UIColor colorWithRed: 0.40 green: 0.10 blue: 0.10 alpha: 1.0],
                         [UIColor colorWithRed: 0.65 green: 0.4 blue: 0.4 alpha: 1.0],
                         [UIColor colorWithRed: 0.56 green: 0.43 blue: 0.0 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKAnnotationColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.313725 green: 0.125490 blue: 0.380392 alpha: 1.0],
                         [UIColor colorWithRed: 0.25 green: 0.25 blue: 0.25 alpha: 1.0],
                         [UIColor colorWithRed: 0.4 green: 0.4 blue: 0.4 alpha: 1.0],
                         [UIColor colorWithRed: 0.56 green: 0.43 blue: 0.0 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIColor *)PKLightShadowColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithWhite: 1.0 alpha: 0.5],
                         [UIColor colorWithWhite: 1.0 alpha: 0.5],
                         [UIColor colorWithWhite: 0.0 alpha: 0.75],
                         [UIColor colorWithWhite: 0.0 alpha: 0.75]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
  return [UIColor colorWithWhite: 1.0 alpha: 0.25];
}

+(UIColor *)PKYellowHighlightColor
{
  return [UIColor colorWithRed: 1.0 green: 1.0 blue: 0.0 alpha: 0.5];
}

+(UIColor *)PKGreenHighlightColor
{
  return [UIColor colorWithRed: 0.5 green: 1.0 blue: 0.5 alpha: 0.5];
}

+(UIColor *)PKBlueHighlightColor
{
  return [UIColor colorWithRed: 0.5 green: 0.75 blue: 1.0 alpha: 0.5];
}

+(UIColor *)PKPinkHighlightColor
{
  return [UIColor colorWithRed: 1.0 green: 0.75 blue: 0.75 alpha: 0.5];
}

+(UIColor *)PKMagentaHighlightColor
{
  return [UIColor colorWithRed: 1.0 green: 0.5 blue: 1.0 alpha: 0.5];
}

+(UIColor *)PKBaseUIColor
{
    static NSArray *theColors;
  if (!theColors) theColors = @[[UIColor colorWithRed: 0.250980 green: 0.282352 blue: 0.313725 alpha: 1.0],
                         [UIColor colorWithRed: 0.250980 green: 0.282352 blue: 0.313725 alpha: 1.0],
                         [UIColor colorWithRed: 0.250980 green: 0.282352 blue: 0.313725 alpha: 1.0],
                         [UIColor colorWithRed: 0.250980 green: 0.282352 blue: 0.313725 alpha: 1.0]
                       ];
  UIColor *theColor = theColors[[( (PKSettings *)[PKSettings instance] )textTheme]];
  return theColor;
}

+(UIImage *)PKImageLeftArrow
{
  int theTheme =  [( (PKSettings *)[PKSettings instance] )textTheme];

  // dark themes need a white arrow
  if (theTheme > 1)
    return [UIImage imageNamed: @"ArrowLeftWhite"];

  // otherwise the normal arrow
  return [UIImage imageNamed: @"ArrowLeft"];
}

+(UIImage *)PKImageRightArrow
{
  int theTheme =  [( (PKSettings *)[PKSettings instance] )textTheme];

  // dark themes need a white arrow
  if (theTheme > 1)
    return [UIImage imageNamed: @"ArrowRightWhite"];

  // otherwise the normal arrow
  return [UIImage imageNamed: @"ArrowRight"];
}

@end