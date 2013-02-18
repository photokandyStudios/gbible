//
//  PKSearchViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKSearchViewController.h"
#import "PKSettings.h"
#import "PKBible.h"
#import "PKAppDelegate.h"
#import "ZUUIRevealController.h"
//#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKHotLabel.h"
#import "PKHistory.h"
#import "PKHistoryViewController.h"
#import "TestFlight.h"
#import "SVProgressHUD.h"
#import "NSString+FontAwesome.h"

@interface PKSearchViewController ()

@end

@implementation PKSearchViewController

@synthesize theSearchBar;
@synthesize theSearchTerm;
@synthesize theSearchResults;
@synthesize clickToDismiss;
@synthesize noResults;
@synthesize fontSize;
@synthesize leftFont;
@synthesize rightFont;
@synthesize delegate;
@synthesize notifyWithCopyOfVerse;

-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];
  
  if (self)
  {
    // Custom initialization
    [self.navigationItem setTitle: __T(@"Search")];
    self.theSearchTerm = [[PKSettings instance] lastSearch];
  }
  return self;
}

-(void)doSearchForTerm: (NSString *) theTerm
{
  [self doSearchForTerm: theTerm requireParsings: NO];
}

-(void)doSearchForTerm: (NSString *) theTerm requireParsings: (BOOL) parsings
{
  [SVProgressHUD showWithStatus:__T(@"Searching...") maskType:SVProgressHUDMaskTypeClear];
  [[PKHistory instance] addBibleSearch: theTerm];
  [[[PKAppDelegate sharedInstance] historyViewController] reloadHistory];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
        ^{

           theSearchResults = nil;
           theSearchTerm = theTerm;
           
           if ([theTerm isEqualToString: @""])
           {
             theSearchResults = nil;
           }
           else
           {
             theSearchResults = [PKBible passagesMatching: theTerm requireParsings: parsings];
           }
          
           dispatch_async(dispatch_get_main_queue(),
            ^{
               [SVProgressHUD dismiss];
               [self.tableView reloadData];
               
               theSearchBar.text = theTerm;
               
               ( (PKSettings *)[PKSettings instance] ).lastSearch = theTerm;
              
               if ([theSearchResults count] == 0)
               {
                 noResults.text = __Tv(@"no-results", @"No results. Please try again.");
               }
               else
               {
                 noResults.text = @"";
               }
             }
           );


         }
      );
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  [TestFlight passCheckpoint: @"SEARCH_BIBLE"];
  
  if (delegate)
  {
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
  }

  // add search bar
  theSearchBar                   = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
  theSearchBar.delegate          = self;
  theSearchBar.placeholder       = __T(@"Search Term");
  theSearchBar.showsCancelButton = NO;
  
  self.tableView.tableHeaderView = theSearchBar;
  
  if (!delegate)
  {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget: self action: @selector(didReceiveRightSwipe:)];
    UISwipeGestureRecognizer *swipeLeft  = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget: self action: @selector(didReceiveLeftSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
    [swipeRight setNumberOfTouchesRequired: 1];
    [swipeLeft setNumberOfTouchesRequired: 1];
    [self.tableView addGestureRecognizer: swipeRight];
    [self.tableView addGestureRecognizer: swipeLeft];
  }
  
  if (!delegate)
  {
    // add navbar items
  /*UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                 initWithTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-reorder"]
                                         style: UIBarButtonItemStylePlain target: [PKAppDelegate sharedInstance].rootViewController action: @selector(revealToggle:)];
  [changeReference setTitleTextAttributes: @{ UITextAttributeFont : [UIFont fontWithName: kFontAwesomeFamilyName size: 22],
                                         UITextAttributeTextColor : [UIColor whiteColor],
                                         UITextAttributeTextShadowColor: [UIColor clearColor] }
              forState:UIControlStateNormal];
  [changeReference setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  changeReference.accessibilityLabel = __T(@"Go to passage");
  changeReference.tag=498;
    self.navigationItem.leftBarButtonItem = changeReference;*/
  }
  CGRect theRect = CGRectMake(0, self.tableView.center.y + 60, self.tableView.bounds.size.width, 60);
  noResults                      = [[UILabel alloc] initWithFrame: theRect];
  noResults.textColor            = [PKSettings PKTextColor];
  noResults.font                 = [UIFont fontWithName: @"Zapfino" size: 15];
  noResults.textAlignment        = UITextAlignmentCenter;
  noResults.backgroundColor      = [UIColor clearColor];
  noResults.shadowColor          = [UIColor whiteColor];
  noResults.autoresizingMask     = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  noResults.numberOfLines        = 0;
  [self.view addSubview: noResults];
  
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  //[self doSearchForTerm: self.theSearchTerm];
}

