//
//  PKBibleViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
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
#import "PKRootViewController.h"
#import "PKSearchViewController.h"
#import "PKHistoryViewController.h"
#import "PKHistory.h"
#import "PKNotes.h"
#import "TSMiniWebBrowser.h"
#import "PKTableViewCell.h"
#import "PKLabel.h"
#import "TestFlight.h"
#import "NSString+FontAwesome.h"
#import <QuartzCore/QuartzCore.h>
#import "PKLayoutController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "PKPortraitNavigationController.h"
#import "PopoverView/PopoverView.h"
//#import "FWTPopoverView.h"
#import "PKStrongs.h"
#import "SVProgressHUD.h"

@interface PKBibleViewController ()

@property UIDeviceOrientation lastKnownOrientation;
@property int reusableLabelQueuePosition;
@end

@implementation PKBibleViewController

@synthesize reusableLabels;
@synthesize reusableLabelQueuePosition;
@synthesize lastKnownOrientation;
@synthesize currentGreekChapter;
@synthesize currentEnglishChapter;

@synthesize formattedGreekChapter;
@synthesize formattedEnglishChapter;

@synthesize formattedGreekVerseHeights;
@synthesize formattedEnglishVerseHeights;

@synthesize selectedVerses;
@synthesize highlightedVerses;

@synthesize cellHeights;
@synthesize cells;

@synthesize changeHighlight;
@synthesize formattedCells;
@synthesize ourMenu;
@synthesize ourMenuState;
@synthesize selectedWord;

@synthesize ourPopover;

@synthesize selectedPassage;

@synthesize theCachedCell;

@synthesize fullScreen;
@synthesize btnRegularScreen;

@synthesize theWordTag;
@synthesize dirty;

@synthesize tableTitle;

@synthesize previousChapterButton;
@synthesize nextChapterButton;

@synthesize PO;

@synthesize theWordIndex;

@synthesize toggleStrongsBtn;
@synthesize toggleMorphologyBtn;
@synthesize toggleTranslationBtn;

@synthesize leftTextSelect;
@synthesize rightTextSelect;
@synthesize bibleTextIDs;

//@synthesize popoverView;

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
-(void)displayBook: (int) theBook andChapter: (int) theChapter andVerse: (int) theVerse
{
  //[( (PKRootViewController *)self.parentViewController.parentViewController )showWaitingIndicator];
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

  PKWait(
    [self loadChapter: theChapter forBook: theBook];
    [self reloadTableCache];
    [(PKHistory *)[PKHistory instance] addPassagewithBook: theBook andChapter: theChapter andVerse: theVerse];
    [self notifyChangedHistory];
    ( (PKSettings *)[PKSettings instance] ).topVerse = theVerse;

    if (theVerse > 1)
    {
      [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: theVerse -
                                               1 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: NO];
    }
    else
    {
      [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: NO];
    }
    UITabBarController *tbc = (UITabBarController *)self.parentViewController.parentViewController;
    tbc.selectedIndex = 0;
    );
}

/**
 *
 * Load the desired chapter for the desired book. Also saves the settings.
 *
 */
-(void)loadChapter: (int) theChapter forBook: (int) theBook
{
  // clear selectedVerses
  selectedVerses             = [[NSMutableDictionary alloc] init];
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
  [( (PKRootViewController *)self.parentViewController.parentViewController )showLeftSwipeIndicator];
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(
    int currentBook = [[PKSettings instance] currentBook];
    int currentChapter = [[PKSettings instance] currentChapter];

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

    [self loadChapter: currentChapter forBook: currentBook];
    [self reloadTableCache];
    [(PKHistory *)[PKHistory instance] addPassagewithBook: currentBook andChapter: currentChapter andVerse: 1];
    [self notifyChangedHistory];

    [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: NO];

    );
}

/**
 *
 * Loads the previous chapter before the current one
 *
 */
-(void)previousChapter
{
  [( (PKRootViewController *)self.parentViewController.parentViewController )showRightSwipeIndicator];
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(

    int currentBook = [[PKSettings instance] currentBook];
    int currentChapter = [[PKSettings instance] currentChapter];

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

    [self loadChapter: currentChapter forBook: currentBook];
    [self reloadTableCache];
    [(PKHistory *)[PKHistory instance] addPassagewithBook: currentBook andChapter: currentChapter andVerse: [PKBible
                                                                                                             countOfVersesForBook:
                                                                                                             currentBook forChapter
                                                                                                             : currentChapter]];
    [self notifyChangedHistory];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [PKBible countOfVersesForBook: currentBook forChapter:
                                                                           currentChapter] -
                                             1 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: NO];

    );
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
  highlightedVerses = [(PKHighlights *)[PKHighlights instance] allHighlightedPassagesForBook: currentBook
                                                                                  andChapter: currentChapter];
}

-(PKLabel *) deQueueReusableLabel
{
  PKLabel *theLabel = nil;

  reusableLabelQueuePosition++;

  if ([reusableLabels count] > reusableLabelQueuePosition)
  {
    theLabel = [reusableLabels objectAtIndex: reusableLabelQueuePosition];
    return theLabel;
  }
  else
  {
    theLabel = [[PKLabel alloc] init];
    [reusableLabels addObject: theLabel];
    return theLabel;
  }
}

/**
 *
 * load the current chapter. We will render all the UILabels as well to reduce scrolling delays.
 *
 */
