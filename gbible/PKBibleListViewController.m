//
//  PKBibleListViewController.m
//  gbible
//
//  Created by Kerri Shotts on 1/29/13.
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
#import "PKBibleListViewController.h"
#import "PKBible.h"
#import "PKConstants.h"
#import "PKSettings.h"
#import <Parse/Parse.h>
#import "PKBibleInfoViewController.h"


@interface PKBibleListViewController ()

@end

@implementation PKBibleListViewController

@synthesize delegate;

@synthesize builtInBibleIDs;
@synthesize builtInBibleAbbreviations;
@synthesize builtInBibleTitles;

@synthesize installedBibleIDs;
@synthesize installedBibleAbbreviations;
@synthesize installedBibleTitles;

@synthesize availableBibleIDs;
@synthesize availableBibleAbbreviations;
@synthesize availableBibleTitles;

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    [self.navigationItem setTitle: __T(@"Manage Bibles")];
  }
  return self;
}

- (void)loadBibles
{
  // we'll first load the bibles we know we have
  builtInBibleIDs           = [PKBible builtInTextsWithColumn:PK_TBL_BIBLES_ID];
  builtInBibleAbbreviations = [PKBible builtInTextsWithColumn:PK_TBL_BIBLES_ABBREVIATION];
  builtInBibleTitles        = [PKBible builtInTextsWithColumn:PK_TBL_BIBLES_NAME];
  
  installedBibleIDs           = [PKBible installedTextsWithColumn:PK_TBL_BIBLES_ID];
  installedBibleAbbreviations = [PKBible installedTextsWithColumn:PK_TBL_BIBLES_ABBREVIATION];
  installedBibleTitles        = [PKBible installedTextsWithColumn:PK_TBL_BIBLES_NAME];
  
  availableBibleIDs = [[NSArray alloc] init];
  availableBibleAbbreviations = [[NSArray alloc] init];
  availableBibleTitles = [[NSArray alloc] init];
  
  [self.tableView reloadData];
  
  // send off a request to parse
  PFQuery *query = [PFQuery queryWithClassName:@"Bibles"];
  [query whereKey:@"ID" notContainedIn:installedBibleIDs];
  [query whereKey:@"minVersion" lessThanOrEqualTo:[[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"]];
  [query whereKey:@"Available" equalTo:@(YES)];
  [query orderByAscending:@"Abbreviation"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      // objects has the available bibles; let's build the available Bibles array
      NSMutableArray *mAvailableBibleIDs = [[NSMutableArray alloc] initWithCapacity:10];
      NSMutableArray *mAvailableBibleAbbreviations = [[NSMutableArray alloc] initWithCapacity:10];
      NSMutableArray *mAvailableBibleTitles = [[NSMutableArray alloc] initWithCapacity:10];
      
      for (int i=0; i<objects.count; i++)
      {
        [mAvailableBibleIDs addObject:[objects[i] objectForKey:@"ID"]];
        [mAvailableBibleAbbreviations addObject:[objects[i] objectForKey:@"Abbreviation"]];
        [mAvailableBibleTitles addObject:[objects[i] objectForKey:@"Title"]];
      }
   
   availableBibleIDs = [mAvailableBibleIDs copy];
   availableBibleAbbreviations = [mAvailableBibleAbbreviations copy];
   availableBibleTitles = [mAvailableBibleTitles copy];
   
   [self.tableView reloadData];
   } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
   }
   }];
  
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.navigationItem)
  {
    UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
     ];
    self.navigationItem.rightBarButtonItem = closeButton;
  }
    [self loadBibles];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

-(void) closeMe: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
  [[PKSettings instance] saveSettings];
}

-(void) installedBiblesChanged
{
  [self loadBibles];
  if (delegate)
  {
    [delegate installedBiblesChanged];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  switch (section)
  {
    case 0:
      return builtInBibleTitles.count;
      break;
    case 1:
      return installedBibleTitles.count;
      break;
    case 2:
      return availableBibleTitles.count;
      break;
  }
  
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
      return __T(@"Built-In Bibles");
      break;
    case 1:
      return __T(@"Installed Bibles");
      break;
    case 2:
      return __T(@"Downloadable Bibles");
      break;
  }
  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *settingsCellID = @"PKBibleCellID";
  UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier: settingsCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleValue1
            reuseIdentifier: settingsCellID];
  }
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  NSString *theBibleTitle;
  NSString *theBibleAbbreviation;
  
  switch (indexPath.section)
  {
    case 0:
      theBibleTitle = builtInBibleTitles[indexPath.row];
      theBibleAbbreviation = builtInBibleAbbreviations[indexPath.row];
      break;
    case 1:
      theBibleTitle = installedBibleTitles[indexPath.row];
      theBibleAbbreviation = installedBibleAbbreviations[indexPath.row];
      break;
    case 2:
      theBibleTitle = availableBibleTitles[indexPath.row];
      theBibleAbbreviation = availableBibleAbbreviations[indexPath.row];
      break;
  }
  
  cell.textLabel.text = theBibleTitle;
  cell.detailTextLabel.text = theBibleAbbreviation;
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  int theBibleID;
  switch (indexPath.section)
  {
    case 0:
      theBibleID = [builtInBibleIDs[indexPath.row] intValue];
      break;
    case 1:
      theBibleID = [installedBibleIDs[indexPath.row] intValue];
      break;
    case 2:
      theBibleID = [availableBibleIDs[indexPath.row] intValue];
      break;
  }
  
  PKBibleInfoViewController *bivc = [[PKBibleInfoViewController alloc] initWithBibleID:theBibleID];
  bivc.delegate = self;
  [self.navigationController pushViewController:bivc animated:YES];
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];

}

@end
