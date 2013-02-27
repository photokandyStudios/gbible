//
//  PKStrongsController.m
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
#import "PKStrongsController.h"
#import "PKStrongs.h"
#import "PKSettings.h"
#import "PKHistory.h"
#import "PKAppDelegate.h"
#import "ZUUIRevealController.h"
#import "PKSearchViewController.h"
//#import "PKRootViewController.h"
#import "TestFlight.h"
#import "PKHistoryViewController.h"
#import "SVProgressHUD.h"
#import "PKHotLabel.h"
#import "NSString+FontAwesome.h"

@interface PKStrongsController ()

@property (strong, nonatomic) NSMutableDictionary *cellHeights;

@end

@implementation PKStrongsController
@synthesize theSearchTerm;
@synthesize theSearchResults;
@synthesize theSearchBar;
@synthesize byKeyOnly;
@synthesize clickToDismiss;
@synthesize noResults;
@synthesize theFont;
@synthesize theBigFont;
@synthesize ourMenu;
@synthesize selectedWord;
@synthesize selectedRow;
@synthesize delegate;
@synthesize cellHeights;

-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];
  
  if (self)
  {
    // set our title
    [self.navigationItem setTitle: __T(@"Strong's")];
    self.theSearchTerm = [[PKSettings instance] lastStrongsLookup];
    self.byKeyOnly     = NO;
  }
  return self;
}

-(void)clearCellHeights
{
  cellHeights = [NSMutableDictionary new];
}

-(void)doSearchForTerm: (NSString *) theTerm
{
  [self clearCellHeights];
  [self doSearchForTerm: theTerm byKeyOnly: self.byKeyOnly];
}

-(void)doSearchForTerm: (NSString *) theTerm byKeyOnly: (BOOL) keyOnly
{
  [self clearCellHeights];
  self.byKeyOnly = byKeyOnly;
  [SVProgressHUD showWithStatus:__T(@"Searching...") maskType:SVProgressHUDMaskTypeClear];
  [[PKHistory instance] addStrongsSearch: theTerm];
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
           theSearchResults = [PKStrongs keysThatMatch: theTerm byKeyOnly: keyOnly];
         }
         dispatch_async(dispatch_get_main_queue(),
          ^{
             [SVProgressHUD dismiss];
             [self.tableView reloadData];
             
             theSearchBar.text = theTerm;
             
             ( (PKSettings *)[PKSettings instance] ).lastStrongsLookup = theTerm;
             
             self.byKeyOnly = NO;
             
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
  // Do any additional setup after loading the view.
  [TestFlight passCheckpoint: @"SEARCH_STRONGS"];
  [self clearCellHeights];
  
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
  theSearchBar.placeholder       = __T(@"Strong's # or search term");
  theSearchBar.showsCancelButton = NO;
  theSearchBar.text = theSearchTerm;
  
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
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                             initWithTarget: self action: @selector(didReceiveLongPress:)];
  longPress.minimumPressDuration    = 0.5;
  longPress.numberOfTapsRequired    = 0;
  longPress.numberOfTouchesRequired = 1;
  [self.tableView addGestureRecognizer: longPress];
  
  self.tableView.tableHeaderView    = theSearchBar;
  
  // add navbar items
  if (!delegate)
  {
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

  if ([self.theSearchTerm isEqualToString:@""])
  {
    noResults.text = __Tv(@"no-search", @"Enter Search Term");
  }
  else
  {
    noResults.text = __Tv(@"do-search", @"Search to display results");
  }

  
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  
//  [self doSearchForTerm:self.theSearchTerm];
  theSearchBar.text              = self.theSearchTerm;
}

-(void) updateAppearanceForTheme
{
/*  UINavigationController *NC = self.navigationController;
  NC.navigationBar.barStyle = UIBarStyleBlackOpaque;
  NC.navigationBar.tintColor = [PKSettings PKSidebarPageColor];
  [NC.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];*/
  

  // get the font
  self.theFont = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                 size: [[PKSettings instance] textFontSize]];
  
  if (self.theFont == nil)
  {
    self.theFont = [UIFont fontWithName: [NSString stringWithFormat: @"%@-Regular", [[PKSettings instance] textFontFace]]
                                   size: [[PKSettings instance] textFontSize]];
  }
  
  if (self.theFont == nil)
  {
    self.theFont = [UIFont fontWithName: @"Helvetica"
                                   size: [[PKSettings instance] textFontSize]];
  }
  self.theBigFont                = [UIFont fontWithName: [self.theFont fontName] size: [[PKSettings instance] textFontSize] + 6];
  
  self.tableView.backgroundView  = nil;
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
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
  // Release any retained subviews of the main view.
  theSearchResults = nil;
  theSearchTerm    = nil;
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
  // ISSUE #61
  [self becomeFirstResponder];
}


