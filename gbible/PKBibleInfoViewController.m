//
//  PKBibleInfoViewController.m
//  gbible
//
//  Created by Kerri Shotts on 1/30/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
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
#import "PKBibleInfoViewController.h"
#import "PKBible.h"
#import "PKDatabase.h"
#import "PKConstants.h"
#import "UIColor-Expanded.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "PKSettings.h"
#import "SSZipArchive.h"

@interface PKBibleInfoViewController ()

@end

@implementation PKBibleInfoViewController
{
  int _theBibleID;
  UILabel *  __strong _theBibleTitle;
  UILabel *  __strong _theBibleAbbreviation;
  UIImageView *  __strong _theBibleImage;
  UILabel *  __strong _theBibleImageAbbr;
  UIWebView *  __strong _theBibleInformation;
  MAConfirmButton *  __strong _theActionButton;
}

- (id)initWithBibleID: (int) bibleID
{
  self = [super init];
  if (self) {
    // Custom initialization
    _theBibleID = bibleID;
    [self.navigationItem setTitle: __T(@"Manage Bible")];
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha: 1.0];
  
  // create the UI layout and then fire off a load of the information.
  _theBibleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 141, 173)];
  _theBibleImage.image = [UIImage imageNamed:@"leather-book"];
  [self.view addSubview:_theBibleImage];
  
  _theBibleImageAbbr = [[UILabel alloc] initWithFrame:CGRectMake(35, 30, 98, 35)];
  _theBibleImageAbbr.font = [UIFont fontWithName:@"Georgia" size:35];
  _theBibleImageAbbr.textColor = [UIColor colorWithHexString:@"b4a567"];
  _theBibleImageAbbr.textAlignment = UITextAlignmentCenter;
  _theBibleImageAbbr.backgroundColor = [UIColor clearColor];
  _theBibleImageAbbr.adjustsFontSizeToFitWidth = YES;
  _theBibleImageAbbr.shadowColor = [UIColor whiteColor];
  _theBibleImageAbbr.shadowOffset = CGSizeMake(0, -1);
  [self.view addSubview:_theBibleImageAbbr];
  _theBibleInformation = [[UIWebView alloc] initWithFrame: CGRectMake( 151, 10, self.view.bounds.size.width-171,
                                                                     self.view.bounds.size.height-20 )];
  _theBibleInformation.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _theBibleInformation.backgroundColor = [UIColor clearColor];
  _theBibleInformation.opaque = NO;
  [self.view addSubview:_theBibleInformation];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self loadBibleInformation];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
}

- (void)setHTML: (NSString *)theHTML
{
  NSString *preHTMLiPad = @"<style>BODY { background-color: #f2f2f2; font-family: 'Helvetica'; color:#333; }</style>";
  NSString *preHTMLiPhone = @"<style>BODY { background-color: #f2f2f2; font-family: 'Helvetica'; color:#333; font-size: 66%}</style>";
  [_theBibleInformation loadHTMLString:[(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? preHTMLiPad : preHTMLiPhone) stringByAppendingString:theHTML] baseURL:nil];
}

