//
//  PKHighlights.h
//  gbible
//
//  Created by Kerri Shotts on 3/29/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKHighlights : NSObject

    +(id) instance;
    -(int) countHighlights;
    -(NSMutableArray *)allHighlightedPassages;
    -(NSMutableDictionary *)allHighlightedPassagesForBook: (int)theBook andChapter: (int)theChapter;
    -(void) setHighlight: (UIColor *)theColor forPassage: (NSString *)thePassage;
    -(void) removeHighlightFromPassage: (NSString *)thePassage;
    -(UIColor *) highlightForPassage: (NSString *)thePassage;
    -(void) createSchema;
    
@end
