//
//  PKHighlights.m
//  gbible
//
//  Created by Kerri Shotts on 3/29/12.
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
#import "PKHighlights.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PKDatabase.h"
#import "PKBible.h"

@implementation PKHighlights

static id _instance;

/**
 *
 * Return the global instance of the highlights model.
 *
 */
+(id) instance
{
  @synchronized(self) {
    if (!_instance)
    {
      _instance = [[self alloc] init];
      
      //create our scheme, if not already done.
      [_instance createSchema];
    }
  }
  return _instance;
}

/**
 *
 * Called by instance, this will create the schema if it doesn't already exist.
 * If it does, we fail silently.
 *
 */
-(void) createSchema
{
  // get local versions of our databases
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  
  [content inDatabase:^(FMDatabase *db)
    {
      BOOL returnVal      = YES;
      returnVal =
      [db executeUpdate:
       @"CREATE TABLE highlights ( \
       book INT NOT NULL, \
       chapter INT NOT NULL, \
       verse INT NOT NULL, \
       value VARCHAR(255), \
       PRIMARY KEY (book, chapter, verse) \
       )"
       ];
      
      if (returnVal)
      {
        NSLog(@"Created schema for highlights.");
      }
    }
  ];
}

/**
 *
 * Return the number of user highlights in the table.
 *
 */
-(int) countHighlights
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  __block int theCount        = 0;
  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s      = [db executeQuery: @"SELECT COUNT(*) FROM highlights"];
      
      if ([s next])
      {
        theCount = [s intForColumnIndex: 0];
      }
      [s close];
    }
  ];
  
  return theCount;
}

/**
 *
 * Return a mutable array containing the passages of every highlighted passage. The
 * passage is formatted like 40N.10.5 (book.chapter.verse).
 *
 */
-(NSMutableArray *)allHighlightedPassages
{
  FMDatabaseQueue *content      = ( (PKDatabase *)[PKDatabase instance] ).content;
  NSMutableArray *theArray = [[NSMutableArray alloc] init];

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s           = [db executeQuery: @"SELECT book,chapter,verse FROM highlights ORDER BY 1,2,3"];
      
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

/**
 *
 * Returns a mutable dictionary containing all the highlighted verses for a given book
 * and chapter. This dictionary is keyed by the passage (book.chapter.verse) and contains
 * the UIColor of each highlight.
 *
 */
-(NSMutableDictionary *)allHighlightedPassagesForBook: (int) theBook andChapter: (int) theChapter
{
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;
  NSMutableDictionary *theArray = [[NSMutableDictionary alloc] init];

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s      =
      [db executeQuery:
       @"SELECT book,chapter,verse, value FROM highlights \
       WHERE book=? AND chapter=? ORDER BY 1,2,3"                                                          ,
       [NSNumber numberWithInt: theBook],
       [NSNumber numberWithInt: theChapter]];
      
      while ([s next])
      {
        int theVerse           = [s intForColumnIndex: 2];
        NSString *theResult    = [s stringForColumnIndex: 3];
        // we need to split the results: the highlight will be RRR,GGG,BBB (from 0.0 to 1.0)
        NSArray *theColorArray = [theResult componentsSeparatedByString: @","];
        // there will always be 3 values; R=0, G=1, B=2
        UIColor *theColor      = [UIColor colorWithRed: [[theColorArray objectAtIndex: 0] floatValue]
                                                 green: [[theColorArray objectAtIndex: 1] floatValue]
                                                  blue: [[theColorArray objectAtIndex: 2] floatValue] alpha: 0.33];
        
        [theArray setValue: theColor forKey: [NSString stringWithFormat: @"%i", theVerse]];
      }
      [s close];
    }
  ];

  return theArray;
}

/**
 *
 * Returns the UIColor for a specific highlighted passage. If the passage has not been
 * highlighted, it returns nil.
 *
 */
