//
//  PKStrongs.m
//  gbible
//
//  Created by Kerri Shotts on 4/3/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
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
  if (theTerm.length == 0)
  {
    return nil;
  }
  NSMutableArray *theResult = [[NSMutableArray alloc] init];
  FMDatabaseQueue *db = [(PKDatabase *)[PKDatabase instance] bible];
  [db inDatabase:^(FMDatabase *db)
    {
      NSString *searchPhrase = convertSearchToSQL(theTerm, @"key||' '|| definition||' '||lemma||' '||pronunciation");
      if (searchPhrase)
      {
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