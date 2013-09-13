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
{
  NSArray */**__strong**/ _notes;
  UILabel */**__strong**/ _noResults;

  NSString */**__strong**/ _theSearchTerm;
  UISearchBar */**__strong**/ _theSearchBar;
  UIButton */**__strong**/ _clickToDismiss;
}

-(void)updateNotesViewAfterSearch
{
  [self.tableView reloadData];
  
  if ([_notes count] == 0)
  {
    _noResults.text = __Tv(@"no-results", @"No results.");
  }
  else
  {
    _noResults.text = @"";
  }

}
-(void)reloadNotes
{
    _notes = [[PKNotes instance] allNotes];
  [self.tableView reloadData];
  if ([_notes count] == 0)
  {
    _noResults.text = __Tv(@"no-notes", @"You don't have any notes.");
  }
  else
  {
    _noResults.text = @"";
  }
  
}

-(id)init
{
  self = [super init];
  
  if (self)
  {
    // Custom initialization
    _theSearchTerm = [[PKSettings instance] lastNotesSearch];

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
  
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKSelectionColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  // add search bar
  _theSearchBar                   = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
  _theSearchBar.delegate          = self;
  _theSearchBar.placeholder       = __T(@"Search Term");
  _theSearchBar.showsCancelButton = NO;
  _theSearchBar.text = _theSearchTerm;
  self.tableView.tableHeaderView = _theSearchBar;

  CGRect theRect = CGRectMake(0, 88, 260, 60);
  _noResults                  = [[UILabel alloc] initWithFrame: theRect];
  _noResults.textColor        = [PKSettings PKTextColor]; //[UIColor whiteColor];
  _noResults.font             = [UIFont fontWithName: [PKSettings interfaceFont] size: 16];
  _noResults.textAlignment    = NSTextAlignmentCenter;
  _noResults.backgroundColor  = [UIColor clearColor];
  _noResults.shadowColor      = [UIColor clearColor];
  _noResults.numberOfLines    = 0;
  [self.view addSubview: _noResults];
  
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  CGFloat topOffset = self.navigationController.navigationBar.frame.size.height;
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) { topOffset = 0; }
  self.tableView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
  //if (SYSTEM_VERSION_LESS_THAN(@"7.0") && !_delegate)
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-topOffset, 0, 0, 0);
}

/**
 *
 * Force our width and then reload our highlights
 *
 */
-(void)viewDidAppear: (BOOL) animated
{
  [super viewDidAppear:animated];
  CGRect newFrame = self.navigationController.view.frame;
  newFrame.size.width                  = 260;
  self.navigationController.view.frame = newFrame;

  if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
  {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    CGFloat topOffset = self.navigationController.navigationBar.frame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
  }

  [self reloadNotes];
  [self updateAppearanceForTheme];
  [self calculateShadows];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  _notes     = nil;
  _noResults = nil;
  
  _theSearchBar = nil;
  _theSearchTerm = nil;
  _clickToDismiss = nil;
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
  return [_notes count];
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
  
  PKReference *theReference = _notes[row];
  
  NSArray *theNoteArray = [[PKNotes instance] getNoteForReference: theReference];
  NSString *theTitle    = theNoteArray[0];
  NSString *theNote     = theNoteArray[1];
  
  cell.textLabel.text                = theTitle;
  cell.textLabel.textColor           = [PKSettings PKSidebarTextColor];
  cell.textLabel.font      = [UIFont fontWithName:[PKSettings boldInterfaceFont] size:16];
  cell.detailTextLabel.text          = theNote;
  cell.detailTextLabel.textColor     = [PKSettings PKSidebarTextColor];
  cell.detailTextLabel.numberOfLines = 4;
  cell.detailTextLabel.font      = [UIFont fontWithName:[PKSettings interfaceFont] size:14];
  [cell.detailTextLabel sizeToFit];
  cell.backgroundColor     = [UIColor clearColor];
  
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
  PKReference *theReference       = _notes[row];
  NSUInteger theBook                = theReference.book;
  NSUInteger theChapter             = theReference.chapter;
  NSUInteger theVerse               = theReference.verse;
  
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
  _theSearchTerm = searchBar.text;
  [PKSettings instance].lastNotesSearch = _theSearchTerm;
  [[PKSettings instance] saveSettings];
  if ([_theSearchTerm isEqualToString:@""])
  {
    [self reloadNotes];
  }
  else
  {
    _notes = [[PKNotes instance] notesMatching:_theSearchTerm];
    [self updateNotesViewAfterSearch];
  }
}

-(void)searchBarTextDidBeginEditing: (UISearchBar *) searchBar
{
  CGRect theRect = self.tableView.frame;
  theRect.origin.y               += 44;
  _clickToDismiss                  = [[UIButton alloc] initWithFrame: theRect];
  _clickToDismiss.autoresizingMask = UIViewAutoresizingFlexibleWidth |
  UIViewAutoresizingFlexibleHeight;
  _clickToDismiss.backgroundColor  = [UIColor colorWithWhite: 0 alpha: 0.5];
  [_clickToDismiss addTarget: self action: @selector(hideKeyboard) forControlEvents: UIControlEventTouchDown |
   UIControlEventTouchDragInside
   ];
  self.tableView.scrollEnabled = NO;
  [self.view addSubview: _clickToDismiss];
}

//FIX ISSUE #50
-(void)searchBarTextDidEndEditing: (UISearchBar *) searchBar
{
  [_clickToDismiss removeFromSuperview];
  _clickToDismiss               = nil;
  self.tableView.scrollEnabled = YES;
  _theSearchTerm = searchBar.text;
  [PKSettings instance].lastNotesSearch = _theSearchTerm;
  [[PKSettings instance] saveSettings];
  if ([_theSearchTerm isEqualToString:@""])
  {
    [self reloadNotes];
  }
}

-(void) hideKeyboard
{
  [_clickToDismiss removeFromSuperview];
  _clickToDismiss               = nil;
  [self becomeFirstResponder];
  self.tableView.scrollEnabled = YES;
  if ([_theSearchTerm isEqualToString:@""])
  {
    [self reloadNotes];
  }
}


@end