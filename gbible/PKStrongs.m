//
//  PKStrongs.m
//  gbible
//
//  Created by Kerri Shotts on 4/3/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKStrongs.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PKDatabase.h"

@implementation PKStrongs

    +(NSArray *)entryForKey:(NSString *)theKey
    {
        FMDatabase *db = [(PKDatabase *)[PKDatabase instance] bible];
        FMResultSet *s = [db executeQuery:@"SELECT * FROM strongs WHERE key = ?", theKey];
        NSArray *theResult = nil;
        if ([s next])
        {
            theResult = [NSArray arrayWithObjects: [s stringForColumnIndex:0],
                                                   [s stringForColumnIndex:1],
                                                   [s stringForColumnIndex:2],
                                                   [s stringForColumnIndex:3],
                                                   [s stringForColumnIndex:4], nil];
        }
        return theResult;
    }

    +(NSArray *)keysThatMatch:(NSString *)theTerm
    {
        FMDatabase *db = [(PKDatabase *)[PKDatabase instance] bible];

        NSString *theNewTerm = [NSString stringWithFormat:@"%%%@%%", [[theTerm uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

        FMResultSet *s = [db executeQuery:@"SELECT * FROM strongs WHERE UPPER(key) LIKE ? OR UPPER(derivation) LIKE ? \
                                                                     OR UPPER(lemma) LIKE ? OR UPPER(kjv_def) LIKE ? \
                                                                     OR UPPER(strongs_def) LIKE ? ORDER BY 1 LIMIT 100", theNewTerm, theNewTerm, theNewTerm, theNewTerm, theNewTerm];
        NSMutableArray *theResult = [[NSMutableArray alloc] init ];
        while ([s next]) {
            [theResult addObject:[s stringForColumnIndex:0]];
        }
        return [theResult copy];
    }

@end