-(void)loadChapter
{
  BOOL parsed               = NO;
  reusableLabelQueuePosition = -1;
  NSUInteger currentBook    = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  NSUInteger currentBible   = [[PKSettings instance] greekText];
  parsed = (currentBible == PK_BIBLETEXT_BYZP
            || currentBible == PK_BIBLETEXT_TRP
            || currentBible == PK_BIBLETEXT_WHP);

  NSDate *startTime;
  NSDate *endTime;
  NSDate *tStartTime;
  NSDate *tEndTime;

  tStartTime            = [NSDate date];
  self.title            = [[PKBible nameForBook: currentBook] stringByAppendingFormat: @" %i", currentChapter];
  tableTitle.text       = self.title;
  startTime             = [NSDate date];
  currentGreekChapter   = [PKBible getTextForBook: currentBook forChapter: currentChapter forSide: 1];
  currentEnglishChapter = [PKBible getTextForBook: currentBook forChapter: currentChapter forSide: 2];
  endTime               = [NSDate date];

  // now, get the formatting for both sides, verse by verse
  // greek side first
  startTime                  = [NSDate date];
  formattedGreekChapter      = [[NSMutableArray alloc] init];
  formattedGreekVerseHeights = [[NSMutableArray alloc] init];
  CGFloat greekHeightIPhone;

  for (int i = 0; i < [currentGreekChapter count]; i++)
  {
    NSArray *formattedText = [PKBible formatText: [currentGreekChapter objectAtIndex: i]
                                       forColumn: 1 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: 0.0];

    [formattedGreekChapter addObject:
     formattedText
    ];

    [formattedGreekVerseHeights addObject:
     [NSNumber numberWithFloat: [PKBible formattedTextHeight: formattedText withParsings: parsed]]
    ];
  }
  endTime = [NSDate date];

  // english next
  startTime                    = [NSDate date];
  formattedEnglishChapter      = [[NSMutableArray alloc] init];
  formattedEnglishVerseHeights = [[NSMutableArray alloc] init];

  for (int i = 0; i < [currentEnglishChapter count]; i++)
  {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
         || UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) )
    {
      greekHeightIPhone = 0.0;
    }
    else
    {
      if (i < formattedGreekVerseHeights.count)
      {
        greekHeightIPhone = [formattedGreekVerseHeights[i] floatValue];
      }
      else
      {
        greekHeightIPhone = 0.0;
      }
    }

    NSArray *formattedText = [PKBible formatText: [currentEnglishChapter objectAtIndex: i]
                                       forColumn: 2 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: greekHeightIPhone];

    [formattedEnglishChapter addObject:
     formattedText
    ];
    [formattedEnglishVerseHeights addObject:
     [NSNumber numberWithFloat: [PKBible formattedTextHeight: formattedText withParsings: parsed]]
    ];
  }
  endTime  = [NSDate date];
  tEndTime = [NSDate date];
  // now, create all our UILabels here, so we don't have to do it while generating a cell.

  formattedCells = [[NSMutableArray alloc] init];
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

  for (int i = 0; i < MAX([currentGreekChapter count], [currentEnglishChapter count]); i++)
  {
    // for each verse (i)

    NSUInteger row = i;

    NSArray *formattedGreekVerse;

    if (row < [formattedGreekChapter count])
    {
      formattedGreekVerse = [formattedGreekChapter objectAtIndex: row];
    }
    else
    {
      formattedGreekVerse = nil;
    }
    NSArray *formattedEnglishVerse;

    if (row < [formattedEnglishChapter count])
    {
      formattedEnglishVerse = [formattedEnglishChapter objectAtIndex: row];
    }
    else
    {
      formattedEnglishVerse = nil;
    }

    CGFloat greekColumnWidth      = [PKBible columnWidth: 1 forBounds: self.view.bounds];
    NSMutableArray *theLabelArray = [[NSMutableArray alloc] init];

    // insert Greek labels
    for (int i = 0; i < [formattedGreekVerse count]; i++)
    {
      NSArray *theWordElement = [formattedGreekVerse objectAtIndex: i];
      NSString *theWord       = [theWordElement objectAtIndex: 0];
      int theWordType         = [[theWordElement objectAtIndex: 1] intValue];
      CGFloat wordX           = [[theWordElement objectAtIndex: 2] floatValue];
      CGFloat wordY           = [[theWordElement objectAtIndex: 3] floatValue];
      CGFloat wordW           = [[theWordElement objectAtIndex: 4] floatValue];
      CGFloat wordH           = [[theWordElement objectAtIndex: 5] floatValue];
      int theStrongsValue     = [theWordElement[6] intValue];

      PKLabel *theLabel       = [self deQueueReusableLabel]; 
      [theLabel setFrame: CGRectMake(wordX, wordY, wordW, wordH)];
      theLabel.text         = theWord; //#573920 87, 57, 32
      theLabel.textColor    = [PKSettings PKTextColor];
      theLabel.shadowColor  = [PKSettings PKLightShadowColor];
      theLabel.shadowOffset = CGSizeMake(0, 1);

      if (theWordType == 5)
      {
        theLabel.textColor = [PKSettings PKInterlinearColor];
      }

      if (theWordType == 10)
      {         //#204057
        theLabel.textColor = [PKSettings PKStrongsColor];
      }

      if (theWordType == 20)
      {         //#305720
        theLabel.textColor = [PKSettings PKMorphologyColor];
      }
      theLabel.font      = theFont;
      theLabel.tag       = theWordType; // so we can avoid certain words later
      theLabel.secondTag = theStrongsValue;       // so we can always get the strong's #

      if (theWordType == 0)
      {
        theLabel.font = theBoldFont;
      }
      [theLabelArray addObject: theLabel];
    }

    // insert English labels
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
         && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) )
    {
      greekColumnWidth = 0;
    }

    for (int i = 0; i < [formattedEnglishVerse count]; i++)
    {
      NSArray *theWordElement = [formattedEnglishVerse objectAtIndex: i];
      NSString *theWord       = [theWordElement objectAtIndex: 0];
      CGFloat wordX           = [[theWordElement objectAtIndex: 2] floatValue];
      CGFloat wordY           = [[theWordElement objectAtIndex: 3] floatValue];
      CGFloat wordW           = [[theWordElement objectAtIndex: 4] floatValue];
      CGFloat wordH           = [[theWordElement objectAtIndex: 5] floatValue];

      PKLabel *theLabel       = [self deQueueReusableLabel]; 
      [theLabel setFrame: CGRectMake(wordX + greekColumnWidth, wordY, wordW, wordH)];
      theLabel.text         = theWord;
      theLabel.textColor    = [PKSettings PKTextColor];
      theLabel.shadowColor  = [PKSettings PKLightShadowColor];
      theLabel.shadowOffset = CGSizeMake(0, 1);
      theLabel.font         = theFont;
      theLabel.tag          = -1;
      theLabel.secondTag    = -1;
      [theLabelArray addObject: theLabel];
    }
    [formattedCells addObject: theLabelArray];
  }

  [self loadHighlights];
  [SVProgressHUD dismiss];
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
  cellHeights = nil;

  cellHeights = [[NSMutableArray alloc] init];

  for (int row = 0; row < MAX([formattedGreekChapter count], [formattedEnglishChapter count]); row++)
  {
    [cellHeights addObject: [NSNumber numberWithFloat: [self heightForRowAtIndexPath: [NSIndexPath indexPathForRow: row inSection:
                                                                                       0]]]];
  }
  [self.tableView reloadData];
  [self calculateShadows];
}

-(void) saveTopVerse
{
  NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];

  if ([indexPaths count] > 0)
  {
    ( (PKSettings *)[PKSettings instance] ).topVerse = [[indexPaths objectAtIndex: 0] row] + 1;
  }
}

-(void) scrollToTopVerseWithAnimation
{
  // attempt to fix issue #37
  PKWaitDelay(0.05, {
                if ([[PKSettings instance] topVerse] > 1)
                {
                  if ([self.tableView numberOfRowsInSection: 0] >  1)
                  {
                    if ([[PKSettings instance] topVerse] - 1 < [self.tableView numberOfRowsInSection: 0])
                    {
                      [self.tableView scrollToRowAtIndexPath:
                       [NSIndexPath                    indexPathForRow:
                        [[PKSettings instance] topVerse] - 1 inSection: 0]
                                            atScrollPosition: UITableViewScrollPositionTop animated: YES];
                    }
                  }
                }
                else
                {
                  [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: YES];
                }
              }
              );
}

-(void) scrollToTopVerse
{
  // attempt to fix issue #37
  PKWaitDelay(0.05, {
                if ([[PKSettings instance] topVerse] > 1)
                {
                  if ([self.tableView numberOfRowsInSection: 0] >  1)
                  {
                    if ([[PKSettings instance] topVerse] - 1 < [self.tableView numberOfRowsInSection: 0])
                    {
                      [self.tableView scrollToRowAtIndexPath:
                       [NSIndexPath                    indexPathForRow:
                        [[PKSettings instance] topVerse] - 1 inSection: 0]
                                            atScrollPosition: UITableViewScrollPositionTop animated: NO];
                    }
                  }
                }
                else
                {
                  [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: NO];
                }
              }
              );
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
    reusableLabelQueuePosition = -1;
    reusableLabels             = [[NSMutableArray alloc] init];
  }
  return self;
}

