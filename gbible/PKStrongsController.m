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
#import "UIFont+Utility.h"

@interface PKStrongsController ()

@end

@implementation PKStrongsController
{
  NSMutableDictionary * __strong _cellHeights;
  NSString * __strong _theSearchTerm;
  NSArray * __strong _theSearchResults;
  UISearchBar * __strong _theSearchBar;
  UIButton * __strong _clickToDismiss;
  UILabel * __strong _noResults;
  UIFont * __strong _theFont;
  UIFont * __strong _theBigFont;
  BOOL _byKeyOnly;
  UIMenuController * __strong _ourMenu;
  NSString * __strong _selectedWord;
  NSUInteger _selectedRow;
}

-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];
  
  if (self)
  {
    // set our title
    [self.navigationItem setTitle: __T(@"Strong's")];
    _theSearchTerm = [[PKSettings instance] lastStrongsLookup];
    _byKeyOnly     = NO;
  }
  return self;
}

-(void)clearCellHeights
{
  _cellHeights = [NSMutableDictionary new];
}

-(void)doSearchForTerm: (NSString *) theTerm
{
  [self clearCellHeights];
  [self doSearchForTerm: theTerm byKeyOnly: _byKeyOnly];
}

-(void)doSearchForTerm: (NSString *) theTerm byKeyOnly: (BOOL) keyOnly
{
  [self clearCellHeights];
  _byKeyOnly = keyOnly;
  [SVProgressHUD showWithStatus:__T(@"Searching...") maskType:SVProgressHUDMaskTypeClear];
  [[PKHistory instance] addStrongsSearch: theTerm];
  [[[PKAppDelegate sharedInstance] historyViewController] reloadHistory];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
         _theSearchResults = nil;
         _theSearchTerm = theTerm;
         
         if ([theTerm isEqualToString: @""])
         {
           _theSearchResults = nil;
         }
         else
         {
           _theSearchResults = [PKStrongs keysThatMatch: theTerm byKeyOnly: keyOnly];
         }
         dispatch_async(dispatch_get_main_queue(),
          ^{
             [SVProgressHUD dismiss];
             [self.tableView reloadData];
             
             _theSearchBar.text = theTerm;
             
             [PKSettings instance].lastStrongsLookup = theTerm;
             
             _byKeyOnly = NO;
             
             if ([_theSearchResults count] == 0)
             {
               _noResults.text = __Tv(@"no-results", @"No results. Please try again.");
             }
             else
             {
               _noResults.text = @"";
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
  
  if (_delegate)
  {
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
  }
  
  // add search bar
  _theSearchBar                   = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
  _theSearchBar.delegate          = self;
  _theSearchBar.placeholder       = __T(@"Strong's # or search term");
  _theSearchBar.showsCancelButton = NO;
  _theSearchBar.text = _theSearchTerm;
  
  if (!_delegate)
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
  
  self.tableView.tableHeaderView    = _theSearchBar;
  
  // add navbar items
  if (!_delegate)
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
  _noResults                      = [[UILabel alloc] initWithFrame: theRect];
  _noResults.textColor            = [PKSettings PKTextColor];
  _noResults.font                 = [UIFont fontWithName: @"Zapfino" size: 15];
  _noResults.textAlignment        = UITextAlignmentCenter;
  _noResults.backgroundColor      = [UIColor clearColor];
  _noResults.shadowColor          = [UIColor whiteColor];
  _noResults.autoresizingMask     = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _noResults.numberOfLines        = 0;
  [self.view addSubview: _noResults];

  if ([_theSearchTerm isEqualToString:@""])
  {
    _noResults.text = __Tv(@"no-search", @"Enter Search Term");
  }
  else
  {
    _noResults.text = __Tv(@"do-search", @"Search to display results");
  }

  
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  
//  [self doSearchForTerm:self.theSearchTerm];
  _theSearchBar.text              = _theSearchTerm;
}

-(void) updateAppearanceForTheme
{
/*  UINavigationController *NC = self.navigationController;
  NC.navigationBar.barStyle = UIBarStyleBlackOpaque;
  NC.navigationBar.tintColor = [PKSettings PKSidebarPageColor];
  [NC.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];*/
  

  // get the font
  _theFont = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                              andSize: [[PKSettings instance] textFontSize]];
  _theBigFont                = [_theFont fontWithSizeDelta:6];
  
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
  _theSearchResults = nil;
  _theSearchTerm    = nil;

  _cellHeights = nil;
  _theSearchBar = nil;
  _clickToDismiss = nil;
  _noResults = nil;
  _theFont = nil;
  _theBigFont = nil;
  _ourMenu = nil;
  _selectedWord = nil;

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
  if (_theSearchResults != nil)
  {
    return [_theSearchResults count];
  }
  else
  {
    return 0;
  }
}

-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row       = [indexPath row];

  if ( [_cellHeights objectForKey:@(row)] )
  {
    return [[_cellHeights objectForKey:@(row)] floatValue];
  }
  
  NSArray *theResult   = [PKStrongs entryForKey: [_theSearchResults objectAtIndex: row]];
  
  CGSize theSize;
  CGFloat theHeight    = 0;
  CGFloat theCellWidth = (self.tableView.bounds.size.width - 30);
  CGSize maxSize       = CGSizeMake(theCellWidth, 300);
  
  theHeight += 10;   // the top margin
  theHeight += _theBigFont.lineHeight;   // the top labels
  
  theSize    = [[theResult objectAtIndex: 1] sizeWithFont: _theFont constrainedToSize: maxSize];
  theHeight += theSize.height + 10;
  
  theSize    =
  [[[theResult objectAtIndex: 3] stringByReplacingOccurrencesOfString: @"  " withString: @" "] sizeWithFont: _theFont
                                                                                          constrainedToSize: maxSize];
  theHeight += theSize.height + 10;
  
  theHeight += 10;

  [_cellHeights setObject:@(theHeight) forKey:@(row)];
  
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
  UILabel *theStrongsLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 10, theColumnWidth, _theBigFont.lineHeight)];
  theStrongsLabel.text            = [_theSearchResults objectAtIndex: row];
  theStrongsLabel.textColor       = [PKSettings PKStrongsColor];
  theStrongsLabel.font            = _theBigFont;
  theStrongsLabel.backgroundColor = [UIColor clearColor];
  
  NSArray *theResult     = [PKStrongs entryForKey: [_theSearchResults objectAtIndex: row]];
  
  UILabel *theLemmaLabel =
  [[UILabel alloc] initWithFrame: CGRectMake(theColumnWidth + 20, 10, theColumnWidth, _theBigFont.lineHeight)];
  theLemmaLabel.text            = [[theResult objectAtIndex: 1] stringByAppendingFormat: @" (%@)", [theResult objectAtIndex: 2]];
  theLemmaLabel.textAlignment   = UITextAlignmentRight;
  theLemmaLabel.textColor       = [PKSettings PKTextColor];
  theLemmaLabel.font            = _theBigFont;
  theLemmaLabel.backgroundColor = [UIColor clearColor];
  
  CGSize maxSize                 = CGSizeMake(theCellWidth, 300);
  
  CGSize theSize                 =
  [[[theResult objectAtIndex: 3] stringByReplacingOccurrencesOfString: @"  " withString: @" "] sizeWithFont: _theFont
                                                                                          constrainedToSize: maxSize];
  PKHotLabel *theDefinitionLabel =
  [[PKHotLabel alloc] initWithFrame: CGRectMake(10, 20 + _theBigFont.lineHeight, theCellWidth, theSize.height)];
  theDefinitionLabel.text               =
  [[theResult objectAtIndex: 3] stringByReplacingOccurrencesOfString: @"  " withString: @" "];
  theDefinitionLabel.textColor          = [PKSettings PKTextColor];
  theDefinitionLabel.font               = _theFont;
  theDefinitionLabel.lineBreakMode      = UILineBreakModeWordWrap;
  theDefinitionLabel.numberOfLines      = 0;
  theDefinitionLabel.backgroundColor    = [UIColor clearColor];
  theDefinitionLabel.hotColor           = [PKSettings PKStrongsColor];
  theDefinitionLabel.hotBackgroundColor = [PKSettings PKSelectionColor];
  theDefinitionLabel.hotWord            = _theSearchTerm;
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
  
  //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
  if (self.view.bounds.size.width>320)
  {
    [cell addSubview: theLemmaLabel];
  }
  [cell addSubview: theDefinitionLabel];
  
  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  if (_ourMenu.isMenuVisible)
  {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    return;
  }
  
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  
  _ourMenu           = [UIMenuController sharedMenuController];
  _ourMenu.menuItems = [NSArray arrayWithObjects:
                       //Issue #61
                       //                            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")         action:@selector(copyStrongs:)],
                       [[UIMenuItem alloc] initWithTitle: __T(@"Define")       action: @selector(defineStrongs:)],
                       [[UIMenuItem alloc] initWithTitle: __T(@"Search Bible") action: @selector(searchBible:)]
                       //                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)]
                       , nil];
  
  NSUInteger row           = [indexPath row];
  _selectedWord = nil;
  _selectedRow  = row;
  UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath: indexPath];
  
  [self becomeFirstResponder];
  [_ourMenu update];   // just in case
  [_ourMenu setTargetRect: theCell.frame inView: self.tableView];
  [_ourMenu setMenuVisible: YES animated: YES];
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
}