-(void) updateAppearanceForTheme
{
  self.fontSize = [[PKSettings instance] textFontSize];
  // get the font
  UIFont *theFont = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                    size: [[PKSettings instance] textFontSize]];
  
  if (theFont == nil)
  {
    theFont = [UIFont fontWithName: [NSString stringWithFormat: @"%@-Regular", [[PKSettings instance] textFontFace]]
                              size: [[PKSettings instance] textFontSize]];
  }
  
  if (theFont == nil)
  {
    theFont = [UIFont fontWithName: @"Helvetica"
                              size: [[PKSettings instance] textFontSize]];
  }
  UIFont *theBoldFont = [UIFont fontWithName: [[PKSettings instance] textGreekFontFace]
                                        size: [[PKSettings instance] textFontSize]];
  
  if (theBoldFont == nil)
  {
    theBoldFont = [UIFont fontWithName: [NSString stringWithFormat: @"%@-Regular", [[PKSettings instance] textGreekFontFace]]
                                  size: [[PKSettings instance] textFontSize]];
  }
  
  if (theBoldFont == nil)       // just in case there's no alternate
  {
    theBoldFont = theFont;
  }
  self.rightFont                 = theFont;
  self.leftFont                  = theBoldFont;
  
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  self.tableView.rowHeight       = 100;
  [self.tableView reloadData];
}

-(void)viewWillAppear: (BOOL) animated
{
  // reload the search? TODO
  [self updateAppearanceForTheme];
}

-(void)viewDidUnload
{
  [super viewDidUnload];
  theSearchResults = nil;
  theSearchTerm    = nil;
  clickToDismiss   = nil;
  noResults        = nil;
}

-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
  [self calculateShadows];
  [self.tableView reloadData];
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

-(BOOL)canBecomeFirstResponder
{
  return YES;
}


-(void) viewDidAppear: (BOOL) animated
{
  [super viewDidAppear: animated];
  [self calculateShadows];
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
  if (theSearchResults != nil)
  {
    return [theSearchResults count];
  }
  else
  {
    return 0;
  }
}

-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row         = [indexPath row];
  
  NSString *thePassage   = [theSearchResults objectAtIndex: row];
  int theBook            = [PKBible bookFromString: thePassage];
  int theChapter         = [PKBible chapterFromString: thePassage];
  int theVerse           = [PKBible verseFromString: thePassage];
  
  CGFloat theCellWidth   = (self.tableView.bounds.size.width);
  CGFloat theColumnWidth = (theCellWidth) / 2;
  CGSize maxSize         = CGSizeMake(theColumnWidth - 40, 100000);
  
  CGSize theLeftSize;
  CGSize theRightSize;
  CGFloat theHeight = 0;
  
  theHeight  += 10;  // the top margin
  
  theLeftSize = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                  [PKBible nameForBook: theBook],
                  theChapter,
                  [PKBible getTextForBook: theBook
                               forChapter: theChapter
                                 forVerse: theVerse
                                  forSide: 1]] sizeWithFont: self.leftFont
                 constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
  
  theRightSize = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                   [PKBible nameForBook: theBook],
                   theChapter,
                   [PKBible getTextForBook: theBook
                                forChapter: theChapter
                                  forVerse: theVerse
                                   forSide: 2]] sizeWithFont: self.rightFont
                  constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
  
  theHeight += MAX(theLeftSize.height, theRightSize.height) + 10;
  
  return theHeight;
}