-(void) updateAppearanceForTheme
{
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  tableTitle.textColor           = [PKSettings PKTextColor];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
  {
    tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] size: 44];
  }
  else
  {
    tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] size: 28];
  }

  // set the button titles
  [previousChapterButton setImage: [PKSettings PKImageLeftArrow] forState: UIControlStateNormal];
  [previousChapterButton setImage: [PKSettings PKImageLeftArrow] forState: UIControlStateHighlighted];
  [previousChapterButton setImage: [PKSettings PKImageLeftArrow] forState: UIControlStateDisabled];
  [previousChapterButton setImage: [PKSettings PKImageLeftArrow] forState: UIControlStateSelected];

  [nextChapterButton setImage: [PKSettings PKImageRightArrow] forState: UIControlStateNormal];
  [nextChapterButton setImage: [PKSettings PKImageRightArrow] forState: UIControlStateHighlighted];
  [nextChapterButton setImage: [PKSettings PKImageRightArrow] forState: UIControlStateDisabled];
  [nextChapterButton setImage: [PKSettings PKImageRightArrow] forState: UIControlStateSelected];

  [self reloadTableCache];
}

-(void) bibleTextChanged
{
  leftTextSelect.title         = [[PKBible titleForTextID: [[PKSettings instance] greekText]] stringByAppendingString: @" ▾"];
  rightTextSelect.title        = [[PKBible titleForTextID: [[PKSettings instance] englishText]] stringByAppendingString: @" ▾"];

  // this will have to change, but for now it will do.
  toggleStrongsBtn.enabled     = [[PKSettings instance] greekText] != PK_BIBLETEXT_TIS;
  toggleMorphologyBtn.enabled  = [[PKSettings instance] greekText] != PK_BIBLETEXT_TIS;
  toggleTranslationBtn.enabled = [[PKSettings instance] greekText] == PK_BIBLETEXT_WHP;
}

// ISSUE #61
-(void)viewDidAppear: (BOOL) animated
{
  [self becomeFirstResponder]; // respond to copy command from keyboard?
}

/**
 *
 * Whenever we appear, we need to reload the chapter. (Highlights / Settings / etc., may have changed)
 *
 */
-(void)viewWillAppear: (BOOL) animated
{
  if (dirty
      || lastKnownOrientation != [[UIDevice currentDevice] orientation])
  {
    lastKnownOrientation = [[UIDevice currentDevice] orientation];
    [self loadChapter];
    [self reloadTableCache];
    [(PKHistory *)[PKHistory instance] addPassagewithBook: [[PKSettings instance] currentBook] andChapter: [[PKSettings instance]
                                                                                                            currentChapter]
     andVerse: [[PKSettings instance] topVerse]];
    [self notifyChangedHistory];
    [self scrollToTopVerse];
    [self calculateShadows];
    dirty = NO;
  }
  [self bibleTextChanged];
  [self updateAppearanceForTheme];
}

-(void)viewWillDisappear: (BOOL) animated
{
  int theVerse = [[[self.tableView indexPathsForVisibleRows] objectAtIndex: 0] row] + 1;
  ( (PKSettings *)[PKSettings instance] ).topVerse = theVerse;
  [[PKSettings instance] saveCurrentReference];

  if (fullScreen)
  {
    [self goRegularScreen: nil];
  }
}

/**
 *
 * Set up our background color, add gestures for going forward and backward, add the longpress recognizer
 * and handle a small bar on the left that will allow for swiping open the left-side navigation.
 *
 */
-(void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  dirty = YES;
  lastKnownOrientation           = [[UIDevice currentDevice] orientation];
  [TestFlight passCheckpoint: @"VIEW_BIBLE"];
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

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
  selectedVerses = [[NSMutableDictionary alloc] init];

  // add navbar items
  UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                      initWithImage: [UIImage imageNamed: @"Listb.png"]
                                              style: UIBarButtonItemStylePlain
                                             target: self
                                             action: @selector(revealToggle:)];

  changeReference.accessibilityLabel = __T(@"Go to passage");
  // need a highlight item
  changeHighlight                    = [[UIBarButtonItem alloc]
                                        initWithTitle: @""
                                                style: UIBarButtonItemStylePlain
                                               target: self action: @selector(changeHighlightColor:)];
  [changeHighlight setTitleTextAttributes: [[NSDictionary alloc]
                                            initWithObjectsAndKeys: [UIColor blackColor], UITextAttributeTextShadowColor,
                                            [UIColor whiteColor], UITextAttributeTextColor,
                                            [UIFont fontWithName: kFontAwesomeFamilyName size: 22], UITextAttributeFont,
                                            nil] forState: UIControlStateNormal];

  changeHighlight.accessibilityLabel = __T(@"Highlight Color");

  if (![changeHighlight respondsToSelector: @selector(setTintColor:)])
  {
    changeHighlight.title = ( (PKSettings *)[PKSettings instance] ).highlightTextColor;
  }

  UIBarButtonItem *fontSelect = [[UIBarButtonItem alloc]
                                 initWithTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-font"]
                                         style: UIBarButtonItemStylePlain target: self action: @selector(fontSelect:)];
  [fontSelect setTitleTextAttributes: [[NSDictionary alloc]
                                       initWithObjectsAndKeys: [UIColor blackColor], UITextAttributeTextShadowColor,
                                       [UIColor whiteColor], UITextAttributeTextColor,
                                       [UIFont fontWithName: kFontAwesomeFamilyName size: 22], UITextAttributeFont,
                                       nil] forState: UIControlStateNormal];
  fontSelect.accessibilityLabel = __T(@"Layout");

  leftTextSelect                = [[UIBarButtonItem alloc]
                                   initWithTitle: [[PKBible titleForTextID: [[PKSettings instance] greekText]]
                                                   stringByAppendingString: @" ▾"]
                                   style: UIBarButtonItemStylePlain target: self action: @selector(textSelect:)];

  if ([self.navigationItem respondsToSelector: @selector(setLeftBarButtonItems:)])
  {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
      self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: changeReference,
                                                fontSelect,
                                                changeHighlight,
                                                leftTextSelect, nil];
    }
    else
    {
      self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: changeReference,
                                                changeHighlight,
                                                nil];
    }
  }
  else
  {
    changeHighlight.style = UIBarButtonItemStyleBordered;
    changeReference.style = UIBarButtonItemStyleBordered;
    NSArray *buttons = [NSArray arrayWithObjects: changeReference, changeHighlight, nil];
    UIToolbar *tb    = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 150, 44)];
    tb.backgroundColor    = [UIColor clearColor];
    tb.barStyle           = UIBarStyleBlack;
    [tb setItems: buttons animated: NO];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: tb];
  }

  UIBarButtonItem *goFullScreen = [[UIBarButtonItem alloc]
                                   initWithTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-resize-full"]
                                           style: UIBarButtonItemStylePlain
                                          target: self action: @selector(goFullScreen:)];
  [goFullScreen setTitleTextAttributes: [[NSDictionary alloc]
                                         initWithObjectsAndKeys: [UIColor blackColor], UITextAttributeTextShadowColor,
                                         [UIColor whiteColor], UITextAttributeTextColor,
                                         [UIFont fontWithName: kFontAwesomeFamilyName size: 22], UITextAttributeFont,
                                         nil] forState: UIControlStateNormal];
  goFullScreen.accessibilityLabel = __T(@"Enter Full Screen");

  // build the toggle items
  toggleStrongsBtn = [[UIBarButtonItem alloc]
                      initWithTitle: @"#"
                              style: UIBarButtonItemStylePlain
                             target: self action: @selector(toggleStrongs:)];
  toggleStrongsBtn.accessibilityLabel = __T(@"Toggle Strong's Numbers");

  toggleMorphologyBtn                 = [[UIBarButtonItem alloc]
                                         initWithTitle: @"M"
                                                 style: UIBarButtonItemStylePlain
                                                target: self action: @selector(toggleMorphology:)];
  toggleMorphologyBtn.accessibilityLabel = __T(@"Toggle Morphology");

  toggleTranslationBtn                   = [[UIBarButtonItem alloc]
                                            initWithTitle: @"T"
                                                    style: UIBarButtonItemStylePlain
                                                   target: self action: @selector(toggleTranslation:)];
  toggleTranslationBtn.accessibilityLabel = __T(@"Toggle Translation");

  goFullScreen.accessibilityLabel         = __T(@"Enter Full Screen");

  rightTextSelect = [[UIBarButtonItem alloc]
                     initWithTitle: [[PKBible titleForTextID: [[PKSettings instance] englishText]] stringByAppendingString: @" ▾"]
                             style: UIBarButtonItemStylePlain target: self action: @selector(textSelect:)];

  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    self.navigationItem.rightBarButtonItems = @[goFullScreen,
                                                toggleStrongsBtn, toggleMorphologyBtn, toggleTranslationBtn,
                                                rightTextSelect
                                              ];
  }
  else
  {
    self.navigationItem.rightBarButtonItem = goFullScreen;
  }

  if ([changeHighlight respondsToSelector: @selector(setTintColor:)])
  {
    changeHighlight.tintColor          = [[PKSettings instance] highlightColor];
    changeHighlight.accessibilityLabel = __T(@"Highlight Color");
  }

  // create the header and footer views
  UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 88)];
  tableTitle            = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 88)];
  previousChapterButton = [UIButton buttonWithType: UIButtonTypeCustom];
  [previousChapterButton setFrame: CGRectMake(10, 22, 44, 44)];

  UIView *footerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, 64)];
  nextChapterButton = [UIButton buttonWithType: UIButtonTypeCustom];
  [nextChapterButton setFrame: CGRectMake(self.tableView.frame.size.width - 54, 10, 44, 44)];

  // set the button titles
  [previousChapterButton setImage: [UIImage imageNamed: @"ArrowLeft.png"] forState: UIControlStateNormal];
  [previousChapterButton setImage: [UIImage imageNamed: @"ArrowLeft.png"] forState: UIControlStateHighlighted];
  [previousChapterButton setImage: [UIImage imageNamed: @"ArrowLeft.png"] forState: UIControlStateDisabled];
  [previousChapterButton setImage: [UIImage imageNamed: @"ArrowLeft.png"] forState: UIControlStateSelected];

  [nextChapterButton setImage: [UIImage imageNamed: @"ArrowRight.png"] forState: UIControlStateNormal];
  [nextChapterButton setImage: [UIImage imageNamed: @"ArrowRight.png"] forState: UIControlStateHighlighted];
  [nextChapterButton setImage: [UIImage imageNamed: @"ArrowRight.png"] forState: UIControlStateDisabled];
  [nextChapterButton setImage: [UIImage imageNamed: @"ArrowRight.png"] forState: UIControlStateSelected];

  // set the targets
  [previousChapterButton addTarget: self action: @selector(previousChapter) forControlEvents: UIControlEventTouchUpInside];
  [nextChapterButton addTarget: self action: @selector(nextChapter) forControlEvents: UIControlEventTouchUpInside];

  nextChapterButton.autoresizingMask       = UIViewAutoresizingFlexibleLeftMargin;

  previousChapterButton.alpha              = 0.5f;
  nextChapterButton.alpha                  = 0.5f;

  previousChapterButton.accessibilityLabel = __T(@"Previous Chapter");
  nextChapterButton.accessibilityLabel     = __T(@"Next Chapter");

  // set the table title up
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
  {
    tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] size: 44];
  }
  else
  {
    tableTitle.font = [UIFont fontWithName: [[PKSettings instance] textFontFace] size: 28];
  }
  tableTitle.textAlignment    = UITextAlignmentCenter;
  tableTitle.textColor        = [PKSettings PKTextColor];
  tableTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  tableTitle.backgroundColor  = [UIColor clearColor];

  // add the items to our views
  [headerView addSubview: tableTitle];
  [headerView addSubview: previousChapterButton];

  [footerView addSubview: nextChapterButton];

  // add the views to the table
  self.tableView.tableHeaderView = headerView;
  self.tableView.tableFooterView = footerView;
}

