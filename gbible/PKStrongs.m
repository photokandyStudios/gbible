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
#import "searchutils.h"

@implementation PKStrongs

+(NSArray *)entryForKey: (NSString *) theKey
{
  FMDatabaseQueue *db            = [(PKDatabase *)[PKDatabase instance] bible];
  NSMutableArray *theResult = [[NSMutableArray alloc] init];

  [db inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s            = [db executeQuery: @"SELECT * FROM strongsgr WHERE key = ?", theKey];

      if ([s next])
      {
        for (int i = 0; i < 4; i++)
        {
          // Fixes issue #30
          NSMutableString *theItem = [[s stringForColumnIndex: i] mutableCopy];
          [theItem replaceOccurrencesOfString: @"[DQ]" withString: @"\"" options: 0 range: NSMakeRange(0, [theItem length])];

          if ([[PKSettings instance] transliterateText])
          {
            theItem = [[PKBible transliterate: theItem] mutableCopy];
          }
          [theResult addObject: theItem];
        }
      }
      [s close];
    }
  ];

  return theResult;
}

+(NSArray *)keysThatMatch: (NSString *) theTerm
{
  NSMutableArray *theResult = [[NSMutableArray alloc] init];
  FMDatabaseQueue *db = [(PKDatabase *)[PKDatabase instance] bible];
  [db inDatabase:^(FMDatabase *db)
    {
      NSString *searchPhrase = convertSearchToSQL(theTerm, @"key||' '|| definition||' '||lemma||' '||pronunciation");

      FMResultSet *s            =
        [db executeQuery: [NSString stringWithFormat:
                           @"SELECT * FROM strongsgr WHERE %@ \
                              ORDER BY (CASE WHEN key=? THEN 0 ELSE 1 END), 1"                                                            ,
                           searchPhrase], [theTerm uppercaseString]];

      while ([s next])
      {
        [theResult addObject: [s stringForColumnIndex: 0]];
      }
      [s close];
    }
  ];

  return [theResult copy];
}

+(NSArray *)keysThatMatch: (NSString *) theTerm byKeyOnly: (BOOL) keyOnly
{
  if (!keyOnly)
  {
    return [self keysThatMatch: theTerm];
  }
  FMDatabaseQueue *db            = [(PKDatabase *)[PKDatabase instance] bible];
  NSMutableArray *theResult = [[NSMutableArray alloc] init];
  [db inDatabase:^(FMDatabase *db)
    {
      NSString *theNewTerm      =
        [NSString stringWithFormat: @"%@",
         [[theTerm uppercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];

      FMResultSet *s            =
        [db executeQuery: @"SELECT * FROM strongsgr WHERE UPPER(key) = ? ORDER BY 1", theNewTerm, theNewTerm, theNewTerm,
         theNewTerm, theNewTerm];

      while ([s next])
      {
        [theResult addObject: [s stringForColumnIndex: 0]];
      }
      [s close];
    }
  ];

  return [theResult copy];
}

@end