-(UIColor *)highlightForPassage: (NSString *) thePassage
{
  // if there is no highlight, we return nil.
  __block UIColor *theColor = nil;

  NSNumber *theBook    = [NSNumber numberWithInt: [PKBible bookFromString: thePassage]];
  NSNumber *theChapter = [NSNumber numberWithInt: [PKBible chapterFromString: thePassage]];
  NSNumber *theVerse   = [NSNumber numberWithInt: [PKBible verseFromString: thePassage]];

  FMDatabaseQueue *content  = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      NSString *theResult;
      FMResultSet *s       =
      [db executeQuery:
       @"SELECT value FROM highlights \
       WHERE book=? AND chapter=? AND verse=?"                                      ,
       theBook, theChapter, theVerse];
      
      if ([s next])
      {
        theResult = [s stringForColumnIndex: 0];
        // we need to split the results: the highlight will be RRR,GGG,BBB (from 0.0 to 1.0)
        NSArray *theColorArray = [theResult componentsSeparatedByString: @","];
        // there will always be 3 values; R=0, G=1, B=2
        theColor = [UIColor colorWithRed: [[theColorArray objectAtIndex: 0] floatValue]
                                   green: [[theColorArray objectAtIndex: 1] floatValue]
                                    blue: [[theColorArray objectAtIndex: 2] floatValue] alpha: 0.33];
      }
      [s close];
    }
  ];
  
  return theColor;
}

/**
 *
 * Creates a highlight for the supplied UIColor for the supplied passage.
 *
 */
-(void) setHighlight: (UIColor *) theColor forPassage: (NSString *) thePassage
{
  NSNumber *theBook    = [NSNumber numberWithInt: [PKBible bookFromString: thePassage]];
  NSNumber *theChapter = [NSNumber numberWithInt: [PKBible chapterFromString: thePassage]];
  NSNumber *theVerse   = [NSNumber numberWithInt: [PKBible verseFromString: thePassage]];
  
  FMDatabaseQueue *content  = ( (PKDatabase *)[PKDatabase instance] ).content;
  
  float red            = 0.0;
  float green          = 0.0;
  float blue           = 0.0;
  float alpha          = 0.0;
  
  if ([theColor respondsToSelector: @selector(getRed:green:blue:alpha:)])
  {
    [theColor getRed: &red green: &green blue: &blue alpha: &alpha];
  }
  else
  {
    const CGFloat *components = CGColorGetComponents([theColor CGColor]);
    red   = components[0];
    green = components[1];
    blue  = components[2];
    alpha = CGColorGetAlpha([theColor CGColor]);
  }
  
  NSString *theValue = [NSString stringWithFormat: @"%f,%f,%f", red, green, blue];

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult       = YES;
      FMResultSet *resultSet;
      int rowCount         = 0;
      
      theResult = [db executeUpdate: @"UPDATE highlights SET value=? WHERE book=? AND chapter=? AND verse=?",
                   theValue, theBook, theChapter, theVerse];
      
      // check to see if it really did just set the value
      resultSet = [db executeQuery: @"SELECT * FROM highlights WHERE book=? AND chapter=? AND verse=?",
                   theBook, theChapter, theVerse];
      
      if ([resultSet next])
      {
        rowCount++;
      }
      [resultSet close];
      
      if (rowCount < 1)
      {
        // nope; do an insert instead.
        theResult = [db executeUpdate: @"INSERT INTO highlights VALUES (?,?,?,?)",
                     theBook, theChapter, theVerse, theValue];
      }
      
      if (!theResult)
      {
        NSLog(@"Couldn't save highlight for %@", thePassage);
      }
    }
  ];

  
}

/**
 *
 * Although one could technically call setHighlight:forPassage: with [UIColor clearColor] to
 * effectively remove a highlight, it is better to call this method instead: here we actually
 * remove the row in the table, which means the highlight is gone, gone, gone.
 *
 */
-(void) removeHighlightFromPassage: (NSString *) thePassage
{
  NSNumber *theBook    = [NSNumber numberWithInt: [PKBible bookFromString: thePassage]];
  NSNumber *theChapter = [NSNumber numberWithInt: [PKBible chapterFromString: thePassage]];
  NSNumber *theVerse   = [NSNumber numberWithInt: [PKBible verseFromString: thePassage]];
  
  FMDatabaseQueue *content  = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult       = [db executeUpdate: @"DELETE FROM highlights WHERE book=? AND chapter=? AND verse=?",
                              theBook, theChapter, theVerse];
      
      if (!theResult)
      {
        NSLog(@"Could not remove highlight for %@", thePassage);
      }
    }
  ];

  
}

@end