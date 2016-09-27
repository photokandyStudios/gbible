//
//  PKBibleViewController.m
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
#import "PKBibleViewController.h"
#import "PKBible.h"
#import "PKSettings.h"
#import "PKConstants.h"
#import "PKHighlights.h"
#import "PKHighlightsViewController.h"
#import "PKAppDelegate.h"
#import "SegmentsController.h"
#import "PKNoteEditorViewController.h"
#import "PKStrongsController.h"
#import "ZUUIRevealController.h"
//#import "PKRootViewController.h"
#import "PKSearchViewController.h"
#import "PKHistoryViewController.h"
#import "PKHistory.h"
#import "PKNotes.h"
#import "TSMiniWebBrowser.h"
#import "PKTableViewCell.h"
#import "PKLabel.h"
#import "NSString+FontAwesome.h"
#import <QuartzCore/QuartzCore.h>
#import "PKLayoutController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "PKPortraitNavigationController.h"
//#import "FWTPopoverView.h"
#import "PKStrongs.h"
#import "SVProgressHUD.h"
#import "PKSettingsController.h"
#import "UIBarButtonItem+Utility.h"
#import "PKReference.h"
#import "UIFont+Utility.h"
#import "UIImage+PKUtility.h"
#import "NSObject+PKGCD.h"
#import "NSString+PKFont.h"
//#import "GTScrollNavigationBar.h"
#import "gbible-Swift.h"

@import SafariServices;


@interface PKBibleViewController ()
  @property (strong, nonatomic, readwrite) UIView *inputView;
@end

@implementation PKBibleViewController
{
  NSArray * /**__strong**/ _currentGreekChapter;
  NSArray * /**__strong**/ _currentEnglishChapter;

  NSMutableArray * /**__strong**/ _formattedGreekChapter;
  NSMutableArray * /**__strong**/ _formattedEnglishChapter;

  NSMutableArray * /**__strong**/ _formattedGreekVerseHeights;
  NSMutableArray * /**__strong**/ _formattedEnglishVerseHeights;

  NSMutableDictionary * /**__strong**/ _selectedVerses;
  NSMutableDictionary * /**__strong**/ _highlightedVerses;

  NSString * /**__strong**/ _selectedWord;
  PKReference * /**__strong**/ _selectedPassage;

  NSMutableArray * /**__strong**/ _cellHeights;     // RE: ISSUE #1
  NSMutableArray * /**__strong**/ _cells;           // RE: ISSUE #1

  // UI elements
  UIBarButtonItem * /**__strong**/ _changeHighlight;
  NSMutableArray * /**__strong**/ _formattedCells;
  UIMenuController * /**__strong**/ _ourMenu;
  int _ourMenuState;
  UIActionSheet * /**__strong**/ _ourPopover;

  UIButton * /**__strong**/ _btnRegularScreen;

  UILabel * /**__strong**/ _tableTitle;

  int _theWordTag;
  int _theWordIndex;

  UIButton * /**__strong**/ _previousChapterButton;
  UIButton * /**__strong**/ _nextChapterButton;

  UIPopoverController * /**__strong**/ _PO;
  //@property (strong, nonatomic) FWTPopoverView *popoverView;


  UIBarButtonItem * /**__strong**/ _leftTextSelect;
  UIBarButtonItem * /**__strong**/ _rightTextSelect;
  NSArray * /**__strong**/ _bibleTextIDs;

  UITextField * /**__strong**/ _keyboardControl;


  UIDeviceOrientation _lastKnownOrientation;
  int _reusableLabelQueuePosition;
  UIBarButtonItem * /**__strong**/ _searchText;
}


#pragma mark -
#pragma mark Network Connectivity
/*
   from:http://stackoverflow.com/a/7934636/741043
   Connectivity testing code pulled from Apple's Reachability Example:
      http://developer.apple.com/library/ios/#samplecode/Reachability
 */
+(BOOL)hasConnectivity
{
  struct sockaddr_in zeroAddress;
  bzero( &zeroAddress, sizeof(zeroAddress) );
  zeroAddress.sin_len    = sizeof(zeroAddress);
  zeroAddress.sin_family = AF_INET;

  SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                                                                 (const struct sockaddr *)&zeroAddress);

  if (reachability != NULL)
  {
    //NetworkStatus retVal = NotReachable;
    SCNetworkReachabilityFlags flags;

    if ( SCNetworkReachabilityGetFlags(reachability, &flags) )
    {
      if ( (flags & kSCNetworkReachabilityFlagsReachable) == 0 )
      {
        // if target host is not reachable
        return NO;
      }

      if ( (flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0 )
      {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        return YES;
      }

      if ( ( ( (flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 )
             || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0 ) )
      {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs

        if ( (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0 )
        {
          // ... and no [user] intervention is needed
          return YES;
        }
      }

      if ( (flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN )
      {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        return YES;
      }
    }
  }

  return NO;
}

#pragma mark -
#pragma mark Content Loading and Display

/**
 *
 * Display the desired book, chapter, and verse. Typically called from the side-bar navigation
 *
 */
-(void)displayBook: (NSUInteger) theBook andChapter: (NSUInteger) theChapter andVerse: (NSUInteger) theVerse
{
  [self performBlockAsynchronouslyInForeground:^(void) {[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];}
   afterDelay:0.01f];

  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      if (weakSelf.navigationController.visibleViewController != self)
      {
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
      }
      [weakSelf loadChapter: theChapter forBook: theBook];
      [weakSelf reloadTableCache];
      [[PKHistory instance] addReference: [PKReference referenceWithBook:theBook andChapter: theChapter andVerse: theVerse]];
      [weakSelf notifyChangedHistory];
      [PKSettings instance].topVerse = theVerse;
      [weakSelf scrollToVerse:(int)theVerse withAnimation:NO afterDelay:0.0f];
    } afterDelay:0.02f];
}

/**
 *
 * Load the desired chapter for the desired book. Also saves the settings.
 *
 */
-(void)loadChapter: (NSUInteger) theChapter forBook: (NSUInteger) theBook
{
  // clear selectedVerses
  _selectedVerses             = [[NSMutableDictionary alloc] init];
  PKSettings *theSettings = [PKSettings instance];
  theSettings.currentBook    = theBook;
  theSettings.currentChapter = theChapter;
  //[theSettings saveCurrentReference]; -- removed for speed
  [self loadChapter];
}

/**
 *
 * Loads the next chapter after the current one
 *
 */
-(void)nextChapter
{
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
  
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      NSUInteger currentBook = [[PKSettings instance] currentBook];
      NSUInteger currentChapter = [[PKSettings instance] currentChapter];

      currentChapter++;

      if (currentChapter > [PKBible countOfChaptersForBook: currentBook])
      {
        // advance the book
        currentChapter = 1;
        currentBook++;

        if (currentBook > 66)
        {
          [SVProgressHUD dismiss];
          return;     // can't go past the end of the Bible
        }
      }

      [weakSelf loadChapter: currentChapter forBook: currentBook];
      [weakSelf reloadTableCache];
      [[PKHistory instance] addReferenceWithBook: currentBook andChapter: currentChapter andVerse: 1];
      [weakSelf notifyChangedHistory];

      [weakSelf.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: NO];
    }
  afterDelay: 0.02];
}

/**
 *
 * Loads the previous chapter before the current one
 *
 */
-(void)previousChapter
{
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
  {
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];

    currentChapter--;

    if (currentChapter < 1)
    {
      // advance the book
      currentBook--;

      if (currentBook < 40)
      {
        [SVProgressHUD dismiss];
        return;     // can't go before the start of the NT (currently)
      }
      currentChapter = [PKBible countOfChaptersForBook: currentBook];
    }

    [weakSelf loadChapter: currentChapter forBook: currentBook];
    [weakSelf reloadTableCache];
    [[PKHistory instance] addReferenceWithBook: currentBook andChapter: currentChapter andVerse: [PKBible
                                                                                                             countOfVersesForBook:
                                                                                                             currentBook forChapter
                                                                                                             : currentChapter]];
    [weakSelf notifyChangedHistory];
    [weakSelf scrollToVerse: (int)MAX( [_currentGreekChapter count], [_currentEnglishChapter count]) withAnimation:NO afterDelay:0.0];
  } afterDelay:0.02f
  ];
}

/**
 *
 * load the highlights for this chapter
 *
 */
-(void)loadHighlights
{
  NSUInteger currentBook    = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  // load our highlighted verses
  _highlightedVerses = [[PKHighlights instance] allHighlightedReferencesForBook: currentBook
                                                                                  andChapter: currentChapter];
}


/**
 *
 * load the current chapter. We will render all the UILabels as well to reduce scrolling delays.
 *
 */
