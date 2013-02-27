//
//  PKDatabase.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
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
#import "PKDatabase.h"
#import "PKBible.h"
#import "PKNotes.h"
#import "PKHighlights.h"
#import "PKSettings.h"

@implementation PKDatabase

@synthesize bible;
@synthesize content;
@synthesize userBible;

static id _instance;

/**
 *
 * Return the global instance of the database
 *
 */
+(id) instance
{
  @synchronized(self) {
    if (!_instance)
    {
      _instance = [[self alloc] init];
    }
  }
  return _instance;
}

/**
 *
 * Open our databases:we have two. The first is the bible content database, located within
 * our application's bundle. The second is the user's content database, which may or may not
 * even exist, and is located in the documents folder. If we can't open them, we log the error
 * and return nil. [This means things are bound to crash.]
 *
 */
-(id) init
{
  if (self = [super init])
  {
    // open our databases
    // locate our database within the application bundle
    NSString *bibleDatabase       = [NSHomeDirectory () stringByAppendingPathComponent: @"gbible.app/bibleContent"];
    
    
    // locate our user content database
    NSString *userContentDatabase =
    [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                           YES) objectAtIndex: 0] stringByAppendingPathComponent: @"userContent"];
    
    // locate our user Bible database
    NSString *userBibleDatabase =
    [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                           YES) objectAtIndex: 0] stringByAppendingPathComponent: @"userBible"];
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0.1"))
    {
      // per apple reqs, we have to put this in the cache directory.
      userBibleDatabase =
      [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask,
                                           YES) objectAtIndex: 0] stringByAppendingPathComponent: @"userBible"];
    }

    // does the bible database exist? If not, we have a problem...
    if (![[NSFileManager defaultManager] fileExistsAtPath: bibleDatabase])
    {
      NSLog(@"[CRITICAL] Bibles could not be found at %@.", bibleDatabase);
      return nil;
    }
    else
    {
      bible = [FMDatabaseQueue databaseQueueWithPath: bibleDatabase];
    }
    
    content = [FMDatabaseQueue databaseQueueWithPath: userContentDatabase];
    userBible = [FMDatabaseQueue databaseQueueWithPath: userBibleDatabase];
  
    NSArray *allDBs = @[ bible, content, userBible ];
    NSArray *allDBNames = @[ @"Bible", @"User Content", @"User Bible"];
    
    for (int i=0; i<allDBs.count; i++)
    {
      FMDatabaseQueue *theDB = allDBs[i];
      NSString *theDBName = allDBNames[i];
      [theDB inDatabase:^(FMDatabase *db)
       {
        if (![db open])
        {
          NSLog(@"[CRITICAL] Could not open %@ Database!", theDBName);
        }

        // add a case and diacritic-insensitive comparator to the sqlite instances
        [db makeFunctionNamed: @"doesContain" maximumArguments: 2 withBlock:^(sqlite3_context * context, int aargc,
                                                                                 sqlite3_value **aargv)
         {
           if (aargc < 2)
           {
             NSLog (@"doesContain doesn't have enough parameters (%d) %s:%d", aargc, __FUNCTION__, __LINE__);
             sqlite3_result_null (context);
             return;
           }
           
           if (sqlite3_value_type (aargv[0]) == SQLITE_TEXT
               && sqlite3_value_type (aargv[1]) == SQLITE_TEXT)
           {
             @autoreleasepool {
               const char *x = (const char *)sqlite3_value_text (aargv[0]);
               NSString *sx = [NSString stringWithUTF8String: x];
               
               const char *y = (const char *)sqlite3_value_text (aargv[1]);
               NSString *sy = [NSString stringWithUTF8String: y];
               
               int lx = [sx length];
               int ly = [sy length];
               
               if (lx > 0
                   && ly > 0)
               {
                 sx = [[sx lowercaseString] stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [NSLocale currentLocale]];
                 sy = [[sy lowercaseString] stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [NSLocale currentLocale]];
                 
                 if ([[PKSettings instance] transliterateText])
                 {
                   sx = [PKBible transliterate: sx];
                   sy = [PKBible transliterate: sy];
                 }
                 sqlite3_result_int (context, [sx rangeOfString: sy].location != NSNotFound);
               }
               else
               {
                 sqlite3_result_int (context, 0);
               }
             }
           }
           else
           {
             NSLog (@"Unknown format for doesContain (%d, %d) %s:%d", sqlite3_value_type (aargv[0]),
                    sqlite3_value_type (aargv[1]), __FUNCTION__, __LINE__);
             sqlite3_result_null (context);
           }
         }
         ];
        
        
       }
      ];
    }
    
    // make sure that the userBible table has all the proper schemas
    [userBible inDatabase:^(FMDatabase *db)
      {
        [db executeUpdate: @"CREATE TABLE bibles (bibleAbbreviation TEXT, bibleAttribution TEXT, bibleSide TEXT, bibleID INTEGER PRIMARY KEY, bibleName TEXT, bibleParsedID NUMERIC)"];
        [db executeUpdate: @"CREATE TABLE [content] ([bibleID] NUMERIC, [bibleReference] TEXT, [bibleText] TEXT, [bibleBook] INT, [bibleChapter] INT, [bibleVerse] INT, PRIMARY KEY ([bibleID] ASC, [bibleBook] ASC, [bibleChapter] ASC, [bibleVerse] ASC))"];
        [db executeUpdate: @"CREATE UNIQUE INDEX [idx_content] ON [content] ([bibleChapter] ASC, [bibleBook] ASC, [bibleVerse] ASC, [bibleID] ASC)"];
      }
    ];
    
    
    // and make sure the userBible is excluded from user backup
    NSURL *URL = [[NSURL alloc] initWithString:[@"file:///" stringByAppendingString:userBibleDatabase]];
    if ( SYSTEM_VERSION_GREATER_THAN(@"5.0.1") )
    {
      NSError *error = nil;
      BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                    forKey: NSURLIsExcludedFromBackupKey error: &error];
      if(!success){
          NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
      }
    }
    else if (SYSTEM_VERSION_EQUAL_TO(@"5.0.1"))
    {
      const char* filePath = [[URL path] fileSystemRepresentation];
      const char* attrName = "com.apple.MobileBackup";
      u_int8_t attrValue = 1;
      int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
      if(!result==0){
          NSLog(@"Error excluding %@ from backup", [URL lastPathComponent]);
      }
    }
  }
  return self;
}

