//
//  PKHighlightsViewController.m
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
#import "PKHighlightsViewController.h"
#import "PKHighlights.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
#import "PKBibleViewController.h"
//#import "PKRootViewController.h"
#import "PKSettings.h"
#import "PKAppDelegate.h"

@interface PKHighlightsViewController ()

@end

@implementation PKHighlightsViewController

@synthesize highlights;
@synthesize noResults;

# pragma mark -
# pragma mark view lifecycle

/**
 *
 * Initialize our view
 *
 */
-(id)init
{
  self = [super init];
  
  if (self)
  {
    // Custom initialization
  }
  return self;
}

/**
 *
 * set the background color and style of our table
 *
 */
-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"HIGHLIGHTS"];
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

/**
 *
 * Force a reload of all our highlights (can occur because a user just highlighted something)
 *
 */
-(void)reloadHighlights
{
  // load all highlights
  highlights = [[PKHighlights instance] allHighlightedPassages];
  [self.tableView reloadData];
  
  if ([highlights count] == 0)
  {
    noResults.text = __Tv(@"no-highlights", @"You've no highlights.");
  }
  else
  {
    noResults.text = @"";
  }
}

-(void) updateAppearanceForTheme
{
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

  self.tableView.rowHeight = 36;
  [self.tableView reloadData];
}

/**
 *
 * Force our width and then reload our highlights
 *
 */
-(void)viewDidAppear: (BOOL) animated
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
  [self reloadHighlights];
  [self updateAppearanceForTheme];
}

/**
 *
 * Release our highlights
 *
 */
-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  highlights = nil;
  noResults  = nil;
}

/**
 *
 * When animating for rotation, keep our frame at 260
 *
 */
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

#pragma mark -
#pragma mark tableview

/**
 *
 * We have one section
 *
 */
-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  return 1;
}

/**
 *
 * Return the number of highlights
 *
 */
-(NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  return [highlights count];
}

/**
 *
 * Generate a cell for the table. We will fill the cell with the "pretty" passage.
 *
 */
-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *highlightCellID = @"PKHighlightCellID";
  UITableViewCell *cell            = [tableView dequeueReusableCellWithIdentifier: highlightCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleDefault
            reuseIdentifier: highlightCellID];
  }
  
  NSUInteger row             = [indexPath row];
  
  NSString *thePassage       = [highlights objectAtIndex: row];
  int theBook                = [PKBible bookFromString: thePassage];
  int theChapter             = [PKBible chapterFromString: thePassage];
  int theVerse               = [PKBible verseFromString: thePassage];
  NSString *thePrettyPassage = [NSString stringWithFormat: @"%@ %i:%i",
                                [PKBible nameForBook: theBook], theChapter, theVerse];
  
  cell.textLabel.text            = thePrettyPassage;
  cell.textLabel.textColor       = [UIColor blackColor];
  cell.textLabel.backgroundColor = [UIColor clearColor];
  
  return cell;
}

/**
 *
 * For whatever reason, Apple decided the background should be controlled separately. So here
 * we load the background color for the desired cell. Oddly enough, it matches the highlight color.
 * /sarcasm/
 *
 */
-(void) tableView: (UITableView *) tableView willDisplayCell: (UITableViewCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row       = [indexPath row];
  NSString *thePassage = [highlights objectAtIndex: row];
  
  UIColor *theColor    = [[PKHighlights instance] highlightForPassage: thePassage];
  
  if (theColor != nil)
  {
    cell.backgroundColor = theColor;
  }
  else
  {
    cell.backgroundColor = [UIColor clearColor];
  }
}

/**
 *
 * If the user clicks on a highlight, we should navigate to that position in the Bible text.
 *
 */
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row             = [indexPath row];
  NSString *thePassage       = [highlights objectAtIndex: row];
  int theBook                = [PKBible bookFromString: thePassage];
  int theChapter             = [PKBible chapterFromString: thePassage];
  int theVerse               = [PKBible verseFromString: thePassage];
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  [[PKAppDelegate sharedInstance].rootViewController revealToggle: self];  
  [[PKAppDelegate sharedInstance].bibleViewController displayBook: theBook andChapter: theChapter andVerse: theVerse];
}

@end