-(void)loadChapter
{
  BOOL parsed               = NO;
  BOOL narrowViewport       = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
  BOOL compression =        narrowViewport;

  NSUInteger currentBook    = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  NSUInteger currentBible   = [[PKSettings instance] greekText];
  parsed = [PKBible isStrongsSupportedByText:currentBible] ||
           [PKBible isMorphologySupportedByText:currentBible] ||
           [PKBible isTranslationSupportedByText:currentBible];

  NSDate *startTime;
  NSDate *endTime;
  NSDate *tStartTime;
  NSDate *tEndTime;

//  [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];

  
  tStartTime            = [NSDate date];
  PKReference *theReference = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:0];
  _tableTitle.text       = [theReference format:@"%bN %c#"];
  self.title = [theReference format:@"%bNS?. %c#"];

  startTime             = [NSDate date];
  _currentGreekChapter   = [PKBible getTextForBook: currentBook forChapter: currentChapter forSide: 1];
  _currentEnglishChapter = [PKBible getTextForBook: currentBook forChapter: currentChapter forSide: 2];
  endTime               = [NSDate date];

  // now, get the formatting for both sides, verse by verse
  // greek side first
  startTime                  = [NSDate date];
  _formattedGreekChapter      = [[NSMutableArray alloc] init];
  _formattedGreekVerseHeights = [[NSMutableArray alloc] init];
  CGFloat greekHeightIPhone;

  for (NSUInteger i = 0; i < [_currentGreekChapter count]; i++)
  {
    NSArray *formattedText = [PKBible formatText: _currentGreekChapter[i]
                                       forColumn: 1 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: 0.0 withCompression:compression];

    [_formattedGreekChapter addObject:
     formattedText
    ];

    [_formattedGreekVerseHeights addObject:
     @([PKBible formattedTextHeight: formattedText withParsings: parsed])
    ];
  }
  endTime = [NSDate date];

  // english next
  startTime                    = [NSDate date];
  _formattedEnglishChapter      = [[NSMutableArray alloc] init];
  _formattedEnglishVerseHeights = [[NSMutableArray alloc] init];

  for (NSUInteger i = 0; i < [_currentEnglishChapter count]; i++)
  {
    if ( !narrowViewport )
    {
      greekHeightIPhone = 0.0;
    }
    else
    {
      if (i < _formattedGreekVerseHeights.count)
      {
        greekHeightIPhone = [_formattedGreekVerseHeights[i] floatValue];
      }
      else
      {
        greekHeightIPhone = 0.0;
      }
    }

    NSArray *formattedText = [PKBible formatText: _currentEnglishChapter[i]
                                       forColumn: 2 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: greekHeightIPhone withCompression:compression];

    [_formattedEnglishChapter addObject:
     formattedText
    ];
    [_formattedEnglishVerseHeights addObject:
     @([PKBible formattedTextHeight: formattedText withParsings: parsed])
    ];
  }
  endTime  = [NSDate date];
  tEndTime = [NSDate date];


  // now, create all our UILabels here, so we don't have to do it while generating a cell.

  _formattedCells = [[NSMutableArray alloc] init];
  UIFont *theFont = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                 andSize: [[PKSettings instance] textFontSize]];

  UIFont *theBoldFont = [UIFont fontWithName: [[PKSettings instance] textGreekFontFace]
                                     andSize: [[PKSettings instance] textFontSize]];

  if (theBoldFont == nil)       // just in case there's no alternate
  {
    theBoldFont = theFont;
  }

  for (NSUInteger i = 0; i < MAX([_currentGreekChapter count], [_currentEnglishChapter count]); i++)
  {
    // for each verse (i)

    NSUInteger row = i;

    NSArray *formattedGreekVerse;
    if (row < [_formattedGreekChapter count])
    {
      formattedGreekVerse = _formattedGreekChapter[row];
    }
    else
    {
      formattedGreekVerse = nil;
    }

    NSArray *formattedEnglishVerse;
    if (row < [_formattedEnglishChapter count])
    {
      formattedEnglishVerse = _formattedEnglishChapter[row];
    }
    else
    {
      formattedEnglishVerse = nil;
    }

    NSMutableArray *theLabelArray = [[NSMutableArray alloc] init];
    [theLabelArray addObjectsFromArray:formattedGreekVerse];
    [theLabelArray addObjectsFromArray:formattedEnglishVerse];
    [_formattedCells addObject: theLabelArray];
  }

  [self loadHighlights];
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD dismiss]; } afterDelay:0.01];
}

/**
 *
 * reloadTableCache nukes the old cellHeights and cells array,
 * recalculates them, and then tells the tableView to reload its data.
 *
 * RE: ISSUE #1
 */
-(void) reloadTableCache
{
  _cellHeights = nil;

  _cellHeights = [[NSMutableArray alloc] init];

  for (NSUInteger row = 0; row < MAX([_formattedGreekChapter count], [_formattedEnglishChapter count]); row++)
  {
    [_cellHeights addObject: @([self heightForRowAtIndexPath: [NSIndexPath indexPathForRow: row inSection:
                                                                                       0]])];
  }
  [self.tableView reloadData];
  [self calculateShadows];
}

-(void) saveTopVerse
{
  CGFloat offset = 64.0f;
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && self.navigationController.navigationBarHidden)
    offset = 0;
  NSIndexPath *topRow = [self.tableView indexPathForRowAtPoint:CGPointMake(0, offset + self.tableView.contentOffset.y)];
  
  if (topRow != nil)
  {
    [PKSettings instance].topVerse = [topRow row] + 1;
  }
  else
  {
    [PKSettings instance].topVerse = 1;
  }
}

-(void) scrollToTopVerseWithAnimation
{
  [self scrollToVerse:(int)PKSettings.instance.topVerse withAnimation:YES afterDelay:0.01f];
}

-(void) scrollToTopVerse
{
  [self scrollToVerse:(int)PKSettings.instance.topVerse withAnimation:NO afterDelay:0.01f];
}
-(void)scrollToVerse: (int)theVerse
{
  [self scrollToVerse:theVerse withAnimation:YES];
}
-(void)scrollToVerse: (int)theVerse withAnimation: (BOOL)animation
{
  [self scrollToVerse:theVerse withAnimation: animation afterDelay:0.01f];
}

-(void)scrollToVerse: (int)theVerse withAnimation:(BOOL)animation afterDelay: (float)delay
{
//  [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];
  if (delay > 0)
  {
    __weak typeof(self) weakSelf = self;
    [self performBlockAsynchronouslyInForeground:^(void)
      {
        if (theVerse > 1)
        {
          if ([weakSelf.tableView numberOfRowsInSection: 0] >  1)
          {
            if (theVerse - 1 < [self.tableView numberOfRowsInSection: 0])
            {
              [weakSelf.tableView scrollToRowAtIndexPath:
               [NSIndexPath                    indexPathForRow:
                theVerse - 1 inSection: 0]
                                    atScrollPosition: UITableViewScrollPositionTop animated: animation];
            }
          }
        }
        else
        {
          [weakSelf.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: animation];
        }
      }
    afterDelay: delay];
  }
  else
  {
        if (theVerse > 1)
        {
          if ([self.tableView numberOfRowsInSection: 0] >  1)
          {
            if (theVerse - 1 < [self.tableView numberOfRowsInSection: 0])
            {
              [self.tableView scrollToRowAtIndexPath:
               [NSIndexPath                    indexPathForRow:
                theVerse - 1 inSection: 0]
                                    atScrollPosition: UITableViewScrollPositionTop animated: animation];
            }
          }
        }
        else
        {
          [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: animation];
        }
  }
}
#pragma mark -
#pragma mark View Lifecycle

/**
 *
 * Set our view title
 *
 */
-(id)initWithStyle: (UITableViewStyle) style
{
  self = [super initWithStyle: style];

  if (self)
  {
    // set our title
    [self.navigationItem setTitle: __T(@"Read Bible")];
  }
  return self;
}

-(void) updateAppearanceForTheme
{
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  _tableTitle.textColor           = [PKSettings PKTextColor];
  
  // set the button titles
  [_previousChapterButton setImage: [UIImage imageNamed: @"ArrowLeft-30" withColor:[PKSettings PKTintColor]] forState: UIControlStateNormal];
  [_nextChapterButton setImage: [UIImage imageNamed: @"ArrowRight-30" withColor:[PKSettings PKTintColor]] forState: UIControlStateNormal];
 
  
  // set the table title up
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
  {
    _tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] andSize: 44];
  }
  else
  {
    _tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] andSize: 28];
  }
  
  [self reloadTableCache];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
  return [PKSettings PKStatusBarStyle];
}

//http://stackoverflow.com/a/26007878
- (BOOL)prefersStatusBarHidden {
  return self.navigationController.isNavigationBarHidden;
}

-(void) bibleTextChanged
{
  _leftTextSelect.title         = [[PKBible abbreviationForTextID: [[PKSettings instance] greekText]] stringByAppendingString: @" ▾"];
  _rightTextSelect.title        = [[PKBible abbreviationForTextID: [[PKSettings instance] englishText]] stringByAppendingString: @" ▾"];

}

// ISSUE #61
-(void)viewDidAppear: (BOOL) animated
{
  [super viewDidAppear:animated];
  [self resignFirstResponder]; // resign first; just in case?
  [self becomeFirstResponder]; // respond to copy command from keyboard?
}

/**
 *
 * Whenever we appear, we need to reload the chapter. (Highlights / Settings / etc., may have changed)
 *
 */
-(void)viewWillAppear: (BOOL) animated
{
  [super viewWillAppear:animated];
  [self configureNavigationItemsWith:self.traitCollection];
  
//  self.navigationController.scrollNavigationBar.scrollView = self.tableView;

  if (_dirty
      || _lastKnownOrientation != [[UIDevice currentDevice] orientation])
  {
    _lastKnownOrientation = [[UIDevice currentDevice] orientation];
    [self loadChapter];
    [self reloadTableCache];
    [[PKHistory instance] addReferenceWithBook: [[PKSettings instance] currentBook] andChapter: [[PKSettings instance]
                                                                                                            currentChapter]
     andVerse: [[PKSettings instance] topVerse]];
    [self notifyChangedHistory];
    [self scrollToTopVerse];
    [self calculateShadows];
    _dirty = NO;
  }
  [self bibleTextChanged];
  [self updateAppearanceForTheme];

}

-(void)viewWillDisappear: (BOOL) animated
{
  [self saveTopVerse];
  [[PKSettings instance] saveCurrentReference];

}

