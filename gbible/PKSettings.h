//
//  PKSettings.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKSettings : NSObject

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
    
    +(id) instance;
    -(NSString *) loadSetting: (NSString *)theSetting;
    -(void) reloadSettings;
    -(void) saveSetting: (NSString *)theSetting valueForSetting: (NSString *)theValue;
    -(void) saveSettings;
    -(BOOL) createDefaultSettings;
    -(void) dealloc;

@end