#pragma mark
#pragma mark Table View Data Source Methods
-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  return 1;
}

-(NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
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
  NSUInteger row       = [indexPath row];

  if ( [cellHeights objectForKey:@(row)] )
  {
    return [[cellHeights objectForKey:@(row)] floatValue];
  }
  
  NSArray *theResult   = [PKStrongs entryForKey: [theSearchResults objectAtIndex: row]];
  
  CGSize theSize;
  CGFloat theHeight    = 0;
  CGFloat theCellWidth = (self.tableView.bounds.size.width - 30);
  CGSize maxSize       = CGSizeMake(theCellWidth, 300);
  
  theHeight += 10;   // the top margin
  theHeight += self.theBigFont.lineHeight;   // the top labels
  
  theSize    = [[theResult objectAtIndex: 1] sizeWithFont: self.theFont constrainedToSize: maxSize];
  theHeight += theSize.height + 10;
  
  theSize    =
  [[[theResult objectAtIndex: 3] stringByReplacingOccurrencesOfString: @"  " withString: @" "] sizeWithFont: self.theFont
                                                                                          constrainedToSize: maxSize];
  theHeight += theSize.height + 10;
  
  theHeight += 10;

  [cellHeights setObject:@(theHeight) forKey:@(row)];
  
  return theHeight;
}