-(void)configureNavigationItemsWith: (UITraitCollection *)traitCollection {
  NSDictionary *largeTextAttributes;
  // Text Attributes for Font-Awesome Icons:
  largeTextAttributes = @{ //UITextAttributeFont : [UIFont systemFontOfSize:20],
                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] };

  UIImage *blankImage = [UIImage new];
  // add navbar items
  //
  // change reference is the menu button
  
  
  UIBarButtonItem *changeReference = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"Menu-30" withColor:[PKSettings PKTintColor]] target:self action:@selector(revealToggle:) andBackgroundImage:blankImage];
  changeReference.accessibilityLabel = __T(@"Go to passage");
  
  // font select lets the user change the theme
  UIBarButtonItem *fontSelect = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"Layout-30" withColor:[PKSettings PKTintColor]] target:self action:@selector(fontSelect:) andBackgroundImage:blankImage];
  fontSelect.accessibilityLabel = __T(@"Layout");
  
  // leftTextSelect lets the user change the left-side Bible
  _leftTextSelect                = [UIBarButtonItem barButtonItemWithTitle:[[PKBible abbreviationForTextID: [[PKSettings instance] greekText]]
                                                                            stringByAppendingString: @" ▾"] target:self action:@selector(textSelect:) withTitleTextAttributes:largeTextAttributes andBackgroundImage:blankImage];
  
  
  self.navigationItem.leftBarButtonItems = (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
    ? @[changeReference, fontSelect, _leftTextSelect]
    : @[changeReference, fontSelect];
  
  _rightTextSelect = [UIBarButtonItem barButtonItemWithTitle:[[PKBible abbreviationForTextID: [[PKSettings instance] englishText]] stringByAppendingString: @" ▾"] target:self action:@selector(textSelect:) withTitleTextAttributes:largeTextAttributes andBackgroundImage:blankImage];
  
  UIBarButtonItem *adjustSettings = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"Settings-30" withColor:[PKSettings PKTintColor]] target:self action:@selector(doSettings:) andBackgroundImage:blankImage];
  adjustSettings.accessibilityLabel = __T(@"Settings");
  
  _searchText = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"Search-30" withColor:[PKSettings PKTintColor]] target:self action:@selector(searchBible:) andBackgroundImage:blankImage];
  _searchText.accessibilityLabel = __T(@"Search");
  
  
  self.navigationItem.rightBarButtonItems = (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
    ? @[ adjustSettings, _searchText, _rightTextSelect ]
    : @[ adjustSettings, _searchText ];
  
  
}

/**
 *
 * Set up our background color, add gestures for going forward and backward, add the longpress recognizer
 * and handle a small bar on the left that will allow for swiping open the left-side navigation.
 *
 */
-(void)viewDidLoad
{
  self.enableVerticalScrollBar = NO;
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeLayout:) name:@"com.photokandy.gbible.settings.changed" object:nil];
  
  _dirty = YES;
  _lastKnownOrientation           = [[UIDevice currentDevice] orientation];
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
  
  
  // add our gestures
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

  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                             initWithTarget: self action: @selector(didReceiveLongPress:)];
  longPress.minimumPressDuration    = 0.5;
  longPress.numberOfTapsRequired    = 0;
  longPress.numberOfTouchesRequired = 1;
  [self.tableView addGestureRecognizer: longPress];
  
  // init our selectedVeres
  _selectedVerses = [[NSMutableDictionary alloc] init];

  

  // create the header and footer views
  UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 88)];
  _tableTitle            = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 88)];
  _previousChapterButton = [UIButton buttonWithType: UIButtonTypeCustom];
  [_previousChapterButton setFrame: CGRectMake((isWide((UIView *)self) ? 10 : 0), 22, 44, 44)];

  UIView *footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 64)];
  _nextChapterButton = [UIButton buttonWithType: UIButtonTypeCustom];
  [_nextChapterButton setFrame: CGRectMake(self.tableView.frame.size.width - (isWide((UIView *)self) ? 54 : 44), 10, 44, 44)];

  // set the button titles
  [_previousChapterButton setImage: [UIImage imageNamed: @"ArrowLeft-30" withColor:[PKSettings PKTintColor]] forState: UIControlStateNormal];
  [_nextChapterButton setImage: [UIImage imageNamed: @"ArrowRight-30" withColor:[PKSettings PKTintColor]] forState: UIControlStateNormal];

  // set the targets
  [_previousChapterButton addTarget: self action: @selector(previousChapter) forControlEvents: UIControlEventTouchUpInside];
  [_nextChapterButton addTarget: self action: @selector(nextChapter) forControlEvents: UIControlEventTouchUpInside];

  _nextChapterButton.autoresizingMask       = UIViewAutoresizingFlexibleLeftMargin;


  _previousChapterButton.accessibilityLabel = __T(@"Previous Chapter");
  _nextChapterButton.accessibilityLabel     = __T(@"Next Chapter");

  // set the table title up
  if (isWide((UIView *)self))
  {
    _tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] andSize: 44];
  }
  else
  {
    _tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] andSize: 28];
  }
  _tableTitle.textAlignment    = NSTextAlignmentCenter;
  _tableTitle.textColor        = [PKSettings PKTextColor];
  _tableTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _tableTitle.backgroundColor  = [UIColor clearColor];

  // add the items to our views
  [headerView addSubview: _tableTitle];
  [headerView addSubview: _previousChapterButton];

  [footerView addSubview: _nextChapterButton];

  //[headerView addSubview:[[UITextView alloc] initWithFrame:CGRectMake(0,0,100,100)]];

  // add the views to the table
  self.tableView.tableHeaderView = headerView;
  self.tableView.tableFooterView = footerView;
 
 
}


-(void) setUpMenuItems
{
    _ourMenu           = [UIMenuController sharedMenuController];
    _ourMenu.menuItems = @[
// ISSUE #61
                         //            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")      action:@selector(copySelection:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Copy...")      action: @selector(askCopy:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Highlight") action: @selector(askHighlight:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Annotate")  action: @selector(doAnnotate:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Search")    action: @selector(askSearch:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Define")    action: @selector(defineWord:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Explain")   action: @selector(explainVerse:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Layout")   action: @selector(textSettings:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Clear")     action: @selector(clearSelection:)],
                         // handle second-tier items
                         [[UIMenuItem alloc] initWithTitle: __T(@"Yellow") action: @selector(highlightSelectionYellow:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Green") action: @selector(highlightSelectionGreen:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Magenta") action: @selector(highlightSelectionMagenta:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Pink") action: @selector(highlightSelectionPink:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Blue") action: @selector(highlightSelectionBlue:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Remove")        action: @selector(removeHighlights:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Search Bible")  action: @selector(searchBible:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Search Strong's") action: @selector(searchStrongs:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Copy Left") action: @selector(copyLeft:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Copy Right") action: @selector(copyRight:)]
                         ];
}


/**
 *
 * Determine what actions can occur when a menu is displayed.
 *
 */
-(BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
  if (_ourMenuState == 0)
  {
// ISSUE #61
    if ( action == @selector(copy:) )
    {
      return YES;
    }

    if ( action == @selector(selectAll:) )
    {
      return YES;
    }

    if ( action == @selector(doAnnotate:) )
    {
      return YES;
    }

    if ( action == @selector(defineWord:) )           //return selectedWord!=nil && theWordTag != 0;
    {
      if (!_selectedWord)
      {
        return NO;
      }                                                                                 // word must not be nil

      if (_theWordTag == 0)
      {
        return _theWordIndex > -1;
      }                                                                                                // if greek, must have a
                                                                                                       // strongs#
      return (_theWordTag < 20);                                               // otherwise, we must not be a morphological word
    }

    if ( action == @selector(explainVerse:) )
    {
      return [PKBibleViewController hasConnectivity];
    }

    if ( action == @selector(clearSelection:) )
    {
      return YES;
    }

    if ( action == @selector(textSettings:) )
    {
      return isNarrow((UIView *)self);
    }

    if ( SYSTEM_VERSION_LESS_THAN(@"5.0") )   // < ios 5
    {
      if ( action == @selector(highlightSelection:))
      {
        return YES;
      }

      if ( action == @selector(removeHighlights:) )
      {
        return YES;
      }

      if ( action == @selector(searchBible:) )
      {
        return _selectedWord != nil;
      }

      if ( action == @selector(searchStrongs:) )
      {
        return _selectedWord != nil;
      }

      if ( action == @selector(askHighlight:) )
      {
        return NO;
      }

      if ( action == @selector(askSearch:) )
      {
        return NO;
      }
    }
    else
    {
      if ( action == @selector(askHighlight:) )
      {
        return YES;
      }

      if ( action == @selector(askSearch:) )
      {
        return _selectedWord != nil;
      }
      
      if ( action == @selector(askCopy:) )
      {
        return YES;
      }
    }
  }

  if (_ourMenuState == 1)    // we're asking about highlighting
  {
    if ( action == @selector(highlightSelection:) ||
         action == @selector(highlightSelectionYellow:) ||
         action == @selector(highlightSelectionGreen:) ||
         action == @selector(highlightSelectionMagenta:) ||
         action == @selector(highlightSelectionPink:) ||
         action == @selector(highlightSelectionBlue:)
       )
    {
      return YES;
    }

    if ( action == @selector(removeHighlights:) )
    {
      return YES;
    }
  }

  if (_ourMenuState == 2)   // we're asking about searching
  {
    if ( action == @selector(searchBible:) )
    {
      return _selectedWord != nil;
    }

    if ( action == @selector(searchStrongs:) )
    {
      return _selectedWord != nil;
    }
  }
  
  if (_ourMenuState == 3)    // we're asking about copying
  {
    return (action == @selector(copyLeft:)) || (action == @selector(copyRight:))
         ? YES : NO;
  }
  return NO;
}

/**
 *
 * We become first responder so that we can show a menu
 *
 */
-(BOOL) canBecomeFirstResponder
{
  return YES;
}

/**
 *
 * Release all our variables
 *
 */
-(void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  _currentGreekChapter          = nil;
  _currentEnglishChapter        = nil;

  _formattedGreekChapter        = nil;
  _formattedEnglishChapter      = nil;

  _formattedGreekVerseHeights   = nil;
  _formattedEnglishVerseHeights = nil;

  _selectedVerses               = nil;
  _highlightedVerses            = nil;

  _changeHighlight              = nil;
  _formattedCells               = nil;
  _ourMenu = nil;

  _selectedWord                 = nil;
  _selectedPassage              = nil;

  _ourPopover                   = nil;

  _cells = nil;
  _cellHeights                  = nil;

  _btnRegularScreen             = nil;

  _tableTitle                   = nil;
  
  _PO                           = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  if ( [PKAppDelegate sharedInstance].splash )
  {
    [[PKAppDelegate sharedInstance].splash removeFromSuperview];
  }
  return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  //FIX ISSUE #74
  if ( [PKAppDelegate sharedInstance].splash )
  {
    [[PKAppDelegate sharedInstance].splash removeFromSuperview];
  }
}
/**
 *
 * Since our orientation (can) determine how much content is visible, when it changes, we
 * have to re-calc it. Obvious visually, but better doing it after the orientation, than
 * in the middle and have the rotation visually /stop/ for a few ms.
 *
 */
/*-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  _lastKnownOrientation = [[UIDevice currentDevice] orientation];
  [self calculateShadows];
  [self saveTopVerse];
  [self loadChapter];
  [self reloadTableCache];
  [self scrollToTopVerseWithAnimation];
}*/

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [self configureNavigationItemsWith:newCollection];

}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  // VIA http://stackoverflow.com/a/27409619
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

  // dismiss any popovers
  if (_PO)
  {
    [_PO dismissPopoverAnimated: NO];
  }
  
  
  // Code here will execute before the rotation begins.
  // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
  
  
  [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    
    // Code here will execute after the rotation has finished.
    // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
    _lastKnownOrientation = [[UIDevice currentDevice] orientation];
    [self calculateShadows];
   // [self configureNavigationItems];
    [self saveTopVerse];
    [self loadChapter];
    [self reloadTableCache];
    [self updateAppearanceForTheme];
    [self scrollToTopVerseWithAnimation];
    
    
  }];
}
/*
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
  [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];
}
*/
/*
-(void)scrollViewDidScroll: (UIScrollView *) scrollView
{
  [self calculateShadows];
}
*/

