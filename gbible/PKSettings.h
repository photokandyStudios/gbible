//
//  PKSettings.h
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
#import <Foundation/Foundation.h>

@interface PKSettings : NSObject

// User-visible settings [that they can change in the settings view]
@property int textFontSize;
@property int textLineSpacing;
@property int textVerseSpacing;
@property int layoutColumnWidths;
@property int greekText;
@property int englishText;
@property BOOL transliterateText;
@property BOOL showNotesInline;
@property BOOL showMorphology;
@property BOOL showStrongs;
@property BOOL showInterlinear;
@property BOOL useICloud;
@property (strong, nonatomic) NSString *textFontFace;
@property (strong, nonatomic) NSString *textGreekFontFace;    //RE: ISSUE #6

// User-invisible settings [that they can change, but do so indirectly]
@property (readwrite) int currentBook;     // current visible book (1-based; Matthew = 40)
@property (readwrite) int currentChapter;     // current visible chapter (1-based)
@property (readwrite) int currentVerse;       // current visible verse (1-based)
@property (readwrite) int topVerse;        // verse @ top of the screen
@property (readwrite, strong, nonatomic) NSString *currentTextHighlight;       // highlight text from a search
@property (readwrite, strong, nonatomic) NSString *lastStrongsLookup;          // the last lookup we did in strong's
@property (readwrite, strong, nonatomic) NSString *lastSearch;                 // the last Search we did
@property (readwrite, strong, nonatomic) NSString *oldNote;                    // the old note (used to get back if we cancel)
@property (readwrite, strong, nonatomic) NSString *currentNote;                // the current note (if we die mid-edit)
@property (readwrite) int noteBook;
@property (readwrite) int noteChapter;
@property (readwrite) int noteVerse;                                // the reference of the current note (mid-edit)
@property (readwrite, strong, nonatomic) UIColor *highlightColor;
@property (readwrite, strong, nonatomic) NSString *highlightTextColor;
@property (readwrite) int textTheme;
@property (readwrite) BOOL usageStats;
@property (readwrite, strong, nonatomic) NSString *lastNotesSearch;
@property (readwrite) BOOL strongsOnTop;

//version 1.2
@property BOOL compressRightSideText;       // if YES, compress the right side's text
@property BOOL extendHighlights;            // if YES, extend the highlights across the screen

+(id)         instance;
-(NSString *) loadSetting: (NSString *) theSetting;
-(void)       reloadSettings;
-(void)       saveSetting: (NSString *) theSetting valueForSetting: (NSString *) theValue;
-(void)       saveSettings;
-(void)       saveCurrentReference;
-(void)       saveCurrentHighlight;
-(BOOL)       createDefaultSettings;
-(void)       dealloc;

+(UIColor *)  PKSidebarSelectionColor;
+(UIColor *)  PKSidebarPageColor;
+(UIColor *)  PKSidebarTextColor;

+(UIColor *)  PKSelectionColor;
+(UIColor *)  PKWordSelectColor;
+(UIColor *)  PKSecondaryPageColor;
+(UIColor *)  PKPageColor;
+(UIColor *)  PKTextColor;
+(UIColor *)  PKStrongsColor;
+(UIColor *)  PKMorphologyColor;
+(UIColor *)  PKInterlinearColor;
+(UIColor *)  PKAnnotationColor;
+(UIColor *)  PKLightShadowColor;
+(UIColor *)  PKYellowHighlightColor;
+(UIColor *)  PKGreenHighlightColor;
+(UIColor *)  PKBlueHighlightColor;
+(UIColor *)  PKPinkHighlightColor;
+(UIColor *)  PKMagentaHighlightColor;
+(UIColor *)  PKBaseUIColor;
+(UIImage *)  PKImageLeftArrow;
+(UIImage *)  PKImageRightArrow;
+(UIColor *)  PKNavigationColor;
+(UIColor *)  PKNavigationTextColor;
+(UIColor *)  PKBarButtonTextColor;

+(NSString *) interfaceFont;
+(NSString *) boldInterfaceFont;


@end