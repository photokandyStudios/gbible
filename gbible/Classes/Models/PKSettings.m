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
#import "UIFont+Utility.h"
#import "PKReference.h"

@implementation PKSettings

static PKSettings * _instance;

/**
 *
 * Global instance for singletons
 *
 */
+(PKSettings *) instance
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
  _textFontFace       = [self loadSetting: PK_SETTING_FONTFACE];
  _textGreekFontFace  = [self loadSetting: @"greek-typeface"];   //RE: ISSUE #6
  _textFontSize       = [[self loadSetting: PK_SETTING_FONTSIZE] intValue];
  _textLineSpacing    = [[self loadSetting: PK_SETTING_LINESPACING] intValue];
  _textVerseSpacing   = [[self loadSetting: PK_SETTING_VERSESPACING] intValue];
  _layoutColumnWidths = [[self loadSetting: PK_SETTING_COLUMNWIDTHS] intValue];
  _greekText          = [[self loadSetting: PK_SETTING_GREEKTEXT] intValue];
  _englishText        = [[self loadSetting: PK_SETTING_ENGLISHTEXT] intValue];
  _transliterateText  = [[self loadSetting: PK_SETTING_TRANSLITERATE] boolValue];
  _showNotesInline    = [[self loadSetting: PK_SETTING_INLINENOTES] boolValue];
  _showMorphology     = [[self loadSetting: PK_SETTING_SHOWMORPHOLOGY] boolValue];
  _showStrongs        = [[self loadSetting: @"show-strongs"] boolValue];
  _strongsOnTop       = [[self loadSetting: @"strongs-on-top"] boolValue];
  _smallerLeftSideWords=[[self loadSetting: @"smaller-left-side-words"] boolValue];
  _showInterlinear    = [[self loadSetting: @"show-interlinear"] boolValue];
  _useICloud          = [[self loadSetting: PK_SETTING_USEICLOUD] boolValue];
  
  _compressRightSideText= [[self loadSetting: @"compress-right-side"] boolValue];
  _extendHighlights   = [[self loadSetting: @"extend-highlights"] boolValue];

  //if the Bible selected is one we no longer support, change it to the new
  //equivalent. Since these would all be non-parsed, turn strongs off.
  if (_greekText == PK_BIBLETEXT_BYZ)
  {
    _greekText   = PK_BIBLETEXT_BYZP;
    _showStrongs = false;
  }

  if (_greekText == PK_BIBLETEXT_TR)
  {
    _greekText   = PK_BIBLETEXT_TRP;
    _showStrongs = false;
  }

  if (_greekText == PK_BIBLETEXT_WH)
  {
    _greekText   = PK_BIBLETEXT_WHP;
    _showStrongs = false;
  }
  
  _currentBook          = [[self loadSetting: @"current-book"] intValue];
  _currentChapter       = [[self loadSetting: @"current-chapter"] intValue];
  _currentVerse         = [[self loadSetting: @"current-verse"] intValue];

  _topVerse             = [[self loadSetting: @"top-verse"] intValue];

  _noteBook             = [[self loadSetting: @"note-book"] intValue];
  _noteChapter          = [[self loadSetting: @"note-chapter"] intValue];
  _noteVerse            = [[self loadSetting: @"note-verse"] intValue];

  _currentTextHighlight = [self loadSetting: @"current-text-highlight"];
  _lastStrongsLookup    = [self loadSetting: @"last-strongs-lookup"];
  _lastSearch           = [self loadSetting: @"last-search"];
  _lastNotesSearch      = [self loadSetting: @"last-notes-search"];

  _oldNote              = [self loadSetting: @"old-note"];
  _currentNote          = [self loadSetting: @"current-note"];

  _highlightTextColor   = [self loadSetting: @"highlight-text-color"];
  // load up highlight color
  NSString *theColorString;

  theColorString = [self loadSetting: @"highlight-color"];
  NSArray *theColorArray = [theColorString componentsSeparatedByString: @","];
  // there will always be 3 values; R=0, G=1, B=2
  if (theColorArray && theColorArray.count == 3) {
    _highlightColor = [UIColor colorWithRed: [theColorArray[0] floatValue]
                                     green: [theColorArray[1] floatValue]
                                      blue: [theColorArray[2] floatValue] alpha: 1.0];
  }

  _textTheme = [[self loadSetting: @"text-theme"] isEqual: @""] ? 0 :
              [[self loadSetting: @"text-theme"] intValue];

  if ([self loadSetting: @"usage-stats"])
  {
    _usageStats = [[self loadSetting: @"usage-stats"] boolValue];
  }
  else
  {
    _usageStats = YES;       // default;
    [self saveSettings];       // save it so the Settings page knows about it
  }

  if (_englishText == PK_BIBLETEXT_KJV)
  {
    _englishText = PK_BIBLETEXT_YLT;
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
  FMDatabaseQueue *content = [PKDatabase instance].content;
  
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
    [self saveSetting: @"current-book" valueForSetting: [PKReference stringFromBookNumber: _currentBook]];
    [self saveSetting: @"current-chapter" valueForSetting: [PKReference stringFromChapterNumber: _currentChapter]];
    [self saveSetting: @"current-verse" valueForSetting: [PKReference stringFromVerseNumber: _currentVerse]];
    [self saveSetting: @"top-verse" valueForSetting: [PKReference stringFromVerseNumber: _topVerse]];
}

