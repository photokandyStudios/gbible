//
//  PKBibleReferenceDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 2/7/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PKBibleReferenceDelegate <NSObject>

@required

-(void)newReferenceByBook: (int)theBook andChapter: (int)theChapter andVerse: (int) andVerse;
-(void)newVerseByBook: (int)theBook andChapter: (int)theChapter andVerse: (int) andVerse;

@end