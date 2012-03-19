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
    @property BOOL useICloud;
    @property (strong, nonatomic) NSString *textFontFace;
    
    // User-invisible settings [that they can change, but do so indirectly]
    @property int currentBook; // current visible book (1-based; Matthew = 40)
    @property int currentChapter; // current visible chapter (1-based)
    @property int currentVerse;   // current visible verse (1-based)
    @property int topVerse;    // verse @ top of the screen
    @property (strong, nonatomic) NSString *currentTextHighlight;   // highlight text from a search
    @property (strong, nonatomic) NSString *lastStrongsLookup;      // the last lookup we did in strong's
    @property (strong, nonatomic) NSString *lastSearch;             // the last Search we did
    @property (strong, nonatomic) NSString *oldNote;                // the old note (used to get back if we cancel)
    @property (strong, nonatomic) NSString *currentNote;            // the current note (if we die mid-edit)
    @property int noteBook;
    @property int noteChapter;
    @property int noteVerse;                                       // the reference of the current note (mid-edit)
    
    
    +(id) instance;
    -(NSString *) loadSetting: (NSString *)theSetting;
    -(void) reloadSettings;
    -(void) saveSetting: (NSString *)theSetting valueForSetting: (NSString *)theValue;
    -(void) saveSettings;
    -(BOOL) createDefaultSettings;
    -(void) dealloc;

@end