#pragma mark -
#pragma mark Table View Data Source Methods

/**
 *
 * We have 1 section
 *
 */
-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
  return 1;
}

/**
 *
 * It's possible for the greek & english columns to have a different number of verses. (Romans 13, 16)
 * Return the largest verse count.
 *
 */
-(NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  // return the number of verses in the current passage
  NSUInteger currentGreekVerseCount   = [_currentGreekChapter count];
  NSUInteger currentEnglishVerseCount = [_currentEnglishChapter count];
  NSUInteger currentVerseCount        = MAX(currentGreekVerseCount, currentEnglishVerseCount);

  return currentVerseCount;
}

/**
 *
 * Return the height for each row
 *
 */
-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  return [_cellHeights[indexPath.row] floatValue];
}

-(CGFloat) heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row           = [indexPath row];
  // the height is the MAX of both the formattedGreekVerseHeights and EnglishVerseHeights for row
  float greekVerseHeight   = 0.0;
  float englishVerseHeight = 0.0;

  if (row < [_formattedGreekVerseHeights count])
  {
    greekVerseHeight = [_formattedGreekVerseHeights[row] floatValue];
  }

  if (row < [_formattedEnglishVerseHeights count])
  {
    englishVerseHeight = [_formattedEnglishVerseHeights[row] floatValue];
  }

  float theMax = MAX(greekVerseHeight, englishVerseHeight);

  // if we have a note to display, add to theMax
  NSUInteger theBook      = [[PKSettings instance] currentBook];
  NSUInteger theChapter   = [[PKSettings instance] currentChapter];

  NSArray *theNote =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter: theChapter andVerse: row + 1]];

  if (theNote != nil
      && [[PKSettings instance] showNotesInline])
  {
    NSString *theNoteText = [NSString stringWithFormat: @"%@ - %@",
                             theNote[0],
                             theNote[1]];
    CGSize theSize        = [theNoteText sizeWithFont: [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                                    andSize: [[PKSettings instance] textFontSize]]
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width -
                             (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? 88 : 20), 1999) usingLigatures:YES];
    theMax += 10 + theSize.height + 10;
  }

  return round(theMax);
}

/**
 *
 * Determine the cell's highlighted/selection status
 *
 */
-(void) tableView: (UITableView *) tableView willDisplayCell: (UITableViewCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath
{
  PKTableViewCell *pkCell   = (PKTableViewCell *)cell;

  // determine if the cell is selected
  NSUInteger row            = [indexPath row];
  BOOL curValue;
  NSUInteger currentBook    = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];

  // are we selected? If so, it takes precedence
  PKReference *reference         = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:row+1];
  curValue = [_selectedVerses[reference.reference] boolValue];
  

  if (curValue)
  {
    pkCell.selectedColor = [PKSettings PKSelectionColor];
  }
  else
  {
    pkCell.selectedColor = nil;
  }

  // are we highlighted?
  if (_highlightedVerses[[PKReference stringFromVerseNumber: row + 1]] != nil)
  {
    pkCell.highlightColor = _highlightedVerses[[PKReference stringFromVerseNumber: row + 1]];
  }
  else   // not highlighted, be transparent.
  {
    pkCell.highlightColor = nil;
  }
}

/**
 *
 * Render the cell. We're pre-calcing the layout, so this is pretty fast.
 *
 */
-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  return [self cellForRowAtIndexPath: indexPath];
}

-(UITableViewCell *) cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  BOOL wideViewport = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
  static NSString *bibleCellID = @"PKBibleCellID";
  PKTableViewCell *cell        = //nil; //
                                 [self.tableView dequeueReusableCellWithIdentifier: bibleCellID];

  if (!cell)
  {
    cell = [[PKTableViewCell alloc]
              initWithStyle: UITableViewCellStyleValue1
            reuseIdentifier: bibleCellID];
  }

  // need to remove the cell's subviews, if they exist...
  for (UIView *view in cell.contentView.subviews)
  {
    [view removeFromSuperview];
  }

  cell.contentMode         = UIViewContentModeRedraw;
  cell.autoresizesSubviews = NO;
  cell.backgroundColor     = [UIColor clearColor];
  NSUInteger row = [indexPath row];

  // and check if we have a note
  NSUInteger theBook              = [[PKSettings instance] currentBook];
  NSUInteger theChapter           = [[PKSettings instance] currentChapter];

  NSArray *theNote         =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter: theChapter andVerse: row + 1]];

  float greekVerseHeight   = 0.0;
  float englishVerseHeight = 0.0;

  if (row < [_formattedGreekVerseHeights count])
  {
    greekVerseHeight = [_formattedGreekVerseHeights[row] floatValue];
  }

  if (row < [_formattedEnglishVerseHeights count])
  {
    englishVerseHeight = [_formattedEnglishVerseHeights[row] floatValue];
  }

  float theMax = MAX(greekVerseHeight, englishVerseHeight);

  if (theNote != nil
      && [[PKSettings instance] showNotesInline])
  {
    NSString *theNoteText = [NSString stringWithFormat: @"%@ - %@",
                             theNote[0],
                             theNote[1]];
    CGSize theSize        = [theNoteText sizeWithFont: [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                                    andSize: [[PKSettings instance] textFontSize]]
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width -
                             (wideViewport ? 88 : 20), 1999) usingLigatures:YES ];
    CGRect theRect        = CGRectIntegral( CGRectMake( wideViewport ? 44 : 10,
                                        theMax + 10,
                                        self.tableView.bounds.size.width -
                                        (wideViewport ? 88 : 20), theSize.height) );

    UILabel *theNoteLabel = [[UILabel alloc] initWithFrame: theRect];
    theNoteLabel.text            = theNoteText;
    theNoteLabel.numberOfLines   = 0;
    theNoteLabel.font            = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                andSize: [[PKSettings instance] textFontSize]];
    //#502057, 80, 32, 97
    theNoteLabel.textColor       = [PKSettings PKAnnotationColor];
    theNoteLabel.backgroundColor = [UIColor clearColor];
    theNoteLabel.shadowColor     = [PKSettings PKLightShadowColor];
    theNoteLabel.shadowOffset    = CGSizeMake(0, 1);
    theNoteLabel.tag             = 99;
    [cell.contentView addSubview: theNoteLabel];
  }
  else
  {
    if (theNote != nil)
    {
      // need to indicate /somehow/ that we have a note.
      UIImageView *theImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Pencil-30" withColor:[PKSettings PKTextColor]]];
      theImage.frame = CGRectMake(self.tableView.bounds.size.width - 50, theMax - 40, 30, 30);
      [cell.contentView addSubview: theImage];
    }
  }

  NSMutableArray *formattedCell = _formattedCells[row];

  NSMutableString *theAString   = [[NSMutableString alloc] init];

  for (NSUInteger i = 0; i < [formattedCell count]; i++)
  {
    [theAString appendString: [formattedCell[i] text]];
    [theAString appendString: @" "];
  }

  cell.labels             = formattedCell;
  //[cell addSubview:theVerseNumber];

  cell.accessibilityLabel = theAString;
  [cell setNeedsDisplay];

  cell.selectionStyle     = UITableViewCellSelectionStyleNone;

  return cell;
}

/**
 *
 * If the user taps the row, we change the selection status.
 *
 */
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  // if we have a menu open, we don't want to change anything....
  if (_ourMenu.isMenuVisible)
  {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    return;
  }

  NSUInteger row            = [indexPath row];
  BOOL curValue;
  NSUInteger currentBook    = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  PKReference *reference    = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:row+1];
  PKTableViewCell *newCell  = (PKTableViewCell *)[tableView cellForRowAtIndexPath: indexPath];

  // toggle the selection state

  curValue = [_selectedVerses[reference.reference] boolValue];
  _selectedVerses[reference.reference] = [NSNumber numberWithBool: !curValue];
  curValue = [_selectedVerses[reference.reference] boolValue];

  if (curValue)
  {
    newCell.selectedColor = [PKSettings PKSelectionColor];
  }
  else
  {
    newCell.selectedColor = nil;
  }

  // are we highlighted?
  if (_highlightedVerses[[PKReference stringFromVerseNumber: row + 1]] != nil)
  {
    newCell.highlightColor = _highlightedVerses[[PKReference stringFromVerseNumber: row + 1]];
  }
  else   // not highlighted, be transparent.
  {
    newCell.highlightColor = nil;
  }
  [newCell setNeedsDisplay];

  [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark -
#pragma mark UISwipeGestureRecognizer
/**
 *
 * We swiped right, load the previous chapter
 *
 */
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
  [self previousChapter];
}

