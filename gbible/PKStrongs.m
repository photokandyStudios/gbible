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
#import "PKSettings.h"
#import "PKBible.h"

@implementation PKStrongs

    +(NSArray *)entryForKey:(NSString *)theKey
    {
        FMDatabase *db = [(PKDatabase *)[PKDatabase instance] bible];
        FMResultSet *s = [db executeQuery:@"SELECT * FROM strongsgr WHERE key = ?", theKey];
        NSMutableArray *theResult = [[NSMutableArray alloc]init ];
        if ([s next])
        {
            for (int i=0; i<4; i++)
            {
                // Fixes issue #30
                NSMutableString *theItem = [[s stringForColumnIndex:i] mutableCopy];
                [theItem replaceOccurrencesOfString:@"[DQ]" withString:@"\"" options:0 range:NSMakeRange(0, [theItem length])];
                if ([[PKSettings instance] transliterateText])
                {
                  theItem = [[PKBible transliterate:theItem] mutableCopy];
                }
                [theResult addObject:theItem];
            }
            
        }
        return theResult;
    }

    +(NSArray *)keysThatMatch:(NSString *)theTerm
    {
        FMDatabase *db = [(PKDatabase *)[PKDatabase instance] bible];

        // in order to support Issue #32 (multiple words), we need to craft a SQL statement
        // based on the inputs. There's really very little risk of SQL injection here --
        // but it should be properly handled.
        
        // search support is as follows:
        //   * "Jesus Mercy" results in an /Exact Phrase/ search. 
        //   * Jesus Mercy results in an OR search: "Jesus" OR "Mercy"
        //   * Jesus +Mercy results in an AND search: "Jesus" AND "Mercy"
        //     * note: a prepended + should be removed
        //   * Jesus -Mercy results in an NAND search: "Jesus" AND NOT "Mercy"
        //   * Jesus%Mercy results in a wildcard search: Jesus, followed by Mercy in the verse.
        //
        // Words separated by SPACES will thus be transformed into LIKE "%word%". Any suspicious
        // characters (", /, ;) will be removed prior. All words will be transformed to lowercase
        // for proper searching.
        
        NSMutableString *searchPhrase = [[[theTerm lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        BOOL exactMatch = NO;
        
        if ([searchPhrase characterAtIndex:0] == '"' &&
            [searchPhrase characterAtIndex:[searchPhrase length]-1] == '"')
        {
            exactMatch = YES;
        }
        
        [searchPhrase replaceOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, [searchPhrase length])];
        [searchPhrase replaceOccurrencesOfString:@";" withString:@"" options:0 range:NSMakeRange(0, [searchPhrase length])];
        [searchPhrase replaceOccurrencesOfString:@"/" withString:@"" options:0 range:NSMakeRange(0, [searchPhrase length])];
        [searchPhrase replaceOccurrencesOfString:@"\\" withString:@"" options:0 range:NSMakeRange(0, [searchPhrase length])];        
        [searchPhrase replaceOccurrencesOfString:@"%" withString:@"%%" options:0 range:NSMakeRange(0, [searchPhrase length])];
        
        if (!exactMatch)
        {
            NSArray *allTerms = [searchPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            searchPhrase = [@"" mutableCopy];
            for (int i=0; i<[allTerms count]; i++)
            {
                NSMutableString *theWord = [[allTerms objectAtIndex:i] mutableCopy];
                
                switch ( [theWord characterAtIndex:0] )
                {
case '.':
case '+':           [searchPhrase appendString: (i!=0 ? @"AND ( " : @"( ") ];
                    [theWord deleteCharactersInRange:NSMakeRange(0, 1)];
                    break;
case '!':
case '-':           [searchPhrase appendString: (i!=0 ? @"AND ( NOT " : @"( NOT ") ];
                    [theWord deleteCharactersInRange:NSMakeRange(0, 1)];
                    break;
default:            [searchPhrase appendString: (i!=0 ? @"OR ( " : @"( ") ];
                    break;
                }
                
               // [searchPhrase appendString:@"TRIM(LOWER( key || ' ' || definition || ' ' || lemma || ' ' || pronunciation )) LIKE \"%"];
                [searchPhrase appendString:@"doesContain (TRIM(key||' '|| definition||' '||lemma||' '||pronunciation),\""];
                [searchPhrase appendString:theWord];
               // [searchPhrase appendString:@"%\" ) "];
                [searchPhrase appendString:@"\"))"];
            }
        }
        else
        {
            NSString *theWord = searchPhrase;
            searchPhrase = [@"" mutableCopy];
//            [searchPhrase appendString:@"( TRIM(LOWER(key || ' ' || definition || ' ' || lemma || ' ' || pronunciation )) LIKE \"%"];
                [searchPhrase appendString:@"doesContain (TRIM(key||' '|| definition||' '||lemma||' '||pronunciation),\""];
            [searchPhrase appendString:theWord];
//            [searchPhrase appendString:@"%\" ) "];
                [searchPhrase appendString:@"\")"];
        }

        //NSLog (@"SQL: %@", searchPhrase);
        NSString *theNewTerm = [NSString stringWithFormat:@"%%%@%%", [[theTerm lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

        FMResultSet *s = [db executeQuery: [NSString stringWithFormat:@"SELECT * FROM strongsgr WHERE %@ ORDER BY 1", searchPhrase], theNewTerm];
        NSMutableArray *theResult = [[NSMutableArray alloc] init ];
        while ([s next]) {
            [theResult addObject:[s stringForColumnIndex:0]];
        }
        return [theResult copy];
    }

    +(NSArray *)keysThatMatch:(NSString *)theTerm byKeyOnly:(BOOL)keyOnly
    {
        if (!keyOnly)
        {
            return [self keysThatMatch:theTerm];
        }
        FMDatabase *db = [(PKDatabase *)[PKDatabase instance] bible];

        NSString *theNewTerm = [NSString stringWithFormat:@"%@", [[theTerm uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

        FMResultSet *s = [db executeQuery:@"SELECT * FROM strongsgr WHERE UPPER(key) = ? ORDER BY 1 LIMIT 100", theNewTerm, theNewTerm, theNewTerm, theNewTerm, theNewTerm];
        NSMutableArray *theResult = [[NSMutableArray alloc] init ];
        while ([s next]) {
            [theResult addObject:[s stringForColumnIndex:0]];
        }
        return [theResult copy];
    }

@end