-(BOOL) importNotes
{
  // locate our import database
  NSString *importDatabaseName =
  [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                         YES) objectAtIndex: 0] stringByAppendingPathComponent: @"import.dat"];
  
  NSFileManager *fm            = [NSFileManager defaultManager];
  
  if (![fm fileExistsAtPath: importDatabaseName])
  {
    UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle: __T(@"Import Error")
                                                           message: __Tv(@"error-import-message",
                                                                         @"Couldn't find an 'import.dat' database; did you copy an export over with iTunes and rename it?")
                                                          delegate: self
                                                 cancelButtonTitle: nil otherButtonTitles: __T(@"OK"), nil];
    [theAlertView show];
    return NO;
  }
  
  FMDatabase *imdb = [FMDatabase databaseWithPath: importDatabaseName];
  
  if (![imdb open])
  {
    NSLog(@"[CRITICAL] Could not open the import.dat database!");
    return NO;
  }
  
  // make sure that we have the notes schema created
  PKNotes *noteModel = [PKNotes instance];
  
  // now that we have an open database, let's copy data out
  FMResultSet *s     = [imdb executeQuery: @"SELECT * FROM notes"];
  
  while ([s next])
  {
    int theBook        = [s intForColumnIndex: 0];
    int theChapter     = [s intForColumnIndex: 1];
    int theVerse       = [s intForColumnIndex: 2];
    NSString *theTitle = [s stringForColumnIndex: 3];
    NSString *theNote  = [s stringForColumnIndex: 4];
    
    // use our model to add the note (we'll happily overwrite an existing note, of course)
    [noteModel setNote: theNote withTitle: theTitle forPassage: [PKBible stringFromBook: theBook forChapter: theChapter forVerse:
                                                                 theVerse]];
  }
  
  [imdb close];
  return YES;
}

