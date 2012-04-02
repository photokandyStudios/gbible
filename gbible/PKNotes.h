//
//  PKNotes.h
//  gbible
//
//  Created by Kerri Shotts on 4/1/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKNotes : NSObject

    +(id) instance;
    
    -(void) createSchema;
    -(int)  countNotes;
    -(void) setNote: (NSString*)theNote withTitle: (NSString *)theTitle forPassage: (NSString*)thePassage;
    -(NSArray *)getNoteForPassage: (NSString *)thePassage;
    -(NSMutableDictionary *)allNotes;
    -(void) deleteNoteForPassage: (NSString*) thePassage;

@end