/**
 *
 * We swiped left, load the next chapter
 *
 */
-(void) didReceiveLeftSwipe: (UISwipeGestureRecognizer *) gestureRecognizer
{
  ZUUIRevealController *rc = [PKAppDelegate sharedInstance].rootViewController;

  if ([rc currentFrontViewPosition] == FrontViewPositionRight)
  {
    [rc revealToggle: nil];
    return;
  }
  [self nextChapter];
}


/**
 *
 * We long-pressed on a cell. Determine the cell (and the word we're over: TODO)
 * and open the long-press popover
 *
 */
-(void) didReceiveLongPress: (UILongPressGestureRecognizer *) gestureRecognizer
{
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
  {
    [self setUpMenuItems];
    CGPoint p              = [gestureRecognizer locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: p];    // nil if no row
    PKLabel *theWordLabel  = nil;
    _selectedWord        = nil;
    CGRect theRect;
    theRect.origin.x    = p.x;
    theRect.origin.y    = p.y;
    theRect.size.width  = 1;
    theRect.size.height = 1;

    if (indexPath != nil)
    {
      NSUInteger row           = [indexPath row];

      // determine the word we're closest to
      float minDistance        = 999;
      PKTableViewCell *theCell = (PKTableViewCell *)[self.tableView cellForRowAtIndexPath: indexPath];
      CGPoint wp               = [gestureRecognizer locationInView: theCell];
      NSString *theWord        = nil;
      _theWordTag = -1;

      for (NSUInteger i = 0; i < [theCell.labels count]; i++)
      {
        PKLabel *theView = (theCell.labels)[i];

        // only UILabels, please
        if ([theView respondsToSelector: @selector(text)])
        {
          // no morphology labels or note labels
          if (theView.tag < 20)
          {
            CGRect theRect    = theView.frame;

            CGPoint theCenter = CGPointMake( theRect.origin.x + (theRect.size.width / 2),
                                             theRect.origin.y + (theRect.size.height / 2) );
            float theDistance = sqrtf(ABS(theCenter.x - wp.x) * 2 +
                                      ABS(theCenter.y - wp.y) * 2);

            if (theDistance < minDistance)
            {
              _theWordTag   = theView.tag;
              _theWordIndex = theView.secondTag;
              theWord      = ( (PKLabel *)theView ).text;
              theWordLabel = (PKLabel *)theView;
              minDistance  = theDistance;
            }
          }
        }
      }

      if (theWord != nil)
      {
        // strip any junk characters
        NSCharacterSet *junkChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        theWord = [theWord stringByTrimmingCharactersInSet: junkChars];

        if ([theWord isEqualToString: @""])
        {
          _theWordTag   = -1;
          _theWordIndex = -1;
          theWord      = nil;
          theWordLabel = nil;
        }
      }
      _selectedWord = theWord;

      // select the row
      BOOL curValue;
      NSUInteger currentBook    = [[PKSettings instance] currentBook];
      NSUInteger currentChapter = [[PKSettings instance] currentChapter];

      _selectedPassage = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:row+1];

      PKTableViewCell *newCell = (PKTableViewCell *)[self.tableView cellForRowAtIndexPath: indexPath];
      _selectedVerses[_selectedPassage.reference] = @YES;
      curValue = [_selectedVerses[_selectedPassage.reference] boolValue];

      if (curValue)
      {
        newCell.selectedColor = [PKSettings PKSelectionColor];
      }
      else
      {
        newCell.selectedColor = nil;
      }

      // are we highlighted?
      if (_highlightedVerses[[PKReference stringFromVerseNumber: row + 1]] != nil)
      {
        newCell.highlightColor = _highlightedVerses[[PKReference stringFromVerseNumber: row + 1]];
      }
      else       // not highlighted, be transparent.
      {
        newCell.highlightColor = nil;
      }
      [newCell setNeedsDisplay];

      if (_selectedWord != nil)
      {
        // highlight the word we got
        theRect           = theWordLabel.frame;
        theRect.origin.y += newCell.frame.origin.y;

        // create a new view and animate it in

        CGRect theNewRect = theWordLabel.frame;
        theNewRect.origin.x       -= 15;
        theNewRect.origin.y       -= 5;
        theNewRect.size.width     += 30;
        theNewRect.size.height    += 10;
        UILabel *theNewWord = [[UILabel alloc] initWithFrame: CGRectIntegral(theNewRect)];
        theNewWord.alpha           = 0.0f;
        theNewWord.backgroundColor = [UIColor whiteColor];
        theNewWord.textColor       = [PKSettings PKTextColor];
        theNewWord.font            = theWordLabel.font;
        theNewWord.text            = theWordLabel.text;

        theNewWord.layer.cornerRadius = 10;

        theNewWord.textAlignment      = NSTextAlignmentCenter;
        [theCell.contentView addSubview: theNewWord];
        [UIView animateWithDuration: 0.5f animations:
         ^{
           theNewWord.alpha = 1.0f;
         }
                         completion:^(BOOL finished)
         {
           [UIView animateWithDuration: 1 animations:
            ^{
              theNewWord.alpha = 1;
            }
                            completion:^(BOOL finished)
            {
              [UIView animateWithDuration: 0.55f animations:
               ^{
                 theNewWord.alpha = 0.0f;
               }
                               completion:^(BOOL finished)
               {
                 [theNewWord removeFromSuperview];
               }
              ];
            }
           ];
         }
        ];
      }

/*
        // build up our popover
        if (theWordIndex>-1)
        {
          NSArray *theSearchResults = [PKStrongs keysThatMatch:[@"G" stringByAppendingString:[[NSNumber numberWithInt:theWordIndex]
             stringValue]] byKeyOnly:YES];
          if (theSearchResults.count>0)
          {
            NSArray *theEntry = [PKStrongs entryForKey:theSearchResults[0]];
            // we have a Strong's # -- let's display it

            NSArray *theStrings = @[
                                     @"Copy", @"Highlight", @"Annotate", @"Search", @"Define", @"Explain", @"Clear" ];

            [PopoverView showPopoverAtPoint:p inView:self.tableView withTitle:[NSString stringWithFormat:@"%@", theEntry[3]]
             withStringArray:theStrings delegate:nil];
          }
        }
 */

      _ourMenuState = 0;   // show entire menu (not second-tier)
      [self becomeFirstResponder];
      [_ourMenu update];   // just in case
      [_ourMenu setTargetRect: theRect inView: self.tableView];
      [_ourMenu setMenuVisible: YES animated: YES];
    }
  }
}


#pragma mark -
#pragma mark miscellaneous selectors (called from popovers, buttons, etc.)


-(void) textSelect: (id) sender
{
  if (_PO)
  {
    [_PO dismissPopoverAnimated: NO];
  }
  NSArray *bibleTextNames;
  NSArray *bibleAbbreviations;
  NSString *title;
  int theTag;

  if (sender == _leftTextSelect)
  {
    _bibleTextIDs   = [PKBible availableOriginalTexts: PK_TBL_BIBLES_ID];
    bibleTextNames = [PKBible availableOriginalTexts: PK_TBL_BIBLES_NAME];
    bibleAbbreviations=[PKBible availableOriginalTexts:PK_TBL_BIBLES_ABBREVIATION];
    title          = __T(@"Greek Text");
    theTag         = 1898;
  }
  else
  {
    _bibleTextIDs   = [PKBible availableHostTexts: PK_TBL_BIBLES_ID];
    bibleTextNames = [PKBible availableHostTexts: PK_TBL_BIBLES_NAME];
    bibleAbbreviations=[PKBible availableHostTexts:PK_TBL_BIBLES_ABBREVIATION];
    title          = __T(@"English Text");
    theTag         = 1899;
  }

  // dismiss our popover if we've got one
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];

  UIActionSheet *theActionSheet = [[UIActionSheet alloc] init];
  theActionSheet.title    = title;
  theActionSheet.delegate = self;

  for (NSUInteger i = 0; i < _bibleTextIDs.count; i++)
  {
    [theActionSheet addButtonWithTitle: [bibleTextNames[i] stringByAppendingFormat:@" (%@)", bibleAbbreviations[i]]];
  }

  [theActionSheet addButtonWithTitle: __T(@"Cancel")];
  theActionSheet.cancelButtonIndex = _bibleTextIDs.count;
  theActionSheet.tag               = theTag; // text chooser
  _ourPopover = theActionSheet;

  [theActionSheet showFromBarButtonItem: sender animated: YES];
}

-(void) textSettings: (id) sender
{
  [self fontSelect: nil];
}

-(void) toggleStrongs: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      [weakSelf saveTopVerse];
      [PKSettings instance].showStrongs = ![PKSettings instance].showStrongs;
      [[PKSettings instance] saveSettings];
      [weakSelf loadChapter];
      [weakSelf reloadTableCache];
      [weakSelf scrollToTopVerseWithAnimation];
    } afterDelay:0.02f
  ];
}

-(void) toggleMorphology: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      [weakSelf saveTopVerse];
      [PKSettings instance].showMorphology = ![PKSettings instance].showMorphology;
      [[PKSettings instance] saveSettings];
      [weakSelf loadChapter];
      [weakSelf reloadTableCache];
      [weakSelf scrollToTopVerseWithAnimation];
    } afterDelay:0.02f
  ];
}