/**
 *
 * Determine what actions can occur when a menu is displayed.
 *
 */
-(BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
  if (ourMenuState == 0)
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
      if (!selectedWord)
      {
        return NO;
      }                                                                                 // word must not be nil

      if (theWordTag == 0)
      {
        return theWordIndex > -1;
      }                                                                                                // if greek, must have a
                                                                                                       // strongs#
      return (theWordTag < 20);                                               // otherwise, we must not be a morphological word
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
      return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    }

    if ( SYSTEM_VERSION_LESS_THAN(@"5.0") )   // < ios 5
    {
      if ( action == @selector(highlightSelection:) )
      {
        return YES;
      }

      if ( action == @selector(removeHighlights:) )
      {
        return YES;
      }

      if ( action == @selector(searchBible:) )
      {
        return selectedWord != nil;
      }

      if ( action == @selector(searchStrongs:) )
      {
        return selectedWord != nil;
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
        return selectedWord != nil;
      }
    }
  }

  if (ourMenuState == 1)    // we're asking about highlighting
  {
    if ( action == @selector(highlightSelection:) )
    {
      return YES;
    }

    if ( action == @selector(removeHighlights:) )
    {
      return YES;
    }
  }

  if (ourMenuState == 2)   // we're asking about searching
  {
    if ( action == @selector(searchBible:) )
    {
      return selectedWord != nil;
    }

    if ( action == @selector(searchStrongs:) )
    {
      return selectedWord != nil;
    }
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
  currentGreekChapter          = nil;
  currentEnglishChapter        = nil;

  formattedGreekChapter        = nil;
  formattedEnglishChapter      = nil;

  formattedGreekVerseHeights   = nil;
  formattedEnglishVerseHeights = nil;

  selectedVerses               = nil;
  highlightedVerses            = nil;

  changeHighlight              = nil;
  formattedCells               = nil;
  ourMenu = nil;

  selectedWord                 = nil;
  selectedPassage              = nil;

  ourPopover                   = nil;

  theCachedCell                = nil;
  cells = nil;
  cellHeights                  = nil;

  btnRegularScreen             = nil;

  reusableLabels               = nil;
  reusableLabelQueuePosition   = -1;

  tableTitle                   = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

/**
 *
 * Since our orientation (can) determine how much content is visible, when it changes, we
 * have to re-calc it. Obvious visually, but better doing it after the orientation, than
 * in the middle and have the rotation visually /stop/ for a few ms.
 *
 */
-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  lastKnownOrientation = [[UIDevice currentDevice] orientation];
  [self calculateShadows];
  // get the top verse so we can scroll back to it after the rotation change
  int theVerse = [[[self.tableView indexPathsForVisibleRows] objectAtIndex: 0] row] + 1;

  [self loadChapter];
  [self reloadTableCache];

  if (theVerse > 1)
  {
    [self.tableView scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:
      theVerse - 1      inSection: 0]
                          atScrollPosition: UITableViewScrollPositionTop animated: YES];
  }
  else
  {
    [self.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: YES];
  }
}

