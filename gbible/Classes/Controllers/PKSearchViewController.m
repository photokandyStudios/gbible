//
//  PKSearchViewController.m
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
#import "PKReference.h"
#import "UIFont+Utility.h"

@interface PKSearchViewController ()

@end

@implementation PKSearchViewController
{
  // FIX ISSUE #75
  NSMutableDictionary * /**__strong**/ _cellHeights;

  NSString * /**__strong**/ _theSearchTerm;
  NSArray * /**__strong**/ _theSearchResults;
  UISearchBar * /**__strong**/ _theSearchBar;
  UIButton * /**__strong**/ _clickToDismiss;
  UILabel * /**__strong**/ _noResults;
  int _fontSize;
  UIFont * /**__strong**/ _leftFont;
  UIFont * /**__strong**/ _rightFont;
}

-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];
  
  if (self)
  {
    // Custom initialization
    [self.navigationItem setTitle: __T(@"Search")];
    _theSearchTerm = [[PKSettings instance] lastSearch];
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
  [self doSearchForTerm: theTerm requireParsings: NO];
}

-(void)doSearchForTerm: (NSString *) theTerm requireParsings: (BOOL) parsings
{
  [self clearCellHeights];
  [SVProgressHUD showWithStatus:__T(@"Searching...") maskType:SVProgressHUDMaskTypeClear];
  [[PKHistory instance] addBibleSearch: theTerm];
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
             _theSearchResults = [PKBible passagesMatching: theTerm requireParsings: parsings];
           }
          
           dispatch_async(dispatch_get_main_queue(),
            ^{
               [SVProgressHUD dismiss];
               [self.tableView reloadData];
               
               _theSearchBar.text = theTerm;
               
               [PKSettings instance].lastSearch = theTerm;
              
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
  _theSearchBar.placeholder       = __T(@"Search Term");
  _theSearchBar.showsCancelButton = NO;
  _theSearchBar.text = _theSearchTerm;
  
  
  self.tableView.tableHeaderView = _theSearchBar;
  
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
  
  if (!_delegate)
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
  
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  
  //[self doSearchForTerm: self.theSearchTerm];
}

-(void) updateAppearanceForTheme
{
  _fontSize = [[PKSettings instance] textFontSize];
  // get the font
  UIFont *theFont = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                 andSize: [[PKSettings instance] textFontSize]];
  
  UIFont *theBoldFont = [UIFont fontWithName: [[PKSettings instance] textGreekFontFace]
                                     andSize: [[PKSettings instance] textFontSize]];
  
  if (theBoldFont == nil)       // just in case there's no alternate
  {
    theBoldFont = theFont;
  }
  _rightFont                 = theFont;
  _leftFont                  = theBoldFont;
  
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
  _theSearchResults = nil;
  _theSearchTerm    = nil;
  _clickToDismiss   = nil;
  _noResults        = nil;
  _cellHeights = nil;
  _theSearchBar = nil;
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
  NSUInteger row         = [indexPath row];
  
  if ( _cellHeights[@(row)] )
  {
    return [_cellHeights[@(row)] floatValue];
  }
  
  
  PKReference *theReference   = _theSearchResults[row];
  int theBook            = theReference.book;
  int theChapter         = theReference.chapter;
  int theVerse           = theReference.verse;
  
  CGFloat theCellWidth   = (self.tableView.bounds.size.width);
    CGFloat theHeight = 0;
  
  if (theCellWidth > 320)
  {
    CGFloat theColumnWidth = (theCellWidth) / 2;
    CGSize maxSize         = CGSizeMake(theColumnWidth - 40, 100000);
    
    CGSize theLeftSize;
    CGSize theRightSize;
    
    theHeight  += 10;  // the top margin
    
    theLeftSize = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                    [PKBible nameForBook: theBook],
                    theChapter,
                    [PKBible getTextForBook: theBook
                                 forChapter: theChapter
                                   forVerse: theVerse
                                    forSide: 1]] sizeWithFont: _leftFont
                   constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
    
    theRightSize = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                     [PKBible nameForBook: theBook],
                     theChapter,
                     [PKBible getTextForBook: theBook
                                  forChapter: theChapter
                                    forVerse: theVerse
                                     forSide: 2]] sizeWithFont: _rightFont
                    constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
    
    theHeight += MAX(theLeftSize.height, theRightSize.height) + 10;
  }
  else
  {
    UIFont *theHeadingFont = [_leftFont fontWithSizeDeltaPercent:1.25];
    theHeight = 40 + [@"M" sizeWithFont: theHeadingFont].height + [@"M" sizeWithFont: _leftFont].height*2 + + [@"M" sizeWithFont: _rightFont].height*2;
  }
  _cellHeights[@(row)] = @(theHeight);
  
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
  
  PKReference *theReference   = _theSearchResults[row];
  int theBook            = theReference.book;
  int theChapter         = theReference.chapter;
  int theVerse           = theReference.verse;
  
  CGFloat theCellWidth   = (self.tableView.bounds.size.width);
  if (theCellWidth>320)
  {
  
    CGFloat theColumnWidth = (theCellWidth) / 2;
    CGSize maxSize         = CGSizeMake(theColumnWidth - 40, 100000);
    
    CGSize theLeftSize     = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                               [PKBible nameForBook: theBook],
                               theChapter,
                               [PKBible getTextForBook: theBook
                                            forChapter: theChapter
                                              forVerse: theVerse
                                               forSide: 1]] sizeWithFont: _leftFont
                              constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
    
    CGSize theRightSize = [[NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                            [PKBible nameForBook: theBook],
                            theChapter,
                            [PKBible getTextForBook: theBook
                                         forChapter: theChapter
                                           forVerse: theVerse
                                            forSide: 2]] sizeWithFont: _rightFont
                           constrainedToSize: maxSize lineBreakMode: NSLineBreakByWordWrapping];
    
    // now create the new subviews
    PKHotLabel *theLeftSide = [[PKHotLabel alloc] initWithFrame: CGRectMake(20, 10, theColumnWidth - 40, theLeftSize.height)];
    theLeftSide.text     = [NSString stringWithFormat: @"%@ %i:%@\n\n\n", //ISSUE #63
                            [PKBible nameForBook: theBook],
                            theChapter,
                            [PKBible getTextForBook: theBook
                                         forChapter: theChapter
                                           forVerse: theVerse
                                            forSide: 1]];
    theLeftSide.hotColor = [PKSettings PKStrongsColor];
    theLeftSide.hotWord  = _theSearchTerm;
    theLeftSide.textColor          = [PKSettings PKTextColor];
    theLeftSide.hotBackgroundColor = [PKSettings PKSelectionColor];
    theLeftSide.numberOfLines      = 0;
    theLeftSide.backgroundColor    = [UIColor clearColor];
    theLeftSide.font               = _leftFont;
    
    PKHotLabel *theRightSide =
    [[PKHotLabel alloc] initWithFrame: CGRectMake(theColumnWidth + 20, 10, theColumnWidth - 40, theRightSize.height)];
    theRightSide.hotColor           = [PKSettings PKStrongsColor];
    theRightSide.hotBackgroundColor = [PKSettings PKSelectionColor];
    theRightSide.hotWord            = _theSearchTerm;
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
    theRightSide.font            = _rightFont;
    
    [cell addSubview: theLeftSide];
    [cell addSubview: theRightSide];
  }
  else
  {
    UIFont *theHeadingFont = [_leftFont fontWithSizeDeltaPercent:1.25];
    UILabel *theReference = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, theCellWidth-20, [@"M" sizeWithFont: theHeadingFont].height)];
    
    PKHotLabel *theTopText = [[PKHotLabel alloc] initWithFrame:CGRectMake(10, 20 + [@"M" sizeWithFont: theHeadingFont].height,
                                                                          theCellWidth-20,
                                                                          [@"M" sizeWithFont: _leftFont].height*2)];
    PKHotLabel *theBottomText=[[PKHotLabel alloc] initWithFrame:CGRectMake(10, 30 + [@"M" sizeWithFont: theHeadingFont].height + [@"M" sizeWithFont: _leftFont].height*2,
    theCellWidth-20, [@"M" sizeWithFont: _rightFont].height*2)];
    
    
    
    theReference.font = theHeadingFont;
    theReference.text = [NSString stringWithFormat:@"%@ %i:%i", [PKBible nameForBook:theBook], theChapter, theVerse];
    theReference.textColor          = [PKSettings PKTextColor];
    theReference.backgroundColor    = [UIColor clearColor];
    
    theTopText.font = _leftFont;
    theTopText.hotColor = [PKSettings PKStrongsColor];
    theTopText.hotWord  = _theSearchTerm;
    theTopText.hotBackgroundColor = [PKSettings PKSelectionColor];
    theTopText.numberOfLines      = 0;
    theTopText.textColor          = [PKSettings PKTextColor];
    theTopText.backgroundColor    = [UIColor clearColor];
    theTopText.text = [PKBible getTextForBook: theBook
                                         forChapter: theChapter
                                           forVerse: theVerse
                                            forSide: 1];
    
    theBottomText.font = _rightFont;
    theBottomText.hotColor = [PKSettings PKStrongsColor];
    theBottomText.hotWord  = _theSearchTerm;
    theBottomText.hotBackgroundColor = [PKSettings PKSelectionColor];
    theBottomText.numberOfLines      = 0;
    theBottomText.textColor          = [PKSettings PKTextColor];
    theBottomText.backgroundColor    = [UIColor clearColor];
    theBottomText.text = [PKBible getTextForBook: theBook
                                         forChapter: theChapter
                                           forVerse: theVerse
                                            forSide: 2];
    [cell addSubview:theReference];
    [cell addSubview:theTopText];
    [cell addSubview:theBottomText];
  }
  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row             = [indexPath row];
  
  PKReference *theReference   = _theSearchResults[row];
  int theBook            = theReference.book;
  int theChapter         = theReference.chapter;
  int theVerse           = theReference.verse;

  if (_delegate)
  {
    if (_notifyWithCopyOfVerse)
    {
      [_delegate newVerseByBook:theBook andChapter:theChapter andVerse:theVerse];
    }
    else
    {
      [_delegate newReferenceByBook:theBook andChapter:theChapter andVerse:theVerse];
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


-(void) closeMe: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
}


@end