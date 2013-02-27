//
//  PKNotesViewController.m
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
#import "PKNotesViewController.h"
#import "PKNotes.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
#import "PKBibleViewController.h"
//#import "PKRootViewController.h"
#import "PKSettings.h"
#import "PKAppDelegate.h"
#import "PKReference.h"

@interface PKNotesViewController ()

@end

@implementation PKNotesViewController

@synthesize notes;
@synthesize noResults;

@synthesize theSearchBar;
@synthesize theSearchTerm;
@synthesize clickToDismiss;

-(void)updateNotesViewAfterSearch
{
  [self.tableView reloadData];
  
  if ([notes count] == 0)
  {
    noResults.text = __Tv(@"no-results", @"No results.");
  }
  else
  {
    noResults.text = @"";
  }

}
-(void)reloadNotes
{
    notes = [(PKNotes *)[PKNotes instance] allNotes];
  [self.tableView reloadData];
  if ([notes count] == 0)
  {
    noResults.text = __Tv(@"no-notes", @"You don't have any notes.");
  }
  else
  {
    noResults.text = @"";
  }
  
}

-(id)init
{
  self = [super init];
  
  if (self)
  {
    // Custom initialization
    self.theSearchTerm = [[PKSettings instance] lastNotesSearch];

  }
  return self;
}

-(void) updateAppearanceForTheme
{
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  self.tableView.rowHeight       = 100;
  [self.tableView reloadData];
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"ANNOTATIONS"];
  
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSelectionColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  // add search bar
  theSearchBar                   = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
  theSearchBar.delegate          = self;
  theSearchBar.placeholder       = __T(@"Search Term");
  theSearchBar.showsCancelButton = NO;
  theSearchBar.text = theSearchTerm;
  self.tableView.tableHeaderView = theSearchBar;

  CGRect theRect = CGRectMake(0, self.tableView.center.y + 20, 260, 60);
  noResults                  = [[UILabel alloc] initWithFrame: theRect];
  noResults.textColor        = [PKSettings PKTextColor]; //[UIColor whiteColor];
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
 * Force our width and then reload our highlights
 *
 */
-(void)viewDidAppear: (BOOL) animated
{
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;
  [self reloadNotes];
  [self updateAppearanceForTheme];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  notes     = nil;
  noResults = nil;
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
  return [notes count];
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
            initWithStyle: UITableViewCellStyleSubtitle
            reuseIdentifier: highlightCellID];
  }
  
  NSUInteger row       = [indexPath row];
  
  PKReference *theReference = [notes objectAtIndex: row];
  //    int theBook = [PKBible bookFromString:thePassage];
  //    int theChapter = [PKBible chapterFromString:thePassage];
  //    int theVerse = [PKBible verseFromString:thePassage];
  //    NSString *thePrettyPassage = [NSString stringWithFormat:@"%@ %i:%i",
  //                                           [PKBible nameForBook:theBook], theChapter, theVerse];
  
  NSArray *theNoteArray = [(PKNotes *)[PKNotes instance] getNoteForReference: theReference];
  NSString *theTitle    = [theNoteArray objectAtIndex: 0];
  NSString *theNote     = [theNoteArray objectAtIndex: 1];
  
  cell.textLabel.text                = theTitle;
  cell.textLabel.textColor           = [PKSettings PKSidebarTextColor];
  cell.detailTextLabel.text          = theNote;
  cell.detailTextLabel.textColor     = [PKSettings PKSidebarTextColor];
  cell.detailTextLabel.numberOfLines = 4;
  [cell.detailTextLabel sizeToFit];
  
  return cell;
}

/**
 *
 * If the user clicks on a highlight, we should navigate to that position in the Bible text.
 *
 */
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row             = [indexPath row];
  PKReference *theReference       = [notes objectAtIndex: row];
  int theBook                = theReference.book;
  int theChapter             = theReference.chapter;
  int theVerse               = theReference.verse;
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  [[PKAppDelegate sharedInstance].rootViewController revealToggle: self];
  [[PKAppDelegate sharedInstance].bibleViewController displayBook: theBook andChapter: theChapter andVerse: theVerse];
}

-(BOOL)canBecomeFirstResponder
{
  return YES;
}

#pragma mark -
#pragma mark Searching
-(void)searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
  [self hideKeyboard];
  theSearchTerm = searchBar.text;
  ((PKSettings *)[PKSettings instance]).lastNotesSearch = theSearchTerm;
  [[PKSettings instance] saveSettings];
  if ([theSearchTerm isEqualToString:@""])
  {
    [self reloadNotes];
  }
  else
  {
    notes = [(PKNotes *)[PKNotes instance] notesMatching:theSearchTerm];
    [self updateNotesViewAfterSearch];
  }
}

-(void)searchBarTextDidBeginEditing: (UISearchBar *) searchBar
{
  CGRect theRect = self.tableView.frame;
  theRect.origin.y               += 44;
  clickToDismiss                  = [[UIButton alloc] initWithFrame: theRect];
  clickToDismiss.autoresizingMask = UIViewAutoresizingFlexibleWidth |
  UIViewAutoresizingFlexibleHeight;
  clickToDismiss.backgroundColor  = [UIColor colorWithWhite: 0 alpha: 0.5];
  [clickToDismiss addTarget: self action: @selector(hideKeyboard) forControlEvents: UIControlEventTouchDown |
   UIControlEventTouchDragInside
   ];
  self.tableView.scrollEnabled = NO;
  [self.view addSubview: clickToDismiss];
}

//FIX ISSUE #50
-(void)searchBarTextDidEndEditing: (UISearchBar *) searchBar
{
  [clickToDismiss removeFromSuperview];
  clickToDismiss               = nil;
  self.tableView.scrollEnabled = YES;
  theSearchTerm = searchBar.text;
  ((PKSettings *)[PKSettings instance]).lastNotesSearch = theSearchTerm;
  [[PKSettings instance] saveSettings];
  if ([theSearchTerm isEqualToString:@""])
  {
    [self reloadNotes];
  }
}

-(void) hideKeyboard
{
  [clickToDismiss removeFromSuperview];
  clickToDismiss               = nil;
  [self becomeFirstResponder];
  self.tableView.scrollEnabled = YES;
  if ([theSearchTerm isEqualToString:@""])
  {
    [self reloadNotes];
  }
}


@end