-(void)calculateShadows
{
  CGFloat topOpacity       = 0.0f;
  CGFloat theContentOffset = (self.tableView.contentOffset.y);

  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  topOpacity = (theContentOffset / 15) * 0.5;

  [( (PKRootViewController *)self.parentViewController.parentViewController ) showTopShadowWithOpacity: topOpacity];

  CGFloat bottomOpacity = 0.0f;

  theContentOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y -
                     self.tableView.bounds.size.height;

  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  bottomOpacity = (theContentOffset / 15) * 0.5;

  [( (PKRootViewController *)self.parentViewController.parentViewController ) showBottomShadowWithOpacity: bottomOpacity];
}

-(void)scrollViewDidScroll: (UIScrollView *) scrollView
{
  [self calculateShadows];
}

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
  int currentGreekVerseCount   = [currentGreekChapter count];
  int currentEnglishVerseCount = [currentEnglishChapter count];
  int currentVerseCount        = MAX(currentGreekVerseCount, currentEnglishVerseCount);

  return currentVerseCount;
}

/**
 *
 * Return the height for each row
 *
 */
-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  return [[cellHeights objectAtIndex: indexPath.row] floatValue];
}

-(CGFloat) heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row           = [indexPath row];
  // the height is the MAX of both the formattedGreekVerseHeights and EnglishVerseHeights for row
  float greekVerseHeight   = 0.0;
  float englishVerseHeight = 0.0;

  if (row < [formattedGreekVerseHeights count])
  {
    greekVerseHeight = [[formattedGreekVerseHeights objectAtIndex: row] floatValue];
  }

  if (row < [formattedEnglishVerseHeights count])
  {
    englishVerseHeight = [[formattedEnglishVerseHeights objectAtIndex: row] floatValue];
  }

  float theMax = MAX(greekVerseHeight, englishVerseHeight);

  // if we have a note to display, add to theMax
  int theBook      = [[PKSettings instance] currentBook];
  int theChapter   = [[PKSettings instance] currentChapter];

  NSArray *theNote =
    [[PKNotes instance] getNoteForPassage: [PKBible stringFromBook: theBook forChapter: theChapter forVerse: row + 1]];

  if (theNote != nil
      && [[PKSettings instance] showNotesInline])
  {
    NSString *theNoteText = [NSString stringWithFormat: @"%@ - %@",
                             [theNote objectAtIndex: 0],
                             [theNote objectAtIndex: 1]];
    CGSize theSize        = [theNoteText sizeWithFont: [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                                       size: [[PKSettings instance] textFontSize]]
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width - 20, 999)];
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
  NSString *passage         = [PKBible stringFromBook: currentBook forChapter: currentChapter forVerse: row + 1];
  curValue = [[selectedVerses objectForKey: passage] boolValue];

  if (curValue)
  {
    pkCell.selectedColor = [PKSettings PKSelectionColor];
  }
  else
  {
    pkCell.selectedColor = nil;
  }

  // are we highlighted?
  if ([highlightedVerses objectForKey: [NSString stringWithFormat: @"%i", row + 1]] != nil)
  {
    pkCell.highlightColor = [highlightedVerses objectForKey: [NSString stringWithFormat: @"%i", row + 1]];
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
  //return [cells objectAtIndex:[indexPath row]];
  return [self cellForRowAtIndexPath: indexPath];
}

-(UITableViewCell *) cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
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
  for (UIView *view in cell.subviews)
  {
    [view removeFromSuperview];
  }

  cell.contentMode         = UIViewContentModeRedraw;
  cell.autoresizesSubviews = NO;
  NSUInteger row = [indexPath row];

  /*
     // add in a verse #
     UILabel *theVerseNumber = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width-120, 0, 120, 80)];

     theVerseNumber.text = [NSString stringWithFormat:@"%i", row+1];
     theVerseNumber.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0625];
     theVerseNumber.backgroundColor = [UIColor clearColor];
     theVerseNumber.textAlignment = UITextAlignmentRight;
     theVerseNumber.font = [UIFont fontWithName:@"Helvetica" size:96];
   */
  // and check if we have a note
  int theBook              = [[PKSettings instance] currentBook];
  int theChapter           = [[PKSettings instance] currentChapter];

  NSArray *theNote         =
    [[PKNotes instance] getNoteForPassage: [PKBible stringFromBook: theBook forChapter: theChapter forVerse: row + 1]];

  float greekVerseHeight   = 0.0;
  float englishVerseHeight = 0.0;

  if (row < [formattedGreekVerseHeights count])
  {
    greekVerseHeight = [[formattedGreekVerseHeights objectAtIndex: row] floatValue];
  }

  if (row < [formattedEnglishVerseHeights count])
  {
    englishVerseHeight = [[formattedEnglishVerseHeights objectAtIndex: row] floatValue];
  }

  float theMax = MAX(greekVerseHeight, englishVerseHeight);

  if (theNote != nil
      && [[PKSettings instance] showNotesInline])
  {
    NSString *theNoteText = [NSString stringWithFormat: @"%@ - %@",
                             [theNote objectAtIndex: 0],
                             [theNote objectAtIndex: 1]];
    CGSize theSize        = [theNoteText sizeWithFont: [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                                       size: [[PKSettings instance] textFontSize]]
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width - 20, 999)];
    CGRect theRect        = CGRectMake(10, theMax + 10, self.tableView.bounds.size.width - 20, theSize.height);

    UILabel *theNoteLabel = [[UILabel alloc] initWithFrame: theRect];
    theNoteLabel.text            = theNoteText;
    theNoteLabel.numberOfLines   = 0;
    theNoteLabel.font            = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                   size: [[PKSettings instance] textFontSize]];
    //#502057, 80, 32, 97
    theNoteLabel.textColor       = [PKSettings PKAnnotationColor];
    theNoteLabel.backgroundColor = [UIColor clearColor];
    theNoteLabel.shadowColor     = [PKSettings PKLightShadowColor];
    theNoteLabel.shadowOffset    = CGSizeMake(0, 1);
    theNoteLabel.tag             = 99;
    [cell addSubview: theNoteLabel];
  }
  else
  {
    if (theNote != nil)
    {
      // need to indicate /somehow/ that we have a note.
      UIImageView *theImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"SlantedPencil.png"]];
      theImage.frame = CGRectMake(self.tableView.bounds.size.width - 52, theMax - 42, 32, 32);
      [cell addSubview: theImage];
    }
  }

  NSMutableArray *formattedCell = [formattedCells objectAtIndex: row];

  NSMutableString *theAString   = [[NSMutableString alloc] init];

  for (int i = 0; i < [formattedCell count]; i++)
  {
    [theAString appendString: [[formattedCell objectAtIndex: i] text]];
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
  if (ourMenu.isMenuVisible)
  {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    return;
  }

  NSUInteger row            = [indexPath row];
  BOOL curValue;
  NSUInteger currentBook    = [[PKSettings instance] currentBook];
  NSUInteger currentChapter = [[PKSettings instance] currentChapter];
  NSString *passage         = [PKBible stringFromBook: currentBook forChapter: currentChapter forVerse: row + 1];
  PKTableViewCell *newCell  = (PKTableViewCell *)[tableView cellForRowAtIndexPath: indexPath];

  // toggle the selection state

  curValue = [[selectedVerses objectForKey: passage] boolValue];
  [selectedVerses setObject: [NSNumber numberWithBool: !curValue] forKey: passage];
  curValue = [[selectedVerses objectForKey: passage] boolValue];

  if (curValue)
  {
    newCell.selectedColor = [PKSettings PKSelectionColor];
  }
  else
  {
    newCell.selectedColor = nil;
  }

  // are we highlighted?
  if ([highlightedVerses objectForKey: [NSString stringWithFormat: @"%i", row + 1]] != nil)
  {
    newCell.highlightColor = [highlightedVerses objectForKey: [NSString stringWithFormat: @"%i", row + 1]];
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
    ZUUIRevealController *rc = (ZUUIRevealController *)self.parentViewController.parentViewController.parentViewController;

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
  ZUUIRevealController *rc = (ZUUIRevealController *)self.parentViewController.parentViewController.parentViewController;

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
    // restore our menu items after a strongs view shows
    ourMenu           = [UIMenuController sharedMenuController];
    ourMenu.menuItems = [NSArray arrayWithObjects:
// ISSUE #61
                         //            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")      action:@selector(copySelection:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Highlight") action: @selector(askHighlight:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Annotate")  action: @selector(doAnnotate:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Search")    action: @selector(askSearch:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Define")    action: @selector(defineWord:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Explain")   action: @selector(explainVerse:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Layout")   action: @selector(textSettings:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Clear")     action: @selector(clearSelection:)],
                         // handle second-tier items
                         [[UIMenuItem alloc] initWithTitle: __T(@"Add Highlight") action: @selector(highlightSelection:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Remove")        action: @selector(removeHighlights:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Search Bible")  action: @selector(searchBible:)],
                         [[UIMenuItem alloc] initWithTitle: __T(@"Search Strong's") action: @selector(searchStrongs:)]
                         , nil];

    CGPoint p              = [gestureRecognizer locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: p];    // nil if no row
    UILabel *theWordLabel  = nil;
    selectedWord        = nil;
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
      theWordTag = -1;

      for (int i = 0; i < [theCell.labels count]; i++)
      {
        PKLabel *theView = [theCell.labels objectAtIndex: i];

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
              theWordTag   = theView.tag;
              theWordIndex = theView.secondTag;
              theWord      = ( (UILabel *)theView ).text;
              theWordLabel = (UILabel *)theView;
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
          theWordTag   = -1;
          theWordIndex = -1;
          theWord      = nil;
          theWordLabel = nil;
        }
      }
      selectedWord = theWord;

      // select the row
      BOOL curValue;
      NSUInteger currentBook    = [[PKSettings instance] currentBook];
      NSUInteger currentChapter = [[PKSettings instance] currentChapter];
      NSString *passage         = [PKBible stringFromBook: currentBook forChapter: currentChapter forVerse: row + 1];

      selectedPassage = passage;

      PKTableViewCell *newCell = (PKTableViewCell *)[self.tableView cellForRowAtIndexPath: indexPath];
      [selectedVerses setObject: [NSNumber numberWithBool: YES] forKey: passage];
      curValue = [[selectedVerses objectForKey: passage] boolValue];

      if (curValue)
      {
        newCell.selectedColor = [PKSettings PKSelectionColor];
      }
      else
      {
        newCell.selectedColor = nil;
      }

      // are we highlighted?
      if ([highlightedVerses objectForKey: [NSString stringWithFormat: @"%i", row + 1]] != nil)
      {
        newCell.highlightColor = [highlightedVerses objectForKey: [NSString stringWithFormat: @"%i", row + 1]];
      }
      else       // not highlighted, be transparent.
      {
        newCell.highlightColor = nil;
      }
      [newCell setNeedsDisplay];

      if (selectedWord != nil)
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
        UILabel *theNewWord = [[UILabel alloc] initWithFrame: theNewRect];
        theNewWord.alpha           = 0.0f;
        theNewWord.backgroundColor = [UIColor whiteColor];
        theNewWord.textColor       = [PKSettings PKTextColor];
        theNewWord.font            = theWordLabel.font;
        theNewWord.text            = theWordLabel.text;

        theNewWord.layer.cornerRadius = 10;

        theNewWord.textAlignment      = UITextAlignmentCenter;
        [theCell addSubview: theNewWord];
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

      ourMenuState = 0;   // show entire menu (not second-tier)
      [self becomeFirstResponder];
      [ourMenu update];   // just in case
      [ourMenu setTargetRect: theRect inView: self.tableView];
      [ourMenu setMenuVisible: YES animated: YES];
    }
  }
}