/**
 *
 * Saves the current highlight setting. Faster than saving all settings.
 *
 */
-(void) saveCurrentHighlight
{
  // save the highlight color
  CGFloat red   = 0.0;
  CGFloat green = 0.0;
  CGFloat blue  = 0.0;
  CGFloat alpha = 0.0;

  if ([_highlightColor respondsToSelector: @selector(getRed:green:blue:alpha:)])
  {
    [_highlightColor getRed: &red green: &green blue: &blue alpha: &alpha];
  }
  else
  {
    const CGFloat *components = CGColorGetComponents([_highlightColor CGColor]);
    red   = components[0];
    green = components[1];
    blue  = components[2];
    alpha = CGColorGetAlpha([_highlightColor CGColor]);
  }

    [self saveSetting: @"highlight-color" valueForSetting: [NSString stringWithFormat: @"%f,%f,%f",
                                                            red, green, blue]];

    [self saveSetting: @"highlight-text-color" valueForSetting: _highlightTextColor];
}

/**
 *
 * Saves all our settings to the database.
 *
 */
-(void) saveSettings
{

    [self saveSetting: PK_SETTING_FONTFACE valueForSetting: _textFontFace];
    [self saveSetting: @"greek-typeface" valueForSetting: _textGreekFontFace];     //RE: ISSUE #6
    [self saveSetting: PK_SETTING_FONTSIZE valueForSetting: [NSString stringWithFormat: @"%i", _textFontSize]];
    [self saveSetting: PK_SETTING_LINESPACING valueForSetting: [NSString stringWithFormat: @"%i", _textLineSpacing]];
    [self saveSetting: PK_SETTING_VERSESPACING valueForSetting: [NSString stringWithFormat: @"%i", _textVerseSpacing]];
    [self saveSetting: PK_SETTING_COLUMNWIDTHS valueForSetting: [NSString stringWithFormat: @"%i", _layoutColumnWidths]];
    [self saveSetting: PK_SETTING_GREEKTEXT valueForSetting: [NSString stringWithFormat: @"%@", @(_greekText)]];
    [self saveSetting: PK_SETTING_ENGLISHTEXT valueForSetting: [NSString stringWithFormat: @"%@", @(_englishText)]];
    [self saveSetting: PK_SETTING_TRANSLITERATE valueForSetting: (_transliterateText ? @"YES": @"NO")];
    [self saveSetting: PK_SETTING_INLINENOTES valueForSetting: (_showNotesInline ? @"YES": @"NO")];
    [self saveSetting: PK_SETTING_SHOWMORPHOLOGY valueForSetting: (_showMorphology ? @"YES": @"NO")];
    [self saveSetting: @"strongs-on-top" valueForSetting: (_strongsOnTop ? @"YES": @"NO")];
    [self saveSetting: @"smaller-left-side-words" valueForSetting: ( _smallerLeftSideWords ? @"YES": @"NO" )];
    [self saveSetting: @"show-strongs" valueForSetting: (_showStrongs ? @"YES": @"NO")];
    [self saveSetting: @"show-interlinear" valueForSetting: (_showInterlinear ? @"YES": @"NO")];
    [self saveSetting: PK_SETTING_USEICLOUD valueForSetting: (_useICloud ? @"YES": @"NO")];

    [self saveSetting: @"compress-right-side" valueForSetting: (_compressRightSideText ? @"YES": @"NO")];
    [self saveSetting: @"extend-highlights" valueForSetting: (_extendHighlights ? @"YES": @"NO")];


    [self saveSetting: @"note-book" valueForSetting: [PKReference stringFromBookNumber:_noteBook]];
    [self saveSetting: @"note-chapter" valueForSetting: [PKReference stringFromChapterNumber:_noteChapter]];
    [self saveSetting: @"note-verse" valueForSetting: [PKReference stringFromVerseNumber:_noteVerse]];

    [self saveSetting: @"current-text-highlight" valueForSetting: _currentTextHighlight];
    [self saveSetting: @"last-strongs-lookup" valueForSetting: _lastStrongsLookup];
    [self saveSetting: @"last-search" valueForSetting: _lastSearch];
    [self saveSetting: @"last-notes-search" valueForSetting: _lastNotesSearch];

    [self saveSetting: @"old-note" valueForSetting: _oldNote];
    [self saveSetting: @"current-note" valueForSetting: _currentNote];


    [self saveSetting: @"text-theme" valueForSetting: [NSString stringWithFormat: @"%i", _textTheme]];
    [self saveSetting: @"usage-stats" valueForSetting: (_usageStats ? @"YES": @"NO")];
    
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
  FMDatabaseQueue *content = [PKDatabase instance].content;
  [content inDatabase:^(FMDatabase *db) {
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
  }];
  
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
  FMDatabaseQueue *content = [PKDatabase instance].content;

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
    _textFontSize         = 14;  // 14pt default font size
    _textLineSpacing      = PK_LS_NORMAL;
    _textVerseSpacing     = PK_VS_NONE;
    _layoutColumnWidths   = PK_CW_WIDEGREEK;
    _greekText            = PK_BIBLETEXT_WHP;
    _englishText          = PK_BIBLETEXT_YLT;
    _transliterateText    = NO;
    _showNotesInline      = NO;
    _showMorphology       = YES;
    _showStrongs          = YES;
    _showInterlinear      = YES;
    _strongsOnTop         = YES;
    _smallerLeftSideWords = YES;
    _useICloud            = NO;
    
    _extendHighlights     = YES;
    _compressRightSideText= YES;
    
    _textFontFace         = @"Arev Sans";
    _textGreekFontFace    = @"Arev Sans Bold";

    _currentBook          = 40;  // Matthew
    _currentChapter       = 1;   // Chapter 1
    _currentVerse         = 1;   // Verse 1
    _topVerse             = 1;   // Top visible verse is 1
    _noteBook             = 0;   // no note
    _noteChapter          = 0;   // "
    _noteVerse            = 0;   // "
    _currentTextHighlight = @"";
    _lastStrongsLookup    = @"";
    _lastSearch           = @"";
    _lastNotesSearch      = @"";
    _oldNote              = @"";
    _currentNote          = @"";
    _highlightColor       = [PKSettings PKYellowHighlightColor];
    _highlightTextColor   = __T(@"Yellow");
    _textTheme            = 0;
    _usageStats           = YES;

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
  _textFontFace         = nil;
  _currentTextHighlight = nil;
  _lastStrongsLookup    = nil;
  _lastSearch           = nil;
  _oldNote              = nil;
  _currentNote          = nil;
  _highlightColor       = nil;
  _highlightTextColor   = nil;
  _textGreekFontFace    = nil;
}