-(UITableViewCell *)tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *searchCellID = @"PKSearchCellID";
  UITableViewCell *cell         = [tableView dequeueReusableCellWithIdentifier: searchCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleDefault
            reuseIdentifier: searchCellID];
  }
  
  // need to remove the cell's subviews, if they exist...
  for (UIView *view in cell.subviews)
  {
    [view removeFromSuperview];
  }
  
  NSUInteger row         = [indexPath row];
  
  NSString *thePassage   = [theSearchResults objectAtIndex: row];
  int theBook            = [PKBible bookFromString: thePassage];
  int theChapter         = [PKBible chapterFromString: thePassage];
  int theVerse           = [PKBible verseFromString: thePassage];
  
  CGFloat theCellWidth   = (self.tableView.bounds.size.width);
  CGFloat theColumnWidth = (theCellWidth) / 2;
  CGSize maxSize         = CGSizeMake(theColumnWidth - 40, 100000);
  
  CGSize theLeftSize     = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                             [PKBible nameForBook: theBook],
                             theChapter,
                             [PKBible getTextForBook: theBook
                                          forChapter: theChapter
                                            forVerse: theVerse
                                             forSide: 1]] sizeWithFont: self.leftFont
                            constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
  
  CGSize theRightSize = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                          [PKBible nameForBook: theBook],
                          theChapter,
                          [PKBible getTextForBook: theBook
                                       forChapter: theChapter
                                         forVerse: theVerse
                                          forSide: 2]] sizeWithFont: self.rightFont
                         constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
  
  // now create the new subviews
  PKHotLabel *theLeftSide = [[PKHotLabel alloc] initWithFrame: CGRectMake(20, 10, theColumnWidth - 40, theLeftSize.height)];
  theLeftSide.hotColor = [PKSettings PKStrongsColor];
  theLeftSide.hotWord  = self.theSearchTerm;
  theLeftSide.text     = [NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                          [PKBible nameForBook: theBook],
                          theChapter,
                          [PKBible getTextForBook: theBook
                                       forChapter: theChapter
                                         forVerse: theVerse
                                          forSide: 1]];
  theLeftSide.textColor          = [PKSettings PKTextColor];
  theLeftSide.hotBackgroundColor = [PKSettings PKSelectionColor];
  theLeftSide.numberOfLines      = 0;
  theLeftSide.backgroundColor    = [UIColor clearColor];
  theLeftSide.font               = self.leftFont;
  
  PKHotLabel *theRightSide =
  [[PKHotLabel alloc] initWithFrame: CGRectMake(theColumnWidth + 20, 10, theColumnWidth - 40, theRightSize.height)];
  theRightSide.hotColor           = [PKSettings PKStrongsColor];
  theRightSide.hotBackgroundColor = [PKSettings PKSelectionColor];
  theRightSide.hotWord            = self.theSearchTerm;
  theRightSide.text               = [NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                                     [PKBible nameForBook: theBook],
                                     theChapter,
                                     [PKBible getTextForBook: theBook
                                                  forChapter: theChapter
                                                    forVerse: theVerse
                                                     forSide: 2]];
  
  theRightSide.textColor       = [PKSettings PKTextColor];
  theRightSide.numberOfLines   = 0;
  theRightSide.backgroundColor = [UIColor clearColor];
  theRightSide.font            = self.rightFont;
  
  [cell addSubview: theLeftSide];
  [cell addSubview: theRightSide];
  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row             = [indexPath row];
  
  NSString *thePassage       = [theSearchResults objectAtIndex: row];
  int theBook                = [PKBible bookFromString: thePassage];
  int theChapter             = [PKBible chapterFromString: thePassage];
  int theVerse               = [PKBible verseFromString: thePassage];

  if (delegate)
  {
    if (notifyWithCopyOfVerse)
    {
      [delegate newVerseByBook:theBook andChapter:theChapter andVerse:theVerse];
    }
    else
    {
      [delegate newReferenceByBook:theBook andChapter:theChapter andVerse:theVerse];
    }
    [self dismissModalViewControllerAnimated: YES];
  }
  else
  {
    [[PKAppDelegate sharedInstance].bibleViewController displayBook: theBook andChapter: theChapter andVerse: theVerse];
  }
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark -
#pragma mark Searching
-(void)searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
  [self hideKeyboard];
  [self doSearchForTerm: searchBar.text];
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
}

-(void) hideKeyboard
{
  [clickToDismiss removeFromSuperview];
  clickToDismiss               = nil;
  [self becomeFirstResponder];
  self.tableView.scrollEnabled = YES;
}

-(void) didReceiveRightSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  CGPoint p = [gestureRecognizer locationInView: self.tableView];
  
  if (p.x < 75)
  {
    // show the sidebar, if not visible
    ZUUIRevealController *rc = [PKAppDelegate sharedInstance].rootViewController;
    
    if ([rc currentFrontViewPosition] == FrontViewPositionLeft)
    {
      [rc revealToggle: nil];
      return;
    }
  }
}

-(void) didReceiveLeftSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  // hide the sidebar, if visible
    ZUUIRevealController *rc = [PKAppDelegate sharedInstance].rootViewController;
  
  if ([rc currentFrontViewPosition] == FrontViewPositionRight)
  {
    [rc revealToggle: nil];
    return;
  }
}


-(void) closeMe: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
}


@end