-(void) hideKeyboard
{
  [_clickToDismiss removeFromSuperview];
  _clickToDismiss               = nil;
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
    return _selectedWord != nil;
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
  NSMutableString *theText = [[_theSearchResults objectAtIndex: _selectedRow] mutableCopy];
  NSArray *theResult       = [PKStrongs entryForKey: [_theSearchResults objectAtIndex: _selectedRow]];
  
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
  if (_delegate)
  {
    PKStrongsController *svc = [[PKStrongsController alloc] initWithStyle:UITableViewStylePlain];
    svc.delegate = self;
    [svc doSearchForTerm: _selectedWord byKeyOnly: true];
    [self.navigationController pushViewController:svc animated:YES];
  }
  else
  {
    [self doSearchForTerm: _selectedWord byKeyOnly: true];
  }
}

-(void) searchBible: (id) sender
{

  if (_delegate)
  {
    PKSearchViewController *svc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    svc.notifyWithCopyOfVerse = NO;
    svc.delegate = self;
    if (!_selectedRow)
    {
      [svc doSearchForTerm: [NSString stringWithFormat: @"\"%@ \"", [_theSearchResults objectAtIndex: _selectedRow]]];
    }
    else
    {
      [svc doSearchForTerm: [NSString stringWithFormat: @"\"%@ \"", _selectedWord] ];
    }
    
    //UINavigationController *mvnc = [[UINavigationController alloc] initWithRootViewController: svc];
    //mvnc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController pushViewController:svc animated:YES];
    
  }
  else
  {
    PKSearchViewController *svc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    
    if (!_selectedWord)
    {
      NSString *theSVCTerm = [NSString stringWithFormat: @"\"%@ \"", [_theSearchResults objectAtIndex: _selectedRow]];
      [svc doSearchForTerm: theSVCTerm
           requireParsings: YES];
    }
    else
    {
      [svc doSearchForTerm: [NSString stringWithFormat: @"\"%@ \"", _selectedWord] requireParsings: YES];
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
      _ourMenu           = [UIMenuController sharedMenuController];
      _ourMenu.menuItems = [NSArray arrayWithObjects:
                           // ISSUE #61
                           //                            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")         action:@selector(copyStrongs:)],
                           [[UIMenuItem alloc] initWithTitle: __T(@"Define")       action: @selector(defineStrongs:)],
                           [[UIMenuItem alloc] initWithTitle: __T(@"Search Bible") action: @selector(searchBible:)]
                           //                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)]
                           , nil];
      
      if (hotWord)
      {
        // we have a hot word in the cell...
        _selectedWord = hotWord;
        _selectedRow  = row;
      }
      else
      {
        _selectedWord = nil;
        _selectedRow  = row;
      }
      [self becomeFirstResponder];
      [_ourMenu update];       // just in case
      [_ourMenu setTargetRect: CGRectMake(p.x, p.y, 1, 1) inView: self.tableView];
      [_ourMenu setMenuVisible: YES animated: YES];
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
  if (_delegate)
  {
    [self dismissModalViewControllerAnimated: YES];
    [_delegate newReferenceByBook:theBook andChapter:theChapter andVerse:andVerse];
  }
}

-(void)newVerseByBook:(int)theBook andChapter:(int)theChapter andVerse:(int)andVerse
{
  return;
}

@end