-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *strongsCellID = @"PKStrongsCellID";
  UITableViewCell *cell          = [tableView dequeueReusableCellWithIdentifier: strongsCellID];
  
  if (!cell)
  {
    cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleDefault
            reuseIdentifier: strongsCellID];
  }
  
  // need to remove the cell's subviews, if they exist...
  for (UIView *view in cell.subviews)
  {
    [view removeFromSuperview];
  }
  
  NSUInteger row           = [indexPath row];
  
  CGFloat theCellWidth     = (self.tableView.bounds.size.width - 30);
  CGFloat theColumnWidth   = (theCellWidth) / 2;
  
  // now create the new subviews
  UILabel *theStrongsLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 10, theColumnWidth, theBigFont.lineHeight)];
  theStrongsLabel.text            = [theSearchResults objectAtIndex: row];
  theStrongsLabel.textColor       = [PKSettings PKStrongsColor];
  theStrongsLabel.font            = theBigFont;
  theStrongsLabel.backgroundColor = [UIColor clearColor];
  
  NSArray *theResult     = [PKStrongs entryForKey: [theSearchResults objectAtIndex: row]];
  
  UILabel *theLemmaLabel =
  [[UILabel alloc] initWithFrame: CGRectMake(theColumnWidth + 20, 10, theColumnWidth, theBigFont.lineHeight)];
  theLemmaLabel.text            = [[theResult objectAtIndex: 1] stringByAppendingFormat: @" (%@)", [theResult objectAtIndex: 2]];
  theLemmaLabel.textAlignment   = UITextAlignmentRight;
  theLemmaLabel.textColor       = [PKSettings PKTextColor];
  theLemmaLabel.font            = theBigFont;
  theLemmaLabel.backgroundColor = [UIColor clearColor];
  
  CGSize maxSize                 = CGSizeMake(theCellWidth, 300);
  
  CGSize theSize                 =
  [[[theResult objectAtIndex: 3] stringByReplacingOccurrencesOfString: @"  " withString: @" "] sizeWithFont: theFont
                                                                                          constrainedToSize: maxSize];
  PKHotLabel *theDefinitionLabel =
  [[PKHotLabel alloc] initWithFrame: CGRectMake(10, 20 + theBigFont.lineHeight, theCellWidth, theSize.height)];
  theDefinitionLabel.text               =
  [[theResult objectAtIndex: 3] stringByReplacingOccurrencesOfString: @"  " withString: @" "];
  theDefinitionLabel.textColor          = [PKSettings PKTextColor];
  theDefinitionLabel.font               = theFont;
  theDefinitionLabel.lineBreakMode      = UILineBreakModeWordWrap;
  theDefinitionLabel.numberOfLines      = 0;
  theDefinitionLabel.backgroundColor    = [UIColor clearColor];
  theDefinitionLabel.hotColor           = [PKSettings PKStrongsColor];
  theDefinitionLabel.hotBackgroundColor = [PKSettings PKSelectionColor];
  theDefinitionLabel.hotWord            = theSearchTerm;
  theDefinitionLabel.hotComparator      = ^(NSString * theWord) {
    if ([theWord length] > 1)
    {
      return (BOOL)([[theWord substringToIndex: 1] isEqualToString: @"G"]
                    && [[theWord substringFromIndex: 1] intValue] > 0);
    }
    else
    {
      return NO;
    }
  };
  theDefinitionLabel.delegate               = self;
  theDefinitionLabel.userInteractionEnabled = YES;
  
  [cell addSubview: theStrongsLabel];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
  {
    [cell addSubview: theLemmaLabel];
  }
  [cell addSubview: theDefinitionLabel];
  
  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  if (ourMenu.isMenuVisible)
  {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    return;
  }
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  
  ourMenu           = [UIMenuController sharedMenuController];
  ourMenu.menuItems = [NSArray arrayWithObjects:
                       //Issue #61
                       //                            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")         action:@selector(copyStrongs:)],
                       [[UIMenuItem alloc] initWithTitle: __T(@"Define")       action: @selector(defineStrongs:)],
                       [[UIMenuItem alloc] initWithTitle: __T(@"Search Bible") action: @selector(searchBible:)]
                       //                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)]
                       , nil];
  
  NSUInteger row           = [indexPath row];
  selectedWord = nil;
  selectedRow  = row;
  UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath: indexPath];
  
  [self becomeFirstResponder];
  [ourMenu update];   // just in case
  [ourMenu setTargetRect: theCell.frame inView: self.tableView];
  [ourMenu setMenuVisible: YES animated: YES];
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

/**
 *
 * Determine what actions can occur when a menu is displayed.
 *
 */
-(BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
  //    if (action == @selector(copyStrongs:))        { return YES; }
  // ISSUE #61
  if ( action == @selector(copy:) )
  {
    return YES;
  }
  
  if ( action == @selector(searchBible:) )
  {
    return YES;
  }
  
  if ( action == @selector(defineStrongs:) )
  {
    return selectedWord != nil;
  }
  return NO;
}

// ISSUE #61
-(void) copy: (id) sender
{
  [self copyStrongs: nil];
}

-(void) copyStrongs: (id) sender
{
  NSMutableString *theText = [[theSearchResults objectAtIndex: selectedRow] mutableCopy];
  NSArray *theResult       = [PKStrongs entryForKey: [theSearchResults objectAtIndex: selectedRow]];
  
  [theText appendFormat: @"\n%@: %@\n%@: %@\n%@: %@", // ISSUE #62
   __T(@"Lemma"),         [theResult objectAtIndex: 1],
   __T(@"Pronunciation"), [theResult objectAtIndex: 2],
   __T(@"Definition"),    [theResult objectAtIndex: 3]
   ];
  
  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  pasteBoard.string = theText;
}