-(void) toggleTranslation: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      [weakSelf saveTopVerse];
      [PKSettings instance].showInterlinear = ![PKSettings instance].showInterlinear;
      [[PKSettings instance] saveSettings];
      [weakSelf loadChapter];
      [weakSelf reloadTableCache];
      [weakSelf scrollToTopVerseWithAnimation];
    } afterDelay:0.02f
  ];
}


-(void) selectAll: (id) sender
{
  _selectedVerses = [[NSMutableDictionary alloc] init]; // clear selection

  NSUInteger currentGreekVerseCount   = [_currentGreekChapter count];
  NSUInteger currentEnglishVerseCount = [_currentEnglishChapter count];
  NSUInteger currentVerseCount        = MAX(currentGreekVerseCount, currentEnglishVerseCount);

  // add all the verses to the selection
  for (int i = 0; i < currentVerseCount; i++)
  {
    NSUInteger currentBook    = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    PKReference *reference = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:i+1];

    _selectedVerses[reference.reference] = @YES;
  }

  [self reloadTableCache];
}

/**
 *
 * When "Highlight" is pressed on the menu, we need to present new options.
 *
 */
-(void) askHighlight: (id) sender
{
   [self setUpMenuItems];
  _ourMenuState = 1;
  [_ourMenu update];
  [_ourMenu setMenuVisible: YES animated: YES];
}

/**
 *
 * When "Search" is pressed on the menu, we need to present new options.
 *
 */
-(void) askSearch: (id) sender
{
   [self setUpMenuItems];
  _ourMenuState = 2;
  [_ourMenu update];
  [_ourMenu setMenuVisible: YES animated: YES];
}

-(void) askCopy: (id) sender
{
   [self setUpMenuItems];
  _ourMenuState = 3;
  [_ourMenu update];
  [_ourMenu setMenuVisible: YES animated: YES];
}

/**
 *
 * Display a drop-down for the highlight color button
 *
 */
-(void) changeHighlightColor: (id) sender
{
  if (_PO)
  {
    [_PO dismissPopoverAnimated: NO];
  }
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];

  UIActionSheet *theActionSheet = [[UIActionSheet alloc]
                                            initWithTitle: __T(@"Choose Color")
                                                 delegate: self
                                        cancelButtonTitle: __T(@"Cancel")
                                   destructiveButtonTitle: nil
                                        otherButtonTitles: __T(@"Yellow"), __T(@"Green"), __T(@"Magenta"),
                                   __T(@"Pink"),   __T(@"Blue"),    nil];
  theActionSheet.tag = 1999;   // color chooser
  _ourPopover         = theActionSheet;
  [theActionSheet showFromBarButtonItem: sender animated: YES];
}

/**
 *
 * Clear the user's selection
 *
 */
-(void) clearSelection: (id) sender
{
  _selectedVerses = [[NSMutableDictionary alloc] init];   // clear selection
//    [self.tableView reloadData]; // and reload the table's data
  [self reloadTableCache];
}

/**
 *
 * Toggle the sidebar and hide any popovers we might have generated.
 *
 */
-(void) revealToggle: (id) sender
{
  if (_PO)
  {
    [_PO dismissPopoverAnimated: NO];
  }
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [(ZUUIRevealController *)[[PKAppDelegate instance] rootViewController] revealToggle: sender];
}

/**
 *
 * let the left-hand navigation know that highlights have changed
 *
 */
-(void) notifyChangedHighlights
{
  [[[PKAppDelegate sharedInstance] highlightsViewController] reloadHighlights];
}

/**
 *
 * let the left-hand navigation know that history has changed
 *
 */
-(void) notifyChangedHistory
{
  [[[PKAppDelegate sharedInstance] historyViewController] reloadHistory];
}

/**
 *
 * called to let us know that notes have changed: reload the table view
 *
 */
-(void) notifyNoteChanged
{
//    [self.tableView reloadData];
  [self reloadTableCache];
}

/**
 *
 * Remove any highlights in the current selection. We can remove without checking, since a remove
 * will never generate an error.
 *
 */
-(void) removeHighlights: (id) sender
{
  for (NSString *key in _selectedVerses)
  {
    if ([_selectedVerses[key] boolValue])
    {
      [[PKHighlights instance]
       removeHighlightFromReference: [PKReference referenceWithString: key]];
    }
  }
  [self notifyChangedHighlights];
  [self loadHighlights];   // get our new highlights
  [self clearSelection: nil];
}

/**
 *
 * Copy the selection to the pasteboard
 *
 */
// ISSUE #61
-(void) copy: (id) sender
{
  [self copySelection: 3]; // all sides
}
-(void) copyLeft: (id) sender
{
  [self copySelection: 1]; // left sides
}
-(void) copyRight: (id) sender
{
  [self copySelection: 2]; // right sides
}

-(void) copySelection: (int) whichSides
{
  NSMutableString *theText   = [[NSMutableString alloc] init];
  // FIX ISSUE #43b
  NSArray *allSelectedVerses = [[_selectedVerses allKeys]
                                // FIX ISSUE #60
                                sortedArrayUsingComparator:
                                ^NSComparisonResult (id obj1, id obj2)
                                {
                                  NSUInteger verse1 = [PKReference verseFromReferenceString: obj1];
                                  NSUInteger verse2 = [PKReference verseFromReferenceString: obj2];

                                  if (verse1 > verse2)
                                  {
                                    return NSOrderedDescending;
                                  }

                                  if (verse1 < verse2)
                                  {
                                    return NSOrderedAscending;
                                  }
                                  return NSOrderedSame;
                                }
                               ];

  for (NSString *key in allSelectedVerses)
  {
    if ([_selectedVerses[key] boolValue])
    {
      NSUInteger theVerse = [PKReference verseFromReferenceString: key];
      PKReference *theReference = [PKReference referenceWithString:key];
      [theText appendFormat:@"%@\n\n", [theReference prettyReference]];
      
      if ( whichSides & 2 )
      {
        if (theVerse <= [_currentEnglishChapter count])
        {
          // FIX ISSUE #43a
          [theText appendString: _currentEnglishChapter[theVerse - 1]];
        }
        [theText appendString: @"\n"];
      }

      if ( whichSides & 1 )
      {
        if (theVerse <= [_currentGreekChapter count])
        {
          // FIX ISSUE #43a
          [theText appendString: _currentGreekChapter[theVerse - 1]];
        }
      }

      NSUInteger theBook      = [[PKSettings instance] currentBook];
      NSUInteger theChapter   = [[PKSettings instance] currentChapter];
      NSArray *theNote =
        [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:theVerse]];
      if (theNote != nil)
      {
        [theText appendFormat: @"\n%@ - %@", theNote[0], theNote[1]];
      }
      [theText appendString: @"\n\n"];
    }
  }

  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  pasteBoard.string = theText;

  [self clearSelection: nil];
  [SVProgressHUD showSuccessWithStatus:__T(@"Copied!")]; // Fixes Issue #85
}

-(void) highlightSelectionYellow: (id) sender
{
  UIColor *newColor  = [PKSettings PKYellowHighlightColor];
  NSString *textColor = __T(@"Yellow");
  [PKSettings instance].highlightColor     = newColor;
  [PKSettings instance].highlightTextColor = textColor;
  [[PKSettings instance] saveCurrentHighlight];
  [self highlightSelection:sender];
}
-(void) highlightSelectionGreen: (id) sender
{
  UIColor *newColor  = [PKSettings PKGreenHighlightColor];
  NSString *textColor = __T(@"Green");
  [PKSettings instance].highlightColor     = newColor;
  [PKSettings instance].highlightTextColor = textColor;
  [[PKSettings instance] saveCurrentHighlight];
  [self highlightSelection:sender];
}
-(void) highlightSelectionMagenta: (id) sender
{
  UIColor *newColor  = [PKSettings PKMagentaHighlightColor];
  NSString *textColor = __T(@"Magenta");
  [PKSettings instance].highlightColor     = newColor;
  [PKSettings instance].highlightTextColor = textColor;
  [[PKSettings instance] saveCurrentHighlight];
  [self highlightSelection:sender];
}
-(void) highlightSelectionPink: (id) sender
{
  UIColor *newColor  = [PKSettings PKPinkHighlightColor];
  NSString *textColor = __T(@"Pink");
  [PKSettings instance].highlightColor     = newColor;
  [PKSettings instance].highlightTextColor = textColor;
  [[PKSettings instance] saveCurrentHighlight];
  [self highlightSelection:sender];
}
-(void) highlightSelectionBlue: (id) sender
{
  UIColor *newColor  = [PKSettings PKBlueHighlightColor];
  NSString *textColor = __T(@"Blue");
  [PKSettings instance].highlightColor     = newColor;
  [PKSettings instance].highlightTextColor = textColor;
  [[PKSettings instance] saveCurrentHighlight];
  [self highlightSelection:sender];
}


/**
 *
 * Highlight the selection with the currently selected highlight color
 *
 */
-(void) highlightSelection: (id) sender
{

  // we're highlighting the selection
  for (NSString *key in _selectedVerses)
  {
    if ([_selectedVerses[key] boolValue])
    {
      [[PKHighlights instance]
       setHighlight: [PKSettings instance].highlightColor
         forReference: [PKReference referenceWithString:key]];
    }
  }
  [self notifyChangedHighlights];
  [self loadHighlights];   // get our new highlights
  [self clearSelection: nil];
}

/**
 *
 * Define the selectedWord
 *
 */
-(void)defineWord: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];
  // if the word is a greek word with a strong's #, we'll look it up first.
  if (_theWordTag == 0
      && _theWordIndex > -1)
  {
    _selectedWord = [NSString stringWithFormat:@"G%i", _theWordIndex];
    [self searchStrongs: sender];

    return;
  }

  // if the word is a strong's #, we'll do that lookup instead.
  //if ([[selectedWord substringToIndex: 1] isEqualToString: @"G"]
  //    && [[selectedWord substringFromIndex: 1] intValue] > 0)
  if (_theWordIndex>0)
  {
    _selectedWord = [NSString stringWithFormat:@"G%i", _theWordIndex];
    [self searchStrongs: sender];
    return;
  }

  UIReferenceLibraryViewController *dictionary = [[UIReferenceLibraryViewController alloc] initWithTerm: _selectedWord];

  if (dictionary != nil)
  {
    // FIX ISSUE #46
    dictionary.modalPresentationStyle = UIModalPresentationFormSheet;
          [self presentViewController:dictionary animated:YES completion:nil];
  }
  else
  {
    // what to do?
  }
}

