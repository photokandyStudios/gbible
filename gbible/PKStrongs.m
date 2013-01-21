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
  FMDatabase *db            = [(PKDatabase *)[PKDatabase instance] bible];
  FMResultSet *s            = [db executeQuery: @"SELECT * FROM strongsgr WHERE key = ?", theKey];
  NSMutableArray *theResult = [[NSMutableArray alloc] init];

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
  return theResult;
}

+(NSArray *)keysThatMatch: (NSString *) theTerm
{
  FMDatabase *db = [(PKDatabase *)[PKDatabase instance] bible];

  NSString *searchPhrase = convertSearchToSQL(theTerm, @"key||' '|| definition||' '||lemma||' '||pronunciation");

  FMResultSet *s            =
    [db executeQuery: [NSString stringWithFormat:
                       @"SELECT * FROM strongsgr WHERE %@ \
                          ORDER BY (CASE WHEN key=? THEN 0 ELSE 1 END), 1"                                                            ,
                       searchPhrase], [theTerm uppercaseString]];
  NSMutableArray *theResult = [[NSMutableArray alloc] init];

  while ([s next])
  {
    [theResult addObject: [s stringForColumnIndex: 0]];
  }
  return [theResult copy];
}

+(NSArray *)keysThatMatch: (NSString *) theTerm byKeyOnly: (BOOL) keyOnly
{
  if (!keyOnly)
  {
    return [self keysThatMatch: theTerm];
  }
  FMDatabase *db            = [(PKDatabase *)[PKDatabase instance] bible];

  NSString *theNewTerm      =
    [NSString stringWithFormat: @"%@",
     [[theTerm uppercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];

  FMResultSet *s            =
    [db executeQuery: @"SELECT * FROM strongsgr WHERE UPPER(key) = ? ORDER BY 1", theNewTerm, theNewTerm, theNewTerm,
     theNewTerm, theNewTerm];
  NSMutableArray *theResult = [[NSMutableArray alloc] init];

  while ([s next])
  {
    [theResult addObject: [s stringForColumnIndex: 0]];
  }
  return [theResult copy];
}

@end