- (void)loadBibleInformation
{
  if (_theActionButton)
  {
    [_theActionButton removeFromSuperview];
    _theActionButton = nil;
  }
  
  // if the Bible is a built-in or installed, we want to get the information from there first.
  if ( [PKBible isTextBuiltIn: _theBibleID] )
  {
    //    theBibleTitle.text = [PKBible text:theBibleID inDB:[[PKDatabase instance]bible] withColumn:PK_TBL_BIBLES_NAME];
    //    theBibleAbbreviation.text = [PKBible text:theBibleID inDB:[[PKDatabase instance]bible] withColumn:PK_TBL_BIBLES_ABBREVIATION];
    _theBibleImageAbbr.text = [PKBible text:_theBibleID inDB:[[PKDatabase instance]bible] withColumn:PK_TBL_BIBLES_ABBREVIATION];
    [self setHTML:[PKBible text:_theBibleID inDB:[[PKDatabase instance]bible] withColumn:PK_TBL_BIBLES_ATTRIBUTION]];
    
    _theActionButton = [[MAConfirmButton alloc] initWithDisabledTitle:__T(@"Built-In")];
    [_theActionButton setAnchor:CGPointMake(141, 193)];
    [self.view addSubview:_theActionButton];
  }
  else
    if ( [PKBible isTextInstalled: _theBibleID] )
    {
      //      theBibleTitle.text = [PKBible text:theBibleID inDB:[[PKDatabase instance]userBible] withColumn:PK_TBL_BIBLES_NAME];
      //      theBibleAbbreviation.text = [PKBible text:theBibleID inDB:[[PKDatabase instance]userBible] withColumn:PK_TBL_BIBLES_ABBREVIATION];
      _theBibleImageAbbr.text = [PKBible text:_theBibleID inDB:[[PKDatabase instance]userBible] withColumn:PK_TBL_BIBLES_ABBREVIATION];
      [self setHTML:[PKBible text:_theBibleID inDB:[[PKDatabase instance]userBible] withColumn:PK_TBL_BIBLES_ATTRIBUTION]];
      _theActionButton = [[MAConfirmButton alloc] initWithTitle:__T(@"Installed") confirm:__T(@"Remove Bible")];
      _theActionButton.secondColor=[UIColor redColor];
      [_theActionButton setAnchor:CGPointMake(141, 193)];
      [_theActionButton addTarget:self action:@selector(removeBible:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:_theActionButton];
    }
    else
    {
      // the bible is an available one; get the object from Parse.
      // send off a request to parse
      [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                     ^{
                       
                       PFQuery *query = [PFQuery queryWithClassName:@"Bibles"];
                       [query whereKey:@"ID" equalTo:@(_theBibleID)];
                       [query orderByAscending:@"Abbreviation"];
                       [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                         if (!error) {
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                            [SVProgressHUD dismiss];
                                            for (int i=0; i<objects.count; i++)
                                            {
                                              //            theBibleTitle.text = [objects[i] objectForKey:@"Title"];
                                              //            theBibleAbbreviation.text = [objects[i] objectForKey:@"Abbreviation"];
                                              _theBibleImageAbbr.text = [objects[i] objectForKey:@"Abbreviation"];
                                              [self setHTML:[objects[i] objectForKey:@"Info"]];
                                              
                                              _theActionButton = [[MAConfirmButton alloc] initWithTitle:__T(@"FREE") confirm:__T(@"Download")];
                                              [_theActionButton setAnchor:CGPointMake(141, 193)];
                                              [_theActionButton addTarget:self action:@selector(downloadBible:) forControlEvents:UIControlEventTouchUpInside];
                                              [self.view addSubview:_theActionButton];
                                              
                                            }
                                          });
                         } else {
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                            [SVProgressHUD dismiss];
                                          });
                           // Log details of the failure
                           NSLog(@"Error: %@ %@", error, [error userInfo]);
                         }
                       }];
                     });
    }
  
}

- (void) removeBible: (id) sender
{
  // make sure we're not currently using the Bible in question
  if ([[PKSettings instance] englishText] == _theBibleID)
  {
    // change the text
    [PKSettings instance].englishText = PK_BIBLETEXT_YLT;
    [[PKSettings instance] saveSettings];
  }
  // change the button
  [_theActionButton disableWithTitle:__T(@"Removing")];
  [SVProgressHUD showWithStatus:__T(@"Removing...") maskType:SVProgressHUDMaskTypeClear];
  
  // delete the corresponding entry from the master table,
  // and all records from the content table
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                 ^{
                   FMDatabaseQueue *db = [[PKDatabase instance] userBible];
                   [db inDatabase: ^(FMDatabase *db)
                    {
                      // delete the Bible metadata
                      NSString *sql = @"DELETE FROM bibles WHERE bibleID=?";
                      [db executeUpdate:sql, @(_theBibleID)];
                      
                      // delete the content of the specific Bible
                      sql = @"DELETE FROM content WHERE bibleID=?";
                      [db executeUpdate:sql, @(_theBibleID)];
                      
                      // delete the search Index for the Bible
                      sql = @"DELETE FROM searchIndex WHERE bibleID=?";
                      [db executeUpdate:sql, @(_theBibleID)];
                      
                      // delete all the unused search index master records
                      sql = @"DELETE FROM searchIndexMaster WHERE NOT EXISTS (SELECT searchIndexTerm FROM searchIndex WHERE searchIndexTerm=searchIndexMasterID)";
                      [db executeUpdate:sql];
                      
                      [db executeUpdate:@"Vacuum"]; // might have to remark to exclude from backup?
                      
                      dispatch_async(dispatch_get_main_queue(),
                                     ^{
                                       [SVProgressHUD showSuccessWithStatus:__T(@"Removed!")];
                                       [self loadBibleInformation];
                                       if (_delegate)
                                       {
                                         [_delegate installedBiblesChanged];
                                       }
                                     }
                                     );
                    }
                    ];
                 }
                 );
}

