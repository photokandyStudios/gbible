//
//  PKStrongs.h
//  gbible
//
//  Created by Kerri Shotts on 4/3/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKStrongs : NSObject

+(NSArray *) entryForKey: (NSString *) theKey;
+(NSArray *) keysThatMatch: (NSString *) theTerm;
+(NSArray *) keysThatMatch: (NSString *) theTerm byKeyOnly: (BOOL) keyOnly;

@end