-(PKSTheme *) currentTheme
{
  static PKSTheme *theCurrentTheme;
  static int currentThemeIndex = -1;
  static NSString *currentThemeName;

  if (currentThemeIndex != [self textTheme]) {
    currentThemeIndex = [self textTheme];
    currentThemeName = [NSString stringWithFormat:@"theme-%i", currentThemeIndex];
    theCurrentTheme = [[PKSTheme alloc] initWithResource:currentThemeName error:nil];
  }
  
  return theCurrentTheme;
}

/**
 *
 * Class colors; specific to the theme
 *
 */

+(UIColor *)PKTintColor
{
  return [[[PKSettings instance] currentTheme] tintColor];
};

+(UIColor *)PKSidebarSelectionColor
{
  return [[[PKSettings instance] currentTheme] sidebarSelectionColor];
}

+(UIColor *)PKSidebarPageColor
{
  return [[[PKSettings instance] currentTheme] sidebarPageColor];
}

+(UIColor *)PKSidebarTextColor
{
  return [[[PKSettings instance] currentTheme] sidebarTextColor];
}

+(UIColor *)PKNavigationColor
{
  return [[[PKSettings instance] currentTheme] navigationColor];
}
+(UIColor *)PKNavigationTextColor
{
  return [[[PKSettings instance] currentTheme] navigationTextColor];
}
+(UIColor *)PKBarButtonTextColor
{
  return [[[PKSettings instance] currentTheme] barButtonTextColor];
}