#pragma mark -
#pragma mark miscellaneous selectors (called from popovers, buttons, etc.)

-(void) textSelect: (id) sender
{
  if (PO)
  {
    [PO dismissPopoverAnimated: NO];
  }
  NSArray *bibleTextNames;
  NSString *title;
  int theTag;

  if (sender == leftTextSelect)
  {
    bibleTextIDs   = [PKBible availableOriginalTexts: PK_TBL_BIBLES_ID];
    bibleTextNames = [PKBible availableOriginalTexts: PK_TBL_BIBLES_NAME];
    title          = __T(@"Greek Text");
    theTag         = 1898;
  }
  else
  {
    bibleTextIDs   = [PKBible availableHostTexts: PK_TBL_BIBLES_ID];
    bibleTextNames = [PKBible availableHostTexts: PK_TBL_BIBLES_NAME];
    title          = __T(@"English Text");
    theTag         = 1899;
  }

  // dismiss our popover if we've got one
  [ourPopover dismissWithClickedButtonIndex: -1 animated: YES];

  UIActionSheet *theActionSheet = [[UIActionSheet alloc] init];
  theActionSheet.title    = title;
  theActionSheet.delegate = self;

  for (int i = 0; i < bibleTextIDs.count; i++)
  {
    [theActionSheet addButtonWithTitle: bibleTextNames[i]];
  }

  [theActionSheet addButtonWithTitle: __T(@"Cancel")];
  theActionSheet.cancelButtonIndex = bibleTextIDs.count;
  theActionSheet.tag               = theTag; // text chooser
  ourPopover = theActionSheet;

  [theActionSheet showFromBarButtonItem: sender animated: YES];
}

-(void) textSettings: (id) sender
{
  [self fontSelect: nil];
}

-(void) toggleStrongs: (id) sender
{
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(
  [self saveTopVerse];
  ( (PKSettings *)[PKSettings instance] ).showStrongs = !( (PKSettings *)[PKSettings instance] ).showStrongs;
  [[PKSettings instance] saveSettings];
  [self loadChapter];
  [self reloadTableCache];
  [self scrollToTopVerseWithAnimation];
  );
}

-(void) toggleMorphology: (id) sender
{
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(
  [self saveTopVerse];
  ( (PKSettings *)[PKSettings instance] ).showMorphology = !( (PKSettings *)[PKSettings instance] ).showMorphology;
  [[PKSettings instance] saveSettings];
  [self loadChapter];
  [self reloadTableCache];
  [self scrollToTopVerseWithAnimation];
  );
}

-(void) toggleTranslation: (id) sender
{
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(
  [self saveTopVerse];
  ( (PKSettings *)[PKSettings instance] ).showInterlinear = !( (PKSettings *)[PKSettings instance] ).showInterlinear;
  [[PKSettings instance] saveSettings];
  [self loadChapter];
  [self reloadTableCache];
  [self scrollToTopVerseWithAnimation];
  );
}

-(void) goFullScreen: (id) sender
{
  if (PO)
  {
    [PO dismissPopoverAnimated: NO];
  }
  ( (PKRootViewController *)self.parentViewController.parentViewController ).aViewHasFullScreen = YES;
  [self.navigationController setNavigationBarHidden: YES animated: YES];

  CGRect theRect = ( (PKRootViewController *)self.parentViewController.parentViewController ).tabBar.frame;
  theRect.origin.y    += 49;
  [( (PKRootViewController *)self.parentViewController.parentViewController ).tabBar setFrame: theRect];
  theRect              = self.parentViewController.parentViewController.view.frame;
  //theRect.origin.y -= 20;
  theRect.size.height += 49;
  [self.parentViewController.parentViewController.view setFrame: theRect];
  [( (PKRootViewController *)self.parentViewController.parentViewController ) calcShadowPosition: [[UIDevice currentDevice]
                                                                                                   orientation]];

  self.fullScreen     = YES;

  // create a button to get us back!
  theRect             = self.parentViewController.parentViewController.view.frame;
  theRect.origin.x    = theRect.size.width - 54;
  theRect.origin.y    = 10;
  theRect.size.width  = 44;
  theRect.size.height = 32;

  btnRegularScreen    = [UIButton buttonWithType: UIButtonTypeRoundedRect];

  [btnRegularScreen setFrame: theRect];
  [btnRegularScreen setTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-resize-small"] forState:
   UIControlStateNormal];
  [btnRegularScreen setTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-resize-small"] forState:
   UIControlStateHighlighted];
  [btnRegularScreen setTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-resize-small"] forState:
   UIControlStateDisabled];
  [btnRegularScreen setTitle: [NSString fontAwesomeIconStringForIconIdentifier: @"icon-resize-small"] forState:
   UIControlStateSelected];

  btnRegularScreen.titleLabel.font = [UIFont fontWithName: kFontAwesomeFamilyName size: 22];

  btnRegularScreen.accessibilityLabel   = __T(@"Leave Full Screen");

  btnRegularScreen.titleLabel.textColor = [PKSettings PKBaseUIColor];
  btnRegularScreen.layer.opacity        = 0.5;
  btnRegularScreen.autoresizingMask     = UIViewAutoresizingFlexibleLeftMargin;
  [btnRegularScreen addTarget: self action: @selector(goRegularScreen:) forControlEvents: UIControlEventTouchUpInside];
  [self.parentViewController.view addSubview: btnRegularScreen];
  [self.parentViewController.view bringSubviewToFront: btnRegularScreen];
}

-(void) goRegularScreen: (id) sender
{
  [btnRegularScreen removeFromSuperview];
  btnRegularScreen = nil;

  ( (PKRootViewController *)self.parentViewController.parentViewController ).aViewHasFullScreen = NO;
  [self.navigationController setNavigationBarHidden: NO animated: YES];

  CGRect theRect = ( (PKRootViewController *)self.parentViewController.parentViewController ).tabBar.frame;
  theRect.origin.y    -= 49;
  [( (PKRootViewController *)self.parentViewController.parentViewController ).tabBar setFrame: theRect];

  theRect              = self.parentViewController.parentViewController.view.frame;
  // theRect.origin.y += 20;
  theRect.size.height -= 49;
  [self.parentViewController.parentViewController.view setFrame: theRect];

  PKWaitDelay(
    2000,
    [( (PKRootViewController *)self.parentViewController.parentViewController ) calcShadowPosition: [[UIDevice currentDevice]
                                                                                                     orientation]];
    );

  self.fullScreen = NO;
}

