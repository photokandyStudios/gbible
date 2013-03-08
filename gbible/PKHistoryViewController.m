//
//  PKHistoryViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
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
#import "PKHistoryViewController.h"
#import "PKHistory.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
//#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKSearchViewController.h"
#import "PKStrongsController.h"
#import "PKSettings.h"
#import "TestFlight.h"
#import "PKAppDelegate.h"
#import "PKReference.h"

@interface PKHistoryViewController ()

@end

@implementation PKHistoryViewController

@synthesize history;
@synthesize noResults;

-(void)reloadHistory
{
  history = [(PKHistory *)[PKHistory instance] mostRecentHistory];
  [self.tableView reloadData];
  
  if ([history count] == 0)
  {
    noResults.text = __Tv(@"no-history", @"You've no history.");
  }
  else
  {
    noResults.text = @"";
  }
}

-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];
  
  if (self)
  {
    // Custom initialization
  }
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  [TestFlight passCheckpoint: @"HISTORY"];
  
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSelectionColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  CGRect theRect = CGRectMake(0, self.tableView.center.y + 20, 260, 60);
  noResults                  = [[UILabel alloc] initWithFrame: theRect];
  noResults.textColor        = [PKSettings PKTextColor];
  noResults.font             = [UIFont fontWithName: @"Zapfino" size: 15];
  noResults.textAlignment    = UITextAlignmentCenter;
  noResults.backgroundColor  = [UIColor clearColor];
  noResults.shadowColor      = [UIColor clearColor];
  noResults.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  noResults.numberOfLines    = 0;
  [self.view addSubview: noResults];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  history   = nil;
  noResults = nil;
}

-(void) updateAppearanceForTheme
{
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

  self.tableView.rowHeight = 36;
  [self.tableView reloadData];
}

-(void)viewDidAppear: (BOOL) animated
{
  [super viewDidAppear:animated];
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
  [self reloadHistory];
  [self updateAppearanceForTheme];
  [self calculateShadows];
}

-(void)didAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
}

-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView: (UITableView *) tableView
{
  // Return the number of sections.
  return 1;
}

-(NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  // Return the number of rows in the section.
  return [history count];
}

-(UITableViewCell *)tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *historyCellID = @"PKHistoryCellID";
  UITableViewCell *cell          = [tableView dequeueReusableCellWithIdentifier: historyCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleDefault
            reuseIdentifier: historyCellID];
  }
  
  NSUInteger row           = [indexPath row];
  cell.textLabel.textColor = [PKSettings PKSidebarTextColor];
  cell.textLabel.font      = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  
  NSString *theHistoryItem = [history objectAtIndex: row];
  
  if ([theHistoryItem characterAtIndex: 0] == 'P')
  {
    // passage
    PKReference *theReference       = [PKReference referenceWithString:[theHistoryItem substringFromIndex: 1]];
    int theBook                = theReference.book;
    int theChapter             = theReference.chapter;
    int theVerse               = theReference.verse;
    NSString *thePrettyReference = [NSString stringWithFormat: @"%@ %i:%i",
                                  [PKBible nameForBook: theBook], theChapter, theVerse];
    
    cell.textLabel.text = thePrettyReference;
  }
  else
    if ([theHistoryItem characterAtIndex: 0] == 'B')
    {
      // Bible search
      NSString *theSearchTerm = [theHistoryItem substringFromIndex: 1];
      cell.textLabel.text = [NSString stringWithFormat: @"%@: %@", __T(@"Bible"), theSearchTerm];
    }
    else
      if ([theHistoryItem characterAtIndex: 0] == 'S')
      {
        // Strongs search
        NSString *theStrongsTerm = [theHistoryItem substringFromIndex: 1];
        cell.textLabel.text = [NSString stringWithFormat: @"%@: %@", __T(@"Strong's"), theStrongsTerm];
      }
  
  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row               = [indexPath row];
  NSString *theHistoryItem     = [history objectAtIndex: row];
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  
  [[PKAppDelegate sharedInstance].rootViewController revealToggle: self];
  
  if ([theHistoryItem characterAtIndex: 0] == 'P')
  {
    // passage
    PKReference *theReference       = [PKReference referenceWithString:[theHistoryItem substringFromIndex: 1]];
    int theBook                = theReference.book;
    int theChapter             = theReference.chapter;
    int theVerse               = theReference.verse;
    [[PKAppDelegate sharedInstance].bibleViewController displayBook: theBook andChapter: theChapter andVerse: theVerse];
  }
  else
    if ([theHistoryItem characterAtIndex: 0] == 'B')
    {
      PKSearchViewController *sbvc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
      // Bible search
      NSString *theSearchTerm = [theHistoryItem substringFromIndex: 1];
      [sbvc doSearchForTerm: theSearchTerm];
      [[PKAppDelegate sharedInstance].bibleViewController.navigationController pushViewController:sbvc animated:YES];
    }
    else
      if ([theHistoryItem characterAtIndex: 0] == 'S')
      {
        PKStrongsController *ssvc    = [[PKStrongsController alloc] initWithStyle:UITableViewStylePlain];
        // Strongs search
        NSString *theStrongsTerm = [theHistoryItem substringFromIndex: 1];
        [ssvc doSearchForTerm: theStrongsTerm];
      [[PKAppDelegate sharedInstance].bibleViewController.navigationController pushViewController:ssvc animated:YES];
      }
}

@end