- (void) downloadBible: (id) sender
{
  // change the button
  [_theActionButton disableWithTitle:__T(@"Installing")];
  
  // ask Parse for the Bible again
  PFQuery *query = [PFQuery queryWithClassName:@"Bibles"];
  [query whereKey:@"ID" equalTo:@(_theBibleID)];
  [query orderByAscending:@"Abbreviation"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      for (int i=0; i<objects.count; i++)
      {
        [objects[i] incrementKey:@"DLCount"];
        [objects[i] saveEventually];
        PFFile *theBibleFile = [objects[i] objectForKey:@"Data"];
        NSString * theBibleFileName = [[objects[i] objectForKey:@"Abbreviation"] stringByAppendingString:@".zip"];
        [theBibleFile getDataInBackgroundWithBlock:
         ^(NSData *data, NSError *error)
         {
           [SVProgressHUD showWithStatus:__T(@"Installing...") maskType:SVProgressHUDMaskTypeClear];
           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                          ^{
                            // save the data out to a temporary file
                            NSString *directoryPath = NSTemporaryDirectory();
                            NSLog (@"%@", directoryPath);
                            NSString *downloadFileTo = [NSString stringWithFormat:@"%@/%@", directoryPath, theBibleFileName];
                            [data writeToFile:downloadFileTo atomically:YES];
                            
                            // now that the file is saved, we need to uncompress it.
                            [SSZipArchive unzipFileAtPath:downloadFileTo toDestination:directoryPath];
                            
                            // now that the file is written, attach it to our userBible database
                            FMDatabaseQueue *dbq = [[PKDatabase instance] userBible];
                            FMDatabase *db = dbq.database;
                            [db executeUpdate:@"ATTACH DATABASE ? AS bibleImport", [downloadFileTo stringByReplacingOccurrencesOfString:@"zip" withString:@"db"]];
                            [db executeUpdate:@"INSERT INTO content SELECT * FROM bibleImport.content"];
                            [db executeUpdate:@"INSERT INTO bibles SELECT * FROM bibleImport.bibles"];
                            [db executeUpdate:@"INSERT INTO searchIndexMaster SELECT null, searchIndexMasterTerm FROM ( SELECT searchIndexMasterTerm FROM bibleImport.searchIndexMaster EXCEPT SELECT searchIndexMasterTerm FROM searchIndexMaster)"];
                            [db executeUpdate:@"INSERT INTO searchIndex SELECT null, (SELECT searchIndexMasterID FROM searchIndexMaster WHERE searchIndexMasterTerm=(SELECT searchIndexMasterTerm FROM bibleImport.searchIndexMaster WHERE searchIndexMasterID=searchIndexTerm) ) searchIndexTerm, bibleID, lexiconID, commentaryID, reference FROM bibleImport.searchIndex"];
                            [db executeUpdate:@"DETACH DATABASE bibleImport"];
                            
                            
/*
                            
                            // now that the file is written, we need to open it up as a database
                            FMDatabase *theNewBible = [[FMDatabase alloc] initWithPath:downloadFileTo];
                            [theNewBible open];
                            FMDatabaseQueue *db = [[PKDatabase instance] userBible];
                            
                            [db inTransaction: ^(FMDatabase *db, BOOL *rollback)
                             {
                               FMResultSet *s = [theNewBible executeQuery:@"SELECT * FROM content order by 4,5,6"];
                               int i=0;
                               while ([s next])
                               {
                                 if (i%25==0)
                                 {
                                   dispatch_async(dispatch_get_main_queue(),
                                                  ^{
                                                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Verse %i", i] maskType:SVProgressHUDMaskTypeClear];
                                                  }
                                                  );
                                 }
                                 i++;
                                 NSString *sql = @"INSERT INTO content VALUES (?, ?, ?, ?, ?, ?)";
                                 [db executeUpdate:sql, [s objectForColumnIndex:0],
                                  [s objectForColumnIndex:1],
                                  [s objectForColumnIndex:2],
                                  [s objectForColumnIndex:3],
                                  [s objectForColumnIndex:4],
                                  [s objectForColumnIndex:5]];
                               }
                               [db commit];
                             }
                             ];
                            
                            // also add to the master table
                            FMResultSet *s = [theNewBible executeQuery:@"SELECT * FROM bibles"];
                            while ([s next])
                            {
                              FMDatabaseQueue *db = [[PKDatabase instance] userBible];
                              [db inDatabase:^(FMDatabase *db)
                               {
                                 NSString *sql = @"INSERT INTO bibles VALUES (?, ?, ?, ?, ?, NULL)";
                                 [db executeUpdate:sql, [s objectForColumnIndex:0],
                                  [s objectForColumnIndex:1],
                                  [s objectForColumnIndex:2],
                                  [s objectForColumnIndex:3],
                                  [s objectForColumnIndex:4]];
                               }
                               ];
                            }
                            
                            [theNewBible close];
*/
                            // delete the file once we're done with it
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            [fileManager removeItemAtPath:[downloadFileTo stringByReplacingOccurrencesOfString:@"zip" withString:@"db"] error:NULL];
                            [fileManager removeItemAtPath:downloadFileTo error:NULL];
                            // tell the user we're done
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                             [SVProgressHUD showSuccessWithStatus:__T(@"Installed!")];
                                             [self loadBibleInformation];
                                             if (_delegate)
                                             {
                                               [_delegate installedBiblesChanged];
                                             }
                                             
                                           }
                                           );
                          }
                          );
         }
                                     progressBlock:
         ^(int percentDone)
         {
           [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%i%%", percentDone] maskType:SVProgressHUDMaskTypeClear];
         }
         ];
        
      }
    } else {
      // Log details of the failure
      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
  }];
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
