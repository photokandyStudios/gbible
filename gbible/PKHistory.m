//
//  PKHistory.m
//  gbible
//
//  Created by Kerri Shotts on 4/7/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKHistory.h"
#import "PKDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PKBible.h"

@implementation PKHistory

static id _instance;

+(id) instance
{
  @synchronized(self) {
    if (!_instance)
    {
      _instance = [[self alloc] init];
      
      //create our scheme, if not already done. TODO: What about cleaning it up?
      [_instance createSchema];
    }
  }
  return _instance;
}

-(NSMutableArray *)mostRecentPassages
{
  return [self mostRecentPassagesWithLimit: 200];
}

-(NSMutableArray *)mostRecentPassagesWithLimit: (int) theLimit
{
  FMDatabaseQueue *content      = ( (PKDatabase *)[PKDatabase instance] ).content;
  NSMutableArray *theArray = [[NSMutableArray alloc] init];

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s           =
      [db executeQuery: @"SELECT DISTINCT book,chapter,verse FROM history11 WHERE kind=0 ORDER BY seq DESC LIMIT ?",
       [NSNumber numberWithInt: theLimit]];
      
      while ([s next])
      {
        int theBook          = [s intForColumnIndex: 0];
        int theChapter       = [s intForColumnIndex: 1];
        int theVerse         = [s intForColumnIndex: 2];
        
        NSString *thePassage = [PKBible stringFromBook: theBook forChapter: theChapter forVerse: theVerse];
        [theArray addObject: thePassage];
      }
      [s close];
    }
  ];

  return theArray;
}

-(NSMutableArray *)mostRecentHistory
{
  return [self mostRecentHistoryWithLimit: 200];
}

-(NSMutableArray *)mostRecentHistoryWithLimit: (int) theLimit
{
  FMDatabaseQueue *content      = ( (PKDatabase *)[PKDatabase instance] ).content;
  NSMutableArray *theArray = [[NSMutableArray alloc] init];

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s           =
      [db executeQuery: @"SELECT DISTINCT kind,data,book,chapter,verse FROM history11 ORDER BY seq DESC LIMIT ?",
       [NSNumber numberWithInt: theLimit]];
      
      while ([s next])
      {
        int theKind = [s intForColumnIndex: 0];
        
        if (theKind == 0)
        {
          int theBook          = [s intForColumnIndex: 2];
          int theChapter       = [s intForColumnIndex: 3];
          int theVerse         = [s intForColumnIndex: 4];
          
          NSString *thePassage = [NSString stringWithFormat: @"P%@",
                                  [PKBible stringFromBook: theBook forChapter: theChapter forVerse: theVerse]];
          [theArray addObject: thePassage];
        }
        else
          if (theKind == 1)
          {
            NSString *thePassage = [NSString stringWithFormat: @"B%@",
                                    [s stringForColumnIndex: 1]];
            [theArray addObject: thePassage];
          }
          else
            if (theKind == 2)
            {
              NSString *thePassage = [NSString stringWithFormat: @"S%@",
                                      [s stringForColumnIndex: 1]];
              [theArray addObject: thePassage];
            }
      }
      [s close];
    }
  ];

  return theArray;
}

-(void) addBibleSearch: (NSString *) theSearchTerm
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult      = YES;
      
      theResult = [db executeUpdate: @"INSERT INTO history11 VALUES (NULL,1,?,NULL,NULL,NULL)",
                   theSearchTerm];
      
      if (!theResult)
      {
        NSLog(@"Couldn't add Bible Search history.");
      }
    }
  ];

}

-(void) addStrongsSearch: (NSString *) theStrongsTerm
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult      = YES;
      
      theResult = [db executeUpdate: @"INSERT INTO history11 VALUES (NULL,2,?,NULL,NULL,NULL)",
                   theStrongsTerm];
      
      if (!theResult)
      {
        NSLog(@"Couldn't add Strongs Search history.");
      }
    }
  ];
}

-(void) addPassage: (NSString *) thePassage
{
  int theBook    = [PKBible bookFromString: thePassage];
  int theChapter = [PKBible chapterFromString: thePassage];
  int theVerse   = [PKBible verseFromString: thePassage];
  [self addPassagewithBook: theBook andChapter: theChapter andVerse: theVerse];
}

-(void) addPassagewithBook: (int) theBook andChapter: (int) theChapter andVerse: (int) theVerse
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult      = YES;
      
      theResult = [db executeUpdate: @"INSERT INTO history11 VALUES (NULL,0,NULL,?,?,?)",
                   [NSNumber numberWithInt: theBook],
                   [NSNumber numberWithInt: theChapter],
                   [NSNumber numberWithInt: theVerse]];
      
      if (!theResult)
      {
        NSLog(@"Couldn't add history.");
      }
    }
  ];

}

-(void) createSchema
{
  // get local versions of our databases
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL returnVal      = YES;
      returnVal =
      [db executeUpdate:
       @"CREATE TABLE history11 ( seq INTEGER PRIMARY KEY AUTOINCREMENT, \
       kind INT NOT NULL, \
       data VARCHAR(512), \
       book INT , \
       chapter INT , \
       verse INT  \
       )"
       ];
      
      if (returnVal)
      {
        NSLog(@"Created schema for history.");
        // if the table was created -- let's migrate the user's previous history
        BOOL theResult = NO;
        theResult =
        [db executeUpdate:
         @"INSERT INTO history11 SELECT NULL, 0, NULL, book, chapter, verse \
         FROM history"
         ];
        
        if (theResult)
        {
          NSLog(@"Migrated 1.0 history.");
          //theResult = [content executeUpdate:@"DROP TABLE history"];
          //if (theResult)
          //{
          //  NSLog (@"And nuked the old table.");
          //}
        }
      }
    }
  ];
  
}

@end