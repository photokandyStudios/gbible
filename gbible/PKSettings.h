//
//  PKSettings.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
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
@end