-(void) defineStrongs: (id) sender
{
  if (delegate)
  {
    PKStrongsController *svc = [[PKStrongsController alloc] initWithStyle:UITableViewStylePlain];
    svc.delegate = self;
    [svc doSearchForTerm: selectedWord byKeyOnly: true];
    [self.navigationController pushViewController:svc animated:YES];
  }
  else
  {
    [self doSearchForTerm: selectedWord byKeyOnly: true];
  }
}

-(void) searchBible: (id) sender
{

  if (delegate)
  {
    PKSearchViewController *svc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    svc.notifyWithCopyOfVerse = NO;
    svc.delegate = self;
    if (!selectedRow)
    {
      [svc doSearchForTerm: [NSString stringWithFormat: @"\"%@ \"", [theSearchResults objectAtIndex: selectedRow]]];
    }
    else
    {
      [svc doSearchForTerm: [NSString stringWithFormat: @"\"%@ \"", selectedWord] ];
    }
    
    //UINavigationController *mvnc = [[UINavigationController alloc] initWithRootViewController: svc];
    //mvnc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController pushViewController:svc animated:YES];
    
  }
  else
  {
    PKSearchViewController *svc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    
    if (!selectedWord)
    {
      NSString *theSVCTerm = [NSString stringWithFormat: @"\"%@ \"", [theSearchResults objectAtIndex: selectedRow]];
      [svc doSearchForTerm: theSVCTerm
           requireParsings: YES];
    }
    else
    {
      [svc doSearchForTerm: [NSString stringWithFormat: @"\"%@ \"", selectedWord] requireParsings: YES];
    }
    
    [[PKAppDelegate sharedInstance].bibleViewController.navigationController pushViewController:svc animated:YES];
  }
}

-(void) didReceiveLongPress: (UILongPressGestureRecognizer *) gestureRecognizer
{
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
  {
    CGPoint p              = [gestureRecognizer locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: p];    // nil if no row
    
    if (indexPath != nil)
    {
      NSUInteger row           = [indexPath row];
      
      UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath: indexPath];
      NSArray *theSubViews     = [theCell subviews];
      PKHotLabel *ourLabel     = (PKHotLabel *)[theSubViews lastObject];
      
      CGPoint wp               = [gestureRecognizer locationInView: ourLabel];
      NSString *hotWord        = [ourLabel wordFromPoint: wp];
      ourMenu           = [UIMenuController sharedMenuController];
      ourMenu.menuItems = [NSArray arrayWithObjects:
                           // ISSUE #61
                           //                            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")         action:@selector(copyStrongs:)],
                           [[UIMenuItem alloc] initWithTitle: __T(@"Define")       action: @selector(defineStrongs:)],
                           [[UIMenuItem alloc] initWithTitle: __T(@"Search Bible") action: @selector(searchBible:)]
                           //                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)]
                           , nil];
      
      if (hotWord)
      {
        // we have a hot word in the cell...
        selectedWord = hotWord;
        selectedRow  = row;
      }
      else
      {
        selectedWord = nil;
        selectedRow  = row;
      }
      [self becomeFirstResponder];
      [ourMenu update];       // just in case
      [ourMenu setTargetRect: CGRectMake(p.x, p.y, 1, 1) inView: self.tableView];
      [ourMenu setMenuVisible: YES animated: YES];
    }
  }
}

-(void) closeMe: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
}


#pragma mark -
#pragma mark Hot Label Delegate; this is essentially dead code

-(void) label: (PKHotLabel *) label didTapWord: (NSString *) theWord
{
  // search for the selected word
  [self doSearchForTerm: theWord byKeyOnly: true];
}

#pragma mark -
#pragma mark Bible Reference Delegate
-(void)newReferenceByBook:(int)theBook andChapter:(int)theChapter andVerse:(int)andVerse
{
  if (delegate)
  {
    [self dismissModalViewControllerAnimated: YES];
    [delegate newReferenceByBook:theBook andChapter:theChapter andVerse:andVerse];
  }
}

-(void)newVerseByBook:(int)theBook andChapter:(int)theChapter andVerse:(int)andVerse
{
  return;
}

@end