+(UIColor *)PKSelectionColor
{
  return [[[PKSettings instance] currentTheme] selectionColor];
}

+(UIColor *)PKWordSelectColor
{
  return [[[PKSettings instance] currentTheme] wordSelectColor];
}

+(UIColor *)PKSecondaryPageColor
{
  return [[[PKSettings instance] currentTheme] secondaryPageColor];
}

+(UIColor *)PKPageColor
{
  return [[[PKSettings instance] currentTheme] pageColor];
}

+(UIColor *)PKTextColor
{
  return [[[PKSettings instance] currentTheme] textColor];
}

+(UIColor *)PKStrongsColor
{
  return [[[PKSettings instance] currentTheme] strongsColor];
}

+(UIColor *)PKMorphologyColor
{
  return [[[PKSettings instance] currentTheme] morphologyColor];
}

+(UIColor *)PKInterlinearColor
{
  return [[[PKSettings instance] currentTheme] interlinearColor];
}

+(UIColor *)PKAnnotationColor
{
  return [[[PKSettings instance] currentTheme] annotationColor];
}

+(UIColor *)PKLightShadowColor
{
  return [[[PKSettings instance] currentTheme] lightShadowColor];
}

+(UIColor *)PKHUDBackgroundColor
{
  return [[[PKSettings instance] currentTheme] hudBackgroundColor];
}

+(UIColor *)PKHUDForegroundColor
{
  return [[[PKSettings instance] currentTheme] hudForegroundColor];
}

+(UIColor *)PKYellowHighlightColor
{
  return [[[PKSettings instance] currentTheme] highlightYellowColor];
}

+(UIColor *)PKGreenHighlightColor
{
  return [[[PKSettings instance] currentTheme] highlightGreenColor];
}

+(UIColor *)PKBlueHighlightColor
{
  return [[[PKSettings instance] currentTheme] highlightBlueColor];
}

+(UIColor *)PKPinkHighlightColor
{
  return [[[PKSettings instance] currentTheme] highlightPinkColor];
}

+(UIColor *)PKMagentaHighlightColor
{
  return [[[PKSettings instance] currentTheme] highlightMagentaColor];
}

+(UIColor *)PKBaseUIColor
{
  return [[[PKSettings instance] currentTheme] baseUIColor];
}

+(UIImage *)PKImageLeftArrow
{
  int theTheme =  [[PKSettings instance] textTheme];

  // dark themes need a white arrow
  if (theTheme > 1)
    return [UIImage imageNamed: @"ArrowLeftWhite"];

  // otherwise the normal arrow
  return [UIImage imageNamed: @"ArrowLeft"];
}

+(UIImage *)PKImageRightArrow
{
  int theTheme =  [[PKSettings instance] textTheme];

  // dark themes need a white arrow
  if (theTheme > 1)
    return [UIImage imageNamed: @"ArrowRightWhite"];

  // otherwise the normal arrow
  return [UIImage imageNamed: @"ArrowRight"];
}

+(NSString *) interfaceFont
{
  NSString *font = [NSString stringWithFormat:@"%@ %@", [[PKSettings instance] textFontFace],
                                                       [[PKSettings instance] textGreekFontFace]];
  if ([font rangeOfString:@"Dyslexic"].location != NSNotFound)
  {
    return [UIFont fontForFamilyName:@"Open Dyslexic"];
  }
  return [UIFont fontForFamilyName:@"Helvetica"];
}

+(NSString *) boldInterfaceFont
{
  NSString *font = [NSString stringWithFormat:@"%@ %@", [[PKSettings instance] textFontFace],
                                                       [[PKSettings instance] textGreekFontFace]];
  if ([font rangeOfString:@"Dyslexic"].location != NSNotFound)
  {
    return [UIFont fontForFamilyName:@"Open Dyslexic Bold"];
  }
  return [UIFont fontForFamilyName:@"Helvetica Bold"];
}

+(UIStatusBarStyle) PKStatusBarStyle
{
  if ([[[[PKSettings instance] currentTheme] statusBarStyle] isEqualToString:@"light"]) {
    return UIStatusBarStyleLightContent;
  }
  return UIStatusBarStyleDefault;
}


@end