-(BOOL) importHighlights
{
  // locate our import database
  NSString *importDatabaseName =
  [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                         YES) objectAtIndex: 0] stringByAppendingPathComponent: @"import.dat"];
  
  NSFileManager *fm            = [NSFileManager defaultManager];
  
  if (![fm fileExistsAtPath: importDatabaseName])
  {
    UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle: __T(@"Import Error")
                                                           message: __Tv(@"error-import-message",
                                                                         @"Couldn't find an 'import.dat' database; did you copy an export over with iTunes and rename it?")
                                                          delegate: self
                                                 cancelButtonTitle: nil otherButtonTitles: __T(@"OK"), nil];
    [theAlertView show];
    return NO;
  }
  
  FMDatabase *imdb = [FMDatabase databaseWithPath: importDatabaseName];
  
  if (![imdb open])
  {
    NSLog(@"[CRITICAL] Could not open the import.dat database!");
    return NO;
  }
  
  // make sure that we have the notes schema created
  PKHighlights *highlightModel = [PKHighlights instance];
  
  // now that we have an open database, let's copy data out
  FMResultSet *s               = [imdb executeQuery: @"SELECT * FROM highlights"];
  
  while ([s next])
  {
    int theBook            = [s intForColumnIndex: 0];
    int theChapter         = [s intForColumnIndex: 1];
    int theVerse           = [s intForColumnIndex: 2];
    NSString *theValue     = [s stringForColumnIndex: 3];
    
    NSArray *theColorArray = [theValue componentsSeparatedByString: @","];
    // there will always be 3 values; R=0, G=1, B=2
    UIColor *theColor      = [UIColor colorWithRed: [[theColorArray objectAtIndex: 0] floatValue]
                                             green: [[theColorArray objectAtIndex: 1] floatValue]
                                              blue: [[theColorArray objectAtIndex: 2] floatValue] alpha: 1.0];
    
    // use our model to add the highlight
    [highlightModel setHighlight: theColor forPassage: [PKBible stringFromBook: theBook forChapter: theChapter forVerse: theVerse]];
  }
  
  [imdb close];
  return YES;
}

-(BOOL) importSettings
{
  // locate our import database
  NSString *importDatabaseName =
  [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                         YES) objectAtIndex: 0] stringByAppendingPathComponent: @"import.dat"];
  
  NSFileManager *fm            = [NSFileManager defaultManager];
  
  if (![fm fileExistsAtPath: importDatabaseName])
  {
    UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle: __T(@"Import Error")
                                                           message: __Tv(@"error-import-message",
                                                                         @"Couldn't find an 'import.dat' database; did you copy an export over with iTunes and rename it?")
                                                          delegate: self
                                                 cancelButtonTitle: nil otherButtonTitles: __T(@"OK"), nil];
    [theAlertView show];
    return NO;
  }
  
  FMDatabase *imdb = [FMDatabase databaseWithPath: importDatabaseName];
  
  if (![imdb open])
  {
    NSLog(@"[CRITICAL] Could not open the import.dat database!");
    return NO;
  }
  
  // make sure that we have the notes schema created
  PKSettings *settingsModel = [PKSettings instance];
  
  // now that we have an open database, let's copy data out
  FMResultSet *s            = [imdb executeQuery: @"SELECT * FROM settings"];
  
  while ([s next])
  {
    NSString *theSettingKey   = [s stringForColumnIndex: 0];
    NSString *theSettingValue = [s stringForColumnIndex: 1];
    
    // use our model to save the setting
    [settingsModel saveSetting: theSettingKey valueForSetting: theSettingValue];
  }
  [settingsModel reloadSettings];
  [imdb close];
  return YES;
}

-(BOOL) exportAll
{
  //[content close];          // close the database first...
  
  // our export will be of the form: exportMMDDYYY_HHMISS.dat
  NSDate *theDate               = [NSDate date];
  NSDateFormatter *theFormatter = [[NSDateFormatter alloc] init];
  [theFormatter setDateFormat: @"yyyyMMddHHmmss"];
  
  NSString *theExportName       = [NSString stringWithFormat: @"export%@.dat",
                                   [theFormatter stringFromDate: theDate]];
  // get the export name
  NSString *exportDatabaseName  =
  [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                         YES) objectAtIndex: 0] stringByAppendingPathComponent: theExportName];
  // locate our user content database
  NSString *userContentDatabase =
  [[NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,
                                         YES) objectAtIndex: 0] stringByAppendingPathComponent: @"userContent"];
  
  NSFileManager *fileManager    = [NSFileManager defaultManager];
  
  NSLog(@"Source File for Copy: %@", userContentDatabase);
  NSLog(@"Target File for Copy: %@", exportDatabaseName);
  
  if ([fileManager copyItemAtPath: userContentDatabase toPath: exportDatabaseName error: nil] == YES)
  {
    NSLog(@"Export successful.");
  }
  else
  {
    NSLog(@"Export unsuccessful.");
    return NO;
  }
  
  //[content open];
  return YES;
}

/**
 *
 * Release our databases and close them.
 *
 */
-(void) dealloc
{
  // close our databases
  [userBible close];
  [content close];
  [bible close];
  content = nil;
  bible   = nil;
}

@end