/**
 *
 * Switches to the Search tab and searches the Bible for the selected word.
 *
 */
-(void)searchBible: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];
  PKSearchViewController *svc = [[PKSearchViewController alloc] initWithStyle:UITableViewStylePlain];
  svc.notifyWithCopyOfVerse = NO;
  svc.delegate = self;
  if (sender != _searchText)
    [svc doSearchForTerm: _selectedWord];

  UINavigationController *mvnc = [[UINavigationController alloc] initWithRootViewController: svc];
  mvnc.modalPresentationStyle = UIModalPresentationPageSheet;
  mvnc.navigationBar.barStyle = UIBarStyleDefault;
          [self presentViewController:mvnc animated:YES completion:nil];
}

/**
 *
 * Switches to the Strong's Lookup tab and searches for the selectedWord. If the word is a
 * strong's number, we indicate that we only want that value (not partial matches).
 *
 */
-(void)searchStrongs: (id) sender
{
  BOOL isStrongs            = _theWordIndex>0;
  //[[selectedWord substringToIndex: 1] isEqualToString: @"G"]
  //                            && [[selectedWord substringFromIndex: 1] intValue] > 0;
  PKStrongsController *svc = [[PKStrongsController alloc] initWithStyle:UITableViewStylePlain];
  svc.delegate = self;
  if (isStrongs)
  {
      _selectedWord = [NSString stringWithFormat:@"G%i", _theWordIndex];
  }
  [svc doSearchForTerm: _selectedWord byKeyOnly: isStrongs];
  
  UINavigationController *mvnc = [[UINavigationController alloc] initWithRootViewController: svc];
  mvnc.modalPresentationStyle = UIModalPresentationPageSheet;
  mvnc.navigationBar.barStyle = UIBarStyleDefault;
          [self presentViewController:mvnc animated:YES completion:nil];
}

/**
 *
 * Explains a verse by loading bible.cc's website.
 *
 */
-(void)explainVerse: (id) sender
{
  NSUInteger theBook                 = _selectedPassage.book;
  NSUInteger theChapter              = _selectedPassage.chapter;
  NSUInteger theVerse                = _selectedPassage.verse;

  NSString *theTransformedURL = [NSString stringWithFormat: @"http://bible.cc/%@/%@-%@.htm",
                                 [[PKBible nameForBook: theBook] lowercaseString],
                                 [PKReference stringFromChapterNumber:theChapter],
                                 [PKReference stringFromVerseNumber:theVerse]];
  theTransformedURL = [theTransformedURL stringByReplacingOccurrencesOfString: @" " withString: @"_"];
  NSURL *theURL        = [[NSURL alloc] initWithString: theTransformedURL];
  //http://stackoverflow.com/a/33929917
  if ([SFSafariViewController class] != nil) {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:theURL];
    //sfvc.delegate = self;
    [self presentViewController:sfvc animated:YES completion:nil];
  } else {
  
    TSMiniWebBrowser *wb = [[TSMiniWebBrowser alloc] initWithUrl: theURL];
    wb.showURLStringOnActionSheetTitle = YES;
    wb.showPageTitleOnTitleBar         = YES;
    wb.showActionButton                = YES;
    wb.showReloadButton                = YES;
    wb.mode = TSMiniWebBrowserModeModal;
    wb.barStyle = UIBarStyleDefault;
    wb.modalDismissButtonTitle         = __T(@"Done");
            [self presentViewController:wb animated:YES completion:nil];
    
  }
}

/**
 *
 * creates a NoteEditorViewController, tells it the passage we're annotating, and shows it modally.
 *
 */
-(void)doAnnotate: (id) sender
{
  PKNoteEditorViewController *nevc = [[PKNoteEditorViewController alloc] initWithReference: _selectedPassage];
  UINavigationController *mvnc     = [[UINavigationController alloc] initWithRootViewController: nevc];
  //mvnc.modalPresentationStyle = UIModalPresentationFormSheet;

  UINavigationBar *navBar          = [mvnc navigationBar];

  if ([navBar respondsToSelector: @selector(setBackgroundImage:)])
  {
    [navBar setBackgroundImage: [UIImage imageNamed: @"BlueNavigationBar.png"] forBarMetrics: UIBarMetricsDefault];
    [navBar setTitleTextAttributes: @{
                                     NSForegroundColorAttributeName: [UIColor whiteColor]}];
  }

          [self presentViewController:mvnc animated:YES completion:nil];
}

-(void)fontSelect: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];

  UINavigationController *nc = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"PKSLayoutNavigationController"];
  nc.view.backgroundColor = [PKSettings PKPageColor];
  
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
  {
    if (_PO)
    {
      [_PO dismissPopoverAnimated: NO];
    }
    _PO = [[UIPopoverController alloc] initWithContentViewController: nc];
    [_PO setPopoverContentSize: CGSizeMake(480, 640) animated: NO];
    [_PO presentPopoverFromBarButtonItem: (UIBarButtonItem *)sender permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
  }
  else
  {
    nc.visibleViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:__T(@"Done") style:UIBarButtonItemStyleDone target:nc.visibleViewController action:@selector(done:)];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
  }

}

-(void)doSettings: (id) sender
{
  [_ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [_PO dismissPopoverAnimated: NO];

  UINavigationController *nc = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"PKSGeneralSettingsNavigationController"];
  nc.view.backgroundColor = [PKSettings PKPageColor];
  
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
  {
    if (_PO)
    {
      [_PO dismissPopoverAnimated: NO];
    }
    _PO = [[UIPopoverController alloc] initWithContentViewController: nc];
    [_PO setPopoverContentSize: CGSizeMake(480, 640) animated: NO];
    [_PO presentPopoverFromBarButtonItem: (UIBarButtonItem *)sender permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
  }
  else
  {
    nc.visibleViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:__T(@"Done") style:UIBarButtonItemStyleDone target:nc.visibleViewController action:@selector(done:)];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
  }
  
  
  
}

#pragma mark -
#pragma mark layout responder
-(void) didChangeLayout: (id) sender
{
  // the settings have changed, update ourselves...
  [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      [weakSelf saveTopVerse];
      [weakSelf updateAppearanceForTheme];
      [weakSelf loadChapter];
      [weakSelf reloadTableCache];
      [weakSelf scrollToTopVerseWithAnimation];
    } afterDelay:0.25f
  ];
}

#pragma mark -
#pragma mark Search delegate
-(void) doBibleSearchFor:(NSString *)theTerm
{
  // TODO
}
-(void) doStrongsSearchFor:(NSString *)theTerm
{
  // TODO
}

#pragma mark -
#pragma mark Reference delegate
-(void) newReferenceByBook:(NSUInteger)theBook andChapter:(NSUInteger)theChapter andVerse:(NSUInteger)andVerse
{
  [self displayBook:theBook andChapter:theChapter andVerse:andVerse];
}
-(void) newVerseByBook:(NSUInteger)theBook andChapter:(NSUInteger)theChapter andVerse:(NSUInteger)andVerse
{
  [self displayBook:theBook andChapter:theChapter andVerse:andVerse];  
}

#pragma mark -
#pragma mark popover responder
/**
 *
 * Handle the response to an actionsheet
 *
 */
-(void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
  if (actionSheet.tag == 1899
      || actionSheet.tag == 1898)
  {
    // handle text changes
    if (buttonIndex < 0
        || buttonIndex == _bibleTextIDs.count)
    {
      // cancel; do nothing.
      return;
    }

    int theNewId = [_bibleTextIDs[buttonIndex] intValue];

    if (actionSheet.tag == 1898)
    {
      [PKSettings instance].greekText = theNewId;
      _leftTextSelect.title =  [[PKBible titleForTextID: theNewId] stringByAppendingString: @" ▾"];
    }
    else
    {
      [PKSettings instance].englishText = theNewId;
      _rightTextSelect.title = [[PKBible titleForTextID: theNewId] stringByAppendingString: @" ▾"];
    }
    [[PKSettings instance] saveSettings];
    [self bibleTextChanged];
    [self performBlockAsynchronouslyInForeground:^{ [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear]; } afterDelay:0.01];
    __weak typeof(self) weakSelf = self;
    [self performBlockAsynchronouslyInForeground:^(void)
      {
        [weakSelf saveTopVerse];
        [weakSelf loadChapter];
        [weakSelf reloadTableCache];
        [weakSelf scrollToTopVerseWithAnimation];
      } afterDelay:0.02f
    ];
  }

  if (actionSheet.tag == 1999)
  {
    // handle color change options
    UIColor *newColor;
    NSString *textColor;

    switch (buttonIndex)
    {
    case 0:
      newColor  = [PKSettings PKYellowHighlightColor];
      textColor = __T(@"Yellow");
      break;

    case 1:
      newColor  = [PKSettings PKGreenHighlightColor];
      textColor = __T(@"Green");
      break;

    case 2:
      newColor  = [PKSettings PKMagentaHighlightColor];
      textColor = __T(@"Magenta");
      break;

    case 3:
      newColor  = [PKSettings PKPinkHighlightColor];
      textColor = __T(@"Pink");
      break;

    case 4:
      newColor  = [PKSettings PKBlueHighlightColor];
      textColor = __T(@"Blue");
      break;

    default:
      return;       // either cancelling, or out of range. we don't care.
    }

    if ([_changeHighlight respondsToSelector: @selector(setTintColor:)])
    {
      _changeHighlight.tintColor     = newColor;
      _changeHighlight.accessibilityLabel =
        [[__T (@"Highlight Color") stringByAppendingString: @" "] stringByAppendingString: textColor];
    }
    else
    {
      _changeHighlight.title = textColor;
    }
    [PKSettings instance].highlightColor     = newColor;
    [PKSettings instance].highlightTextColor = textColor;
    [[PKSettings instance] saveCurrentHighlight];
  }
}

#pragma mark -
#pragma mark UIKeyText methods

//
// we're trying to be a little... sneaky here -- we're treating these
// as keyboard short cuts.

-(void) deleteBackward
{
  return; // we do nothing.
}

-(BOOL) hasText
{
  return YES;
}


-(void)selectVerse: (NSUInteger)theVerse
{
  NSInteger row            = theVerse -1;
  NSUInteger currentBook = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  BOOL curValue;

  PKReference *reference = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:row+1];

  curValue = [_selectedVerses[reference.reference] boolValue];
  _selectedVerses[reference.reference] = [NSNumber numberWithBool: !curValue];
  
  [self.tableView reloadData];
}

-(NSUInteger)lowestSelectedVerse
{
  NSArray *allSelectedVerses = [[_selectedVerses allKeys]
                                // FIX ISSUE #60
                                sortedArrayUsingComparator:
                                ^NSComparisonResult (id obj1, id obj2)
                                {
                                  NSUInteger verse1 = [PKReference verseFromReferenceString: obj1];
                                  NSUInteger verse2 = [PKReference verseFromReferenceString: obj2];

                                  if (verse1 > verse2)
                                  {
                                    return NSOrderedDescending;
                                  }

                                  if (verse1 < verse2)
                                  {
                                    return NSOrderedAscending;
                                  }
                                  return NSOrderedSame;
                                }
                               ];
  NSUInteger lowestIndex = 999;
  for (NSString *key in allSelectedVerses)
  {
    if ([_selectedVerses[key] boolValue])
    {
      NSUInteger index = [PKReference verseFromReferenceString:key];
      if (index < lowestIndex)
        lowestIndex = index;
    }
  }
      
  if (lowestIndex<999)
    return lowestIndex;
  else
    return 0;
}

-(NSUInteger)highestSelectedVerse
{
  NSArray *allSelectedVerses = [[_selectedVerses allKeys]
                                // FIX ISSUE #60
                                sortedArrayUsingComparator:
                                ^NSComparisonResult (id obj1, id obj2)
                                {
                                  NSUInteger verse1 = [PKReference verseFromReferenceString: obj1];
                                  NSUInteger verse2 = [PKReference verseFromReferenceString: obj2];

                                  if (verse1 > verse2)
                                  {
                                    return NSOrderedDescending;
                                  }

                                  if (verse1 < verse2)
                                  {
                                    return NSOrderedAscending;
                                  }
                                  return NSOrderedSame;
                                }
                               ];

  NSUInteger highestIndex = 0;
  for (NSString *key in allSelectedVerses)
  {
    if ([_selectedVerses[key] boolValue])
    {
      NSUInteger index = [PKReference verseFromReferenceString:key];
      if (index > highestIndex)
        highestIndex = index;
    }
  }
      
  if (highestIndex>0)
    return highestIndex;
  else
    return 0;
}

-(NSArray<UIKeyCommand *> *)keyCommands {
//  if ([[UIKeyCommand class] respondsToSelector:@selector(keyCommandWithInput:modifierFlags:action:discoverabilityTitle:)]) {
//    return @[
//             [UIKeyCommand keyCommandWithInput:@"f" modifierFlags:0 action:@selector(onKeySearch:) discoverabilityTitle:__T(@"Search Bible")]
//             ];
//  } else {
    return @[
             [UIKeyCommand keyCommandWithInput:@"f" modifierFlags:0 action:@selector(onKeySearch:)],
             ];
//  }
}

-(void) onKeySearch:(UIKeyCommand *) sender {
  [self searchBible:nil];
}

-(void) insertText:(NSString *)text
{
  //
  // Key mappings:
  //
  // t = scroll to top
  // q = scroll up by 3
  // w = scroll up
  // s = scroll down
  // z = scroll down by 3
  // b = scroll to bottom
  //
  // W = extend selection up by one; and scroll to top of selection
  // S = extend selection down by one; and scroll to bottom of selection
  //
  // cC= clear selection
  //
  // h = add highlights to selected verses
  // H = remove highlights from selected verse
  //
  // nN= add/view annotation (uses first verse in selection)
  //
  // eE= explain first verse in selection
  //
  // aA= previous chapter
  // dD= next chapter
  //
  NSUInteger currentBook = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  NSUInteger currentGreekVerseCount   = [_currentGreekChapter count];
  NSUInteger currentEnglishVerseCount = [_currentEnglishChapter count];
  NSUInteger currentVerseCount        = MAX(currentGreekVerseCount, currentEnglishVerseCount);

  static NSDate *lastKeypress;
  NSTimeInterval lastKeypressInterval = [lastKeypress timeIntervalSince1970];
  
  NSDate *thisKeypress = [NSDate date];
  NSTimeInterval thisKeypressInterval = [thisKeypress timeIntervalSince1970];
  

  if (thisKeypressInterval > lastKeypressInterval + 0.5)
  {
    lastKeypress = thisKeypress;

    [self saveTopVerse];
    NSInteger theRow = PKSettings.instance.topVerse - 1; // rows are 0; verses are 1-based
    //
    // SCROLL TO TOP
    if ([text isEqualToString:@"t"])
    {
      [self scrollToVerse:0 withAnimation:YES afterDelay:0.0];
    }
    //
    // SELECT UP ONE VERSE
    if ([text isEqualToString:@"W"])
    {
      NSUInteger theLowestVerse = [self lowestSelectedVerse];
      if (theLowestVerse<1)
      {
        theLowestVerse = theRow+1;
      }
      theLowestVerse--;
      if (theLowestVerse>0)
      {
        [self selectVerse:theLowestVerse];
        [self scrollToVerse:(int)theLowestVerse withAnimation:YES afterDelay:0.0f];
      }
    }
    //
    // UP ONE VERSE
    if ([text isEqualToString:@"w"])
    {
      theRow--;
      [self scrollToVerse:(int)theRow+1 withAnimation:YES afterDelay:0.0f];
    }
    //
    // UP THREE VERSES
    if ([text isEqualToString:@"q"])
    {
      theRow = theRow - 3;
      if (theRow < 0) theRow = 0;
      [self scrollToVerse:(int)theRow+1 withAnimation:YES afterDelay:0.0f];
    }
    //
    // DOWN ONE VERSE
    if ([text isEqualToString:@"s"])
    {
      theRow++;
      [self scrollToVerse:(int)theRow+1 withAnimation:YES afterDelay:0.0f];
    }
    //
    // DOWN THREE VERSES
    if ([text isEqualToString:@"z"])
    {
      theRow = theRow + 3;
      if (theRow > currentVerseCount-1) theRow = currentVerseCount - 1;
      [self scrollToVerse:(int)theRow+1 withAnimation:YES afterDelay:0.0f];
    }
    //
    // SELECT DOWN ONE VERSE
    if ([text isEqualToString:@"S"])
    {
      NSUInteger theHighestVerse = [self highestSelectedVerse];
      if (theHighestVerse<1)
      {
        theHighestVerse = theRow;
      }
      theHighestVerse++;
      if (theHighestVerse>0 && theHighestVerse <= currentVerseCount)
      {
        [self selectVerse:theHighestVerse];
        [self scrollToVerse:(int)theHighestVerse withAnimation:YES afterDelay:0.0f];
      }
    }
    //
    // SCROLL TO BOTTOM
    if ([text isEqualToString:@"b"])
    {
      [self scrollToVerse:(int)currentVerseCount withAnimation:YES afterDelay:0.0f];
    }
    //
    // HIGHLIGHT
    if ([text isEqualToString:@"h"])
    {
      [self highlightSelection:nil];
    }
    //
    // REMOVE HIGHLIGHT
    if ([text isEqualToString:@"H"])
    {
      [self removeHighlights:nil];
    }
    //
    // CLEAR SELECTION
    if ([text isEqualToString:@"c"] ||
        [text isEqualToString:@"C"])
    {
      [self clearSelection:nil];
    }
    //
    // ANNOTATE
    if ([text isEqualToString:@"n"] ||
        [text isEqualToString:@"N"])
    {
      NSUInteger lowestVerse = 0;
      lowestVerse = [self lowestSelectedVerse];
      if (lowestVerse>0)
      {
        _selectedPassage = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:lowestVerse];
        [self doAnnotate:nil];
      }
    }
    //
    // EXPLAIN
    if ([text isEqualToString:@"e"] ||
        [text isEqualToString:@"E"])
    {
      NSUInteger lowestVerse = 0;
      lowestVerse = [self lowestSelectedVerse];
      if (lowestVerse>0)
      {
        _selectedPassage = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:lowestVerse];
        [self explainVerse:nil];
      }
    }
    //
    // COPY LEFT
    if ([text isEqualToString:@"["])
    {
      [self copyLeft:nil];
    }
    if ([text isEqualToString:@"]"])
    //
    // COPY RIGHT
    {
      [self copyRight:nil];
    }
    //
    // PREVIOUS CHAPTER
    if ([text isEqualToString:@"a"] ||
        [text isEqualToString:@"A"])
    {
      __weak typeof(self) weakSelf = self;
      [self performBlockAsynchronouslyInForeground:^(void)
        {
          [weakSelf previousChapter];
        }
        afterDelay:0.01
      ];
    }
    //
    // NEXT CHAPTER
    if ([text isEqualToString:@"d"] ||
        [text isEqualToString:@"D"])
    {
      __weak typeof(self) weakSelf = self;
      [self performBlockAsynchronouslyInForeground:^(void)
        {
          [weakSelf nextChapter];
        }
        afterDelay:0.01
      ];
    }
    

  }

}


@end