-(void) selectAll: (id) sender
{
  selectedVerses = [[NSMutableDictionary alloc] init]; // clear selection

  int currentGreekVerseCount   = [currentGreekChapter count];
  int currentEnglishVerseCount = [currentEnglishChapter count];
  int currentVerseCount        = MAX(currentGreekVerseCount, currentEnglishVerseCount);

  // add all the verses to the selection
  for (int i = 0; i < currentVerseCount; i++)
  {
    NSUInteger currentBook    = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    NSString *passage         = [PKBible stringFromBook: currentBook forChapter: currentChapter forVerse: i + 1];

    [selectedVerses setObject: [NSNumber numberWithBool: YES] forKey: passage];
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
  ourMenuState = 1;
  [ourMenu update];
  [ourMenu setMenuVisible: YES animated: YES];
}

/**
 *
 * When "Search" is pressed on the menu, we need to present new options.
 *
 */
-(void) askSearch: (id) sender
{
  ourMenuState = 2;
  [ourMenu update];
  [ourMenu setMenuVisible: YES animated: YES];
}

/**
 *
 * Display a drop-down for the highlight color button
 *
 */
-(void) changeHighlightColor: (id) sender
{
  if (PO)
  {
    [PO dismissPopoverAnimated: NO];
  }
  [ourPopover dismissWithClickedButtonIndex: -1 animated: YES];

  UIActionSheet *theActionSheet = [[UIActionSheet alloc]
                                            initWithTitle: __T(@"Choose Color")
                                                 delegate: self
                                        cancelButtonTitle: __T(@"Cancel")
                                   destructiveButtonTitle: nil
                                        otherButtonTitles: __T(@"Yellow"), __T(@"Green"), __T(@"Magenta"),
                                   __T(@"Pink"),   __T(@"Blue"),    nil];
  theActionSheet.tag = 1999;   // color chooser
  ourPopover         = theActionSheet;
  [theActionSheet showFromBarButtonItem: sender animated: YES];
}

/**
 *
 * Clear the user's selection
 *
 */
-(void) clearSelection: (id) sender
{
  selectedVerses = [[NSMutableDictionary alloc] init];   // clear selection
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
  if (PO)
  {
    [PO dismissPopoverAnimated: NO];
  }
  [ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  [(ZUUIRevealController *)[[PKAppDelegate instance] rootViewController] revealToggle: sender];
}

/**
 *
 * let the left-hand navigation know that highlights have changed
 *
 */
-(void) notifyChangedHighlights
{
  [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 1] reloadHighlights];
}

/**
 *
 * let the left-hand navigation know that history has changed
 *
 */
-(void) notifyChangedHistory
{
  [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex: 3] reloadHistory];
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
  for (NSString *key in selectedVerses)
  {
    if ([[selectedVerses objectForKey: key] boolValue])
    {
      [(PKHighlights *)[PKHighlights instance]
       removeHighlightFromPassage: key];
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
  [self copySelection: nil];
}

-(void) copySelection: (id) sender
{
  NSMutableString *theText   = [[NSMutableString alloc] init];
  // FIX ISSUE #43b
  NSArray *allSelectedVerses = [[selectedVerses allKeys]
                                // FIX ISSUE #60
                                sortedArrayUsingComparator:
                                ^NSComparisonResult (id obj1, id obj2)
                                {
                                  int verse1 = [PKBible verseFromString: obj1];
                                  int verse2 = [PKBible verseFromString: obj2];

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
    if ([[selectedVerses objectForKey: key] boolValue])
    {
      int theVerse = [PKBible verseFromString: key];

      if (theVerse <= [currentEnglishChapter count])
      {
        // FIX ISSUE #43a
        [theText appendString: [currentEnglishChapter objectAtIndex: theVerse - 1]];
      }
      [theText appendString: @"\n"];

      if (theVerse <= [currentGreekChapter count])
      {
        // FIX ISSUE #43a
        [theText appendString: [currentGreekChapter objectAtIndex: theVerse - 1]];
      }

      int theBook      = [[PKSettings instance] currentBook];
      int theChapter   = [[PKSettings instance] currentChapter];
      NSArray *theNote =
        [[PKNotes instance] getNoteForPassage: [PKBible stringFromBook: theBook forChapter: theChapter forVerse: theVerse]];

      if (theNote != nil)
      {
        [theText appendFormat: @"\n%@ - %@", [theNote objectAtIndex: 0], [theNote objectAtIndex: 1]];
      }
      [theText appendString: @"\n\n"];
    }
  }

  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  pasteBoard.string = theText;

  [self clearSelection: nil];
}

/**
 *
 * Highlight the selection with the currently selected highlight color
 *
 */
-(void) highlightSelection: (id) sender
{
  // we're highlighting the selection
  for (NSString *key in selectedVerses)
  {
    if ([[selectedVerses objectForKey: key] boolValue])
    {
      [(PKHighlights *)[PKHighlights instance]
       setHighlight: ( (PKSettings *)[PKSettings instance] ).highlightColor
         forPassage: key];
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
  // if the word is a greek word with a strong's #, we'll look it up first.
  if (theWordTag == 0
      && theWordIndex > -1)
  {
    ZUUIRevealController *rc  = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKStrongsController *svc  = [[[rvc.viewControllers objectAtIndex: 2] viewControllers] objectAtIndex: 0];
    [svc doSearchForTerm: [@"G" stringByAppendingString: [[NSNumber numberWithInt: theWordIndex] stringValue]] byKeyOnly: YES];
    return;
  }

  // if the word is a strong's #, we'll do that lookup instead.
  if ([[selectedWord substringToIndex: 1] isEqualToString: @"G"]
      && [[selectedWord substringFromIndex: 1] intValue] > 0)
  {
    [self searchStrongs: sender];
    return;
  }

  UIReferenceLibraryViewController *dictionary = [[UIReferenceLibraryViewController alloc] initWithTerm: selectedWord];

  if (dictionary != nil)
  {
    // FIX ISSUE #46
    dictionary.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController: dictionary animated: YES];
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
  ZUUIRevealController *rc    = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
  PKRootViewController *rvc   = (PKRootViewController *)[rc frontViewController];
  PKSearchViewController *svc = [[[rvc.viewControllers objectAtIndex: 1] viewControllers] objectAtIndex: 0];

  [svc doSearchForTerm: selectedWord];
}

/**
 *
 * Switches to the Strong's Lookup tab and searches for the selectedWord. If the word is a
 * strong's number, we indicate that we only want that value (not partial matches).
 *
 */
-(void)searchStrongs: (id) sender
{
  BOOL isStrongs            = [[selectedWord substringToIndex: 1] isEqualToString: @"G"]
                              && [[selectedWord substringFromIndex: 1] intValue] > 0;

  ZUUIRevealController *rc  = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
  PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
  PKStrongsController *svc  = [[[rvc.viewControllers objectAtIndex: 2] viewControllers] objectAtIndex: 0];

  [svc doSearchForTerm: selectedWord byKeyOnly: isStrongs];
}

/**
 *
 * Explains a verse by loading bible.cc's website.
 *
 */
-(void)explainVerse: (id) sender
{
  int theBook                 = [PKBible bookFromString: selectedPassage];
  int theChapter              = [PKBible chapterFromString: selectedPassage];
  int theVerse                = [PKBible verseFromString: selectedPassage];

  NSString *theTransformedURL = [NSString stringWithFormat: @"http://bible.cc/%@/%i-%i.htm",
                                 [[PKBible nameForBook: theBook] lowercaseString],
                                 theChapter, theVerse];
  theTransformedURL = [theTransformedURL stringByReplacingOccurrencesOfString: @" " withString: @"_"];
  NSURL *theURL        = [[NSURL alloc] initWithString: theTransformedURL];
  TSMiniWebBrowser *wb = [[TSMiniWebBrowser alloc] initWithUrl: theURL];
  wb.showURLStringOnActionSheetTitle = YES;
  wb.showPageTitleOnTitleBar         = YES;
  wb.showActionButton                = YES;
  wb.showReloadButton                = YES;
  wb.mode = TSMiniWebBrowserModeModal;
  wb.barStyle = UIBarStyleBlack;
  wb.modalDismissButtonTitle         = __T(@"Done");
  [self presentModalViewController: wb animated: YES];
}

/**
 *
 * creates a NoteEditorViewController, tells it the passage we're annotating, and shows it modally.
 *
 */
-(void)doAnnotate: (id) sender
{
  PKNoteEditorViewController *nevc = [[PKNoteEditorViewController alloc] initWithPassage: selectedPassage];
  UINavigationController *mvnc     = [[UINavigationController alloc] initWithRootViewController: nevc];
  mvnc.modalPresentationStyle = UIModalPresentationFormSheet;

  UINavigationBar *navBar          = [mvnc navigationBar];

  if ([navBar respondsToSelector: @selector(setBackgroundImage:)])
  {
    [navBar setBackgroundImage: [UIImage imageNamed: @"BlueNavigationBar.png"] forBarMetrics: UIBarMetricsDefault];
    [navBar setTitleTextAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor blackColor],
                                     UITextAttributeTextShadowColor,
                                     [UIColor whiteColor], UITextAttributeTextColor, nil]];
  }

  [self presentModalViewController: mvnc animated: YES];
}

-(void)fontSelect: (id) sender
{
  [ourPopover dismissWithClickedButtonIndex: -1 animated: YES];
  PKLayoutController *LC = [[PKLayoutController alloc] init];
  LC.delegate = self;

  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
  {
    if (PO)
    {
      [PO dismissPopoverAnimated: NO];
    }
    PO = [[UIPopoverController alloc] initWithContentViewController: LC];
    [PO setPopoverContentSize: CGSizeMake(320, 420) animated: NO];
    [PO presentPopoverFromBarButtonItem: (UIBarButtonItem *)sender permittedArrowDirections: UIPopoverArrowDirectionAny animated:
     YES];
  }
  else
  {
    PKPortraitNavigationController *mvnc = [[PKPortraitNavigationController alloc] initWithRootViewController: LC];
    mvnc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController: mvnc animated: YES];
  }
}

#pragma mark -
#pragma mark layout responder
-(void) didChangeLayout: (PKLayoutController *) sender
{
  // the settings have changed, update ourselves...
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(
  [self saveTopVerse];
  [self updateAppearanceForTheme];
  [self loadChapter];
  [self reloadTableCache];
  [self scrollToTopVerseWithAnimation];
  );
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
        || buttonIndex == bibleTextIDs.count)
    {
      // cancel; do nothing.
      return;
    }

    int theNewId = [bibleTextIDs[buttonIndex] intValue];

    if (actionSheet.tag == 1898)
    {
      ( (PKSettings *)[PKSettings instance] ).greekText = theNewId;
      leftTextSelect.title =  [[PKBible titleForTextID: theNewId] stringByAppendingString: @" ▾"];
    }
    else
    {
      ( (PKSettings *)[PKSettings instance] ).englishText = theNewId;
      rightTextSelect.title = [[PKBible titleForTextID: theNewId] stringByAppendingString: @" ▾"];
    }
    [[PKSettings instance] saveSettings];
    [self bibleTextChanged];
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  PKWait(
    [self saveTopVerse];
    [self loadChapter];
    [self reloadTableCache];
    [self scrollToTopVerseWithAnimation];
    );
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

    if ([changeHighlight respondsToSelector: @selector(setTintColor:)])
    {
      self.changeHighlight.tintColor     = newColor;
      changeHighlight.accessibilityLabel =
        [[__T (@"Highlight Color") stringByAppendingString: @" "] stringByAppendingString: textColor];
    }
    else
    {
      self.changeHighlight.title = textColor;
    }
    ( (PKSettings *)[PKSettings instance] ).highlightColor     = newColor;
    ( (PKSettings *)[PKSettings instance] ).highlightTextColor = textColor;
    [(PKSettings *)[PKSettings instance] saveCurrentHighlight];
  }
}

@end