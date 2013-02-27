//
//  PKNotes.m
//  gbible
//
//  Created by Kerri Shotts on 4/1/12.
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
#import "PKNotes.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PKBible.h"
#import "PKDatabase.h"
#import "searchutils.h"

@implementation PKNotes

static id _instance;

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

-(void) createSchema
{
  // get local versions of our databases
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL returnVal =
      [db executeUpdate:
       @"CREATE TABLE notes ( \
       book INT NOT NULL, \
       chapter INT NOT NULL, \
       verse INT NOT NULL, \
       title VARCHAR(4096), \
       note VARCHAR(4096), \
       PRIMARY KEY (book, chapter, verse) \
       )"
       ];
      
      if (returnVal)
      {
        NSLog(@"Created schema for notes.");
      }
    }
  ];
  
}

-(int)  countNotes;
{
  __block int theCount        = 0;
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s      = [db executeQuery: @"SELECT COUNT(*) FROM notes"];
      
      if ([s next])
      {
        theCount = [s intForColumnIndex: 0];
      }
      [s close];
    }
  ];

  return theCount;
}

-(void) setNote: (NSString *) theNote withTitle: (NSString *) theTitle forReference: (PKReference *) theReference;
{
  NSNumber *theBook    = @(theReference.book);
  NSNumber *theChapter = @(theReference.chapter);
  NSNumber *theVerse   = @(theReference.verse);
  
  FMDatabaseQueue *content  = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult       = YES;
      FMResultSet *resultSet;
      int rowCount         = 0;
      
      theResult = [db executeUpdate: @"UPDATE notes SET title=?,note=? WHERE book=? AND chapter=? AND verse=?",
                   theTitle, theNote, theBook, theChapter, theVerse];
      
      // check to see if it really did just set the value
      resultSet = [db executeQuery: @"SELECT * FROM notes WHERE book=? AND chapter=? AND verse=?",
                   theBook, theChapter, theVerse];
      
      if ([resultSet next])
      {
        rowCount++;
      }
      [resultSet close];
      
      if (rowCount < 1)
      {
        // nope; do an insert instead.
        theResult = [db executeUpdate: @"INSERT INTO notes VALUES (?,?,?,?,?)",
                     theBook, theChapter, theVerse, theTitle, theNote];
      }
      
      if (!theResult)
      {
        NSLog(@"Couldn't save note for %@", theReference);
      }
    }
  ];

}

-(void) deleteNoteForReference: (PKReference *) theReference
{
  NSNumber *theBook    = @(theReference.book);
  NSNumber *theChapter = @(theReference.chapter);
  NSNumber *theVerse   = @(theReference.verse);
  
  FMDatabaseQueue *content  = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      BOOL theResult       = [db executeUpdate: @"DELETE FROM notes WHERE book=? AND chapter=? AND verse=?",
                              theBook, theChapter, theVerse];
      
      if (!theResult)
      {
        NSLog(@"Could not remove note for %@", theReference);
      }
    }
  ];
  
}

-(NSArray *)getNoteForReference: (PKReference *) theReference;
{
  NSNumber *theBook    = @(theReference.book);
  NSNumber *theChapter = @(theReference.chapter);
  NSNumber *theVerse   = @(theReference.verse);
  
  __block NSArray *theResult;
  
  FMDatabaseQueue *content = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s      =
      [db executeQuery:
       @"SELECT title,note FROM notes \
       WHERE book=? AND chapter=? AND verse=?",
       theBook, theChapter, theVerse];
      
      theResult = nil;
      
      if ([s next])
      {
        NSString *theTitle;
        NSString *theNote;
        theTitle  = [s stringForColumnIndex: 0];
        theNote   = [s stringForColumnIndex: 1];
        theResult = [NSArray arrayWithObjects: theTitle, theNote, nil];
      }
      [s close];
    }
  ];
  return theResult;
}

-(NSMutableArray *)allNotes;
{
  FMDatabaseQueue *content      = ( (PKDatabase *)[PKDatabase instance] ).content;
  NSMutableArray *theArray = [[NSMutableArray alloc] init];

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s           = [db executeQuery: @"SELECT book,chapter,verse FROM notes ORDER BY 1,2,3"];
      
      while ([s next])
      {
        int theBook          = [s intForColumnIndex: 0];
        int theChapter       = [s intForColumnIndex: 1];
        int theVerse         = [s intForColumnIndex: 2];
        
        PKReference *theReference = [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:theVerse];
        [theArray addObject: theReference];
      }
      [s close];
    }
  ];

  return theArray;
}

-(NSMutableArray *)notesMatching: (NSString *)theTerm
{
  NSString *searchPhrase = convertSearchToSQL(theTerm, @"title || ' ' || note");
  NSMutableArray *theArray = [[NSMutableArray alloc] init];

  FMDatabaseQueue *content      = ( (PKDatabase *)[PKDatabase instance] ).content;

  [content inDatabase:^(FMDatabase *db)
    {
      FMResultSet *s           = [db executeQuery: [NSString stringWithFormat:@"SELECT book,chapter,verse FROM notes where (%@) ORDER BY 1,2,3", searchPhrase]];
      
      while ([s next])
      {
        int theBook          = [s intForColumnIndex: 0];
        int theChapter       = [s intForColumnIndex: 1];
        int theVerse         = [s intForColumnIndex: 2];
        
        PKReference *theReference = [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:theVerse];
        [theArray addObject: theReference];
      }
      [s close];
    }
  ];

  return theArray;
}

@end