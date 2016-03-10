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
#import "UIImage+PKUtility.h"

@interface PKBibleInfoViewController ()

@end

@implementation PKBibleInfoViewController
{
  int _theBibleID;
  UILabel *  /**__strong**/ _theBibleTitle;
  UILabel *  /**__strong**/ _theBibleAbbreviation;
  UIImageView *  /**__strong**/ _theBibleImage;
  UILabel *  /**__strong**/ _theBibleImageAbbr;
  UIWebView *  /**__strong**/ _theBibleInformation;
  MAConfirmButton *  /**__strong**/ _theActionButton;
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

  self.extendedLayoutIncludesOpaqueBars  = YES;
  self.edgesForExtendedLayout = UIRectEdgeNone;
  [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[PKSettings PKSecondaryPageColor]] forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  
  self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha: 1.0];
  
  // create the UI layout and then fire off a load of the information.
  _theBibleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 141, 173)];
  _theBibleImage.image = [UIImage imageNamed:@"leather-book"];
  [self.view addSubview:_theBibleImage];
  
  _theBibleImageAbbr = [[UILabel alloc] initWithFrame:CGRectMake(35, 30, 98, 35)];
  _theBibleImageAbbr.font = [UIFont fontWithName:@"Georgia" size:35];
  _theBibleImageAbbr.textColor = [UIColor colorWithHexString:@"b4a567"];
  _theBibleImageAbbr.textAlignment = NSTextAlignmentCenter;
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
      [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone]; } afterDelay:0.01];
      [self performBlockAsynchronouslyInForeground:^{
         PFQuery *query = [PFQuery queryWithClassName:@"Bibles"];
         [query whereKey:@"ID" equalTo:@(_theBibleID)];
         [query orderByAscending:@"Abbreviation"];
         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           if (!error) {
             [self performBlockAsynchronouslyInForeground:^{
                              [SVProgressHUD dismiss];
                              for (int i=0; i<objects.count; i++)
                              {
                                //            theBibleTitle.text = [objects[i] objectForKey:@"Title"];
                                //            theBibleAbbreviation.text = [objects[i] objectForKey:@"Abbreviation"];
                                _theBibleImageAbbr.text = (objects[i])[@"Abbreviation"];
                                [self setHTML:(objects[i])[@"Info"]];
                                
                                _theActionButton = [[MAConfirmButton alloc] initWithTitle:__T(@"FREE") confirm:__T(@"Download")];
                                [_theActionButton setAnchor:CGPointMake(141, 193)];
                                [_theActionButton addTarget:self action:@selector(downloadBible:) forControlEvents:UIControlEventTouchUpInside];
                                [self.view addSubview:_theActionButton];
                                
                              }
                            } afterDelay:0.1f];
           } else {
             [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD dismiss]; } afterDelay:0.01];
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
           }
         }];
      } afterDelay:0.02];
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

  // TODO: what about the greek side? 
  
  // change the button
  [self performBlockAsynchronouslyInForeground:^{
    [_theActionButton disableWithTitle:__T(@"Removing")];
    [SVProgressHUD showWithStatus:__T(@"Removing...") maskType:SVProgressHUDMaskTypeClear];
  } afterDelay:0.01];

  
  // delete the corresponding entry from the master table,
  // and all records from the content table
  [self performBlockAsynchronouslyInBackground:^{
                   FMDatabaseQueue *db = [[PKDatabase instance] userBible];
                   [db inDatabase: ^(FMDatabase *db)
                    {
                      // delete the Bible metadata
                      NSString *sql = @"DELETE FROM bibles WHERE bibleID=?";
                      [db executeUpdate:sql, @(_theBibleID)];
                      
                      // delete the content of the specific Bible
                      sql = @"DELETE FROM content WHERE bibleID=?";
                      [db executeUpdate:sql, @(_theBibleID)];
                      
                      /* NOTE: removing for now, until I come up with a better search index
                      // delete the search Index for the Bible
                      sql = @"DELETE FROM searchIndex WHERE bibleID=?";
                      [db executeUpdate:sql, @(_theBibleID)];
                      
                      // delete all the unused search index master records
                      sql = @"DELETE FROM searchIndexMaster WHERE NOT EXISTS (SELECT searchIndexTerm FROM searchIndex WHERE searchIndexTerm=searchIndexMasterID)";
                      [db executeUpdate:sql];
                      */
                      [db executeUpdate:@"Vacuum"]; // TODO: might have to remark to exclude from backup?
                      
                      [self performBlockAsynchronouslyInForeground:^{
                                       [SVProgressHUD showSuccessWithStatus:__T(@"Removed!")];
                                       [self loadBibleInformation];
                                       if (_delegate)
                                       {
                                         [_delegate installedBiblesChanged];
                                       }
                                     } afterDelay:0.01];
                    }
                    ];
                 } afterDelay:0.02];
}

- (void) downloadBible: (id) sender
{
  // change the button
  [self performBlockAsynchronouslyInForeground:^{
    [_theActionButton disableWithTitle:__T(@"Installing")];
    [SVProgressHUD showWithStatus:__T(@"Installing...") maskType:SVProgressHUDMaskTypeClear];
  } afterDelay:0.01];
  
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
        PFFile *theBibleFile = (objects[i])[@"Data"];
        NSString * theBibleFileName = [(objects[i])[@"Abbreviation"] stringByAppendingString:@".zip"];
        [theBibleFile getDataInBackgroundWithBlock:
         ^(NSData *data, NSError *error)
         {
            [self performBlockAsynchronouslyInBackground:^{
                            // save the data out to a temporary file
                            NSString *directoryPath = NSTemporaryDirectory();
                            NSLog (@"%@", directoryPath);
                            NSString *downloadFileTo = [NSString stringWithFormat:@"%@/%@", directoryPath, theBibleFileName];
                            [data writeToFile:downloadFileTo atomically:YES];
                            
                            // now that the file is saved, we need to uncompress it.
                            [SSZipArchive unzipFileAtPath:downloadFileTo toDestination:directoryPath];
                            
                            // now that the file is written, attach it to our userBible database
                            FMDatabaseQueue *dbq = [[PKDatabase instance] userBible];
                            [dbq inDatabase:^(FMDatabase *db) {
                              [db executeUpdate:@"ATTACH DATABASE ? AS bibleImport", [downloadFileTo stringByReplacingOccurrencesOfString:@"zip" withString:@"db"]];
                              [db executeUpdate:@"INSERT INTO content SELECT * FROM bibleImport.content"];
                              [db executeUpdate:@"INSERT INTO bibles SELECT * FROM bibleImport.bibles"];
                              /* NOTE: Removing for now until I come up with a better option.
                               [db executeUpdate:@"INSERT INTO searchIndexMaster SELECT null, searchIndexMasterTerm FROM ( SELECT searchIndexMasterTerm FROM bibleImport.searchIndexMaster EXCEPT SELECT searchIndexMasterTerm FROM searchIndexMaster)"];
                               [db executeUpdate:@"INSERT INTO searchIndex SELECT null, (SELECT searchIndexMasterID FROM searchIndexMaster WHERE searchIndexMasterTerm=(SELECT searchIndexMasterTerm FROM bibleImport.searchIndexMaster WHERE searchIndexMasterID=searchIndexTerm) ) searchIndexTerm, bibleID, lexiconID, commentaryID, reference FROM bibleImport.searchIndex"];
                               */
                              [db executeUpdate:@"DETACH DATABASE bibleImport"];
                            }];
              
                            // delete the file once we're done with it
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            [fileManager removeItemAtPath:[downloadFileTo stringByReplacingOccurrencesOfString:@"zip" withString:@"db"] error:NULL];
                            [fileManager removeItemAtPath:downloadFileTo error:NULL];
                            // tell the user we're done
                            [self performBlockAsynchronouslyInForeground:^{
                                             [SVProgressHUD showSuccessWithStatus:__T(@"Installed!")];
                                             [self loadBibleInformation];
                                             if (_delegate)
                                             {
                                               [_delegate installedBiblesChanged];
                                             }
                                           } afterDelay:0.01f];
                          } afterDelay:0.02f];
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
