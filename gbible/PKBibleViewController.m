
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

#import <QuartzCore/QuartzCore.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface PKBibleViewController ()

@end

@implementation PKBibleViewController
  
    
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

#pragma mark -
#pragma mark Network Connectivity
/* 
from:http://stackoverflow.com/a/7934636/741043
Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
+(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }

            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }


            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs

                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }

            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
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
- (void)displayBook: (int)theBook andChapter: (int)theChapter andVerse: (int)theVerse
{

    [((PKRootViewController *)self.parentViewController.parentViewController ) showWaitingIndicator];
      PKWait(
                [self loadChapter:theChapter forBook:theBook];
                //[self.tableView reloadData];
                [self reloadTableCache];
                [(PKHistory *)[PKHistory instance] addPassagewithBook:theBook andChapter:theChapter andVerse:theVerse];
                [self notifyChangedHistory];
                ((PKSettings *)[PKSettings instance]).topVerse = theVerse;
                [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:theVerse-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                UITabBarController *tbc = (UITabBarController *)self.parentViewController.parentViewController;
                tbc.selectedIndex = 0;
            );
}
/**
 *
 * Load the desired chapter for the desired book. Also saves the settings.
 *
 */
- (void)loadChapter: (int)theChapter forBook: (int)theBook
{
    // clear selectedVerses
    selectedVerses = [[NSMutableDictionary alloc] init];
    PKSettings *theSettings = [PKSettings instance];
    theSettings.currentBook = theBook;
    theSettings.currentChapter = theChapter;
    //[theSettings saveCurrentReference]; -- removed for speed
    [self loadChapter];
}

/**
 *
 * Loads the next chapter after the current one
 *
 */
- (void)nextChapter
{
    [((PKRootViewController *)self.parentViewController.parentViewController ) showLeftSwipeIndicator];
    PKWait(
    int currentBook = [[PKSettings instance] currentBook];
    int currentChapter = [[PKSettings instance] currentChapter];
    
    currentChapter++;
    if (currentChapter > [PKBible countOfChaptersForBook:currentBook])
    {
        // advance the book
        currentChapter = 1;
        currentBook++;
        if (currentBook > 66)
        {
            return; // can't go past the end of the Bible
        }
    }

    
        [self loadChapter: currentChapter forBook: currentBook];
        [self reloadTableCache];
        [(PKHistory *)[PKHistory instance] addPassagewithBook:currentBook andChapter:currentChapter andVerse:1];
        [self notifyChangedHistory];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    );
}

/**
 *
 * Loads the previous chapter before the current one
 *
 */
- (void)previousChapter
{
    [((PKRootViewController *)self.parentViewController.parentViewController ) showRightSwipeIndicator];
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
            return; // can't go before the start of the NT (currently)
        }
        currentChapter = [PKBible countOfChaptersForBook:currentBook];
    }
    
    [self loadChapter: currentChapter forBook: currentBook];
    [self reloadTableCache];
    [(PKHistory *)[PKHistory instance] addPassagewithBook:currentBook andChapter:currentChapter andVerse:1];
    [self notifyChangedHistory];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    );
}

/**
 *
 * load the highlights for this chapter
 *
 */
- (void)loadHighlights
{
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    // load our highlighted verses
    highlightedVerses = [(PKHighlights *)[PKHighlights instance] allHighlightedPassagesForBook: currentBook
                                                                                   andChapter: currentChapter];
}

/**
 *
 * load the current chapter. We will render all the UILabels as well to reduce scrolling delays.
 *
 */
- (void)loadChapter
{
    BOOL parsed = NO;
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    NSUInteger currentBible = [[PKSettings instance] greekText];
    parsed = (currentBible == PK_BIBLETEXT_BYZP || 
              currentBible == PK_BIBLETEXT_TRP || 
              currentBible == PK_BIBLETEXT_WHP);

    NSDate *startTime;
    NSDate *endTime;
    NSDate *tStartTime;
    NSDate *tEndTime;

    tStartTime = [NSDate date];
    self.title = [[PKBible nameForBook:currentBook] stringByAppendingFormat:@" %i",currentChapter];    
    //NSLog (@"---------------------------------------------------");
    //NSLog (@"Timing for passage %@", self.title);
    startTime = [NSDate date];
    currentGreekChapter = [PKBible getTextForBook:currentBook forChapter:currentChapter forSide:1];
    currentEnglishChapter = [PKBible getTextForBook:currentBook forChapter:currentChapter forSide:2];
    endTime = [NSDate date];
    //NSLog (@"Time to read chapter text: %f", [endTime timeIntervalSinceDate:startTime]);

    // now, get the formatting for both sides, verse by verse
    // greek side first
    startTime = [NSDate date];
    formattedGreekChapter = [[NSMutableArray alloc]init];
    formattedGreekVerseHeights = [[NSMutableArray alloc]init];
    for (int i=0; i<[currentGreekChapter count]; i++)
    {
        //NSLog (@"Greek side(%i): Formatting text...", i);
        NSArray *formattedText = [PKBible formatText:[currentGreekChapter objectAtIndex:i] 
                                           forColumn:1 withBounds:self.view.bounds withParsings:parsed];
        
        [formattedGreekChapter addObject: 
            formattedText
        ];
        
        //NSLog (@"Greek side(%i): End Format", i);
        [formattedGreekVerseHeights addObject:
            [NSNumber numberWithFloat: [PKBible formattedTextHeight:formattedText withParsings:parsed]]
        ];
    }
    endTime = [NSDate date];
    //NSLog (@"Time to format Greek chapter text: %f", [endTime timeIntervalSinceDate:startTime]);
    //NSLog (@"... Average time to format verses: %f", [endTime timeIntervalSinceDate:startTime] / [currentGreekChapter count]);
    //NSLog (@"...          For number of verses: %i", [currentGreekChapter count]);
    
    // english next
    startTime = [NSDate date];
    formattedEnglishChapter = [[NSMutableArray alloc]init];
    formattedEnglishVerseHeights = [[NSMutableArray alloc]init];
    for (int i=0; i<[currentEnglishChapter count]; i++)
    {
        //NSLog (@"English side(%i): Formatting text...", i);
        NSArray *formattedText = [PKBible formatText:[currentEnglishChapter objectAtIndex:i] 
                                           forColumn:2 withBounds:self.view.bounds withParsings:parsed];

        [formattedEnglishChapter addObject: 
            formattedText
        ];
        
        //NSLog (@"English side(%i): End Format", i);
        [formattedEnglishVerseHeights addObject:
            [NSNumber numberWithFloat: [PKBible formattedTextHeight:formattedText withParsings:parsed]]
        ];
    }
    endTime = [NSDate date];
    tEndTime = [NSDate date];
    //NSLog (@"Time to format English chapter text: %f", [endTime timeIntervalSinceDate:startTime]);
    //NSLog (@"...   Average time to format verses: %f", [endTime timeIntervalSinceDate:startTime] / [currentEnglishChapter count]);
    //NSLog (@"...            For number of verses: %i", [currentEnglishChapter count]);
    
    //NSLog (@"Total time to format passage: %f", [tEndTime timeIntervalSinceDate:tStartTime]);

    // now, create all our UILabels here, so we don't have to do it while generating a cell.
    
    formattedCells = [[NSMutableArray alloc] init];
    for (int i=0;i<MAX([currentGreekChapter count], [currentEnglishChapter count]);i++)
    {
        // for each verse (i)
        UIFont *theFont = [UIFont fontWithName:[[PKSettings instance] textFontFace]
                                          size:[[PKSettings instance] textFontSize]];
        if (theFont == nil)
        {
            theFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular", [[PKSettings instance] textFontFace]]
                                                  size:[[PKSettings instance] textFontSize]];
        }
        if (theFont == nil)
        {
            theFont = [UIFont fontWithName:@"Helvetica"
                                                  size:[[PKSettings instance] textFontSize]];
        }

        UIFont *theBoldFont = [UIFont fontWithName:[[PKSettings instance] textGreekFontFace]
                                              size:[[PKSettings instance] textFontSize]];
        
        if (theBoldFont == nil)
        {
            theBoldFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular", [[PKSettings instance] textGreekFontFace]]
                                          size:[[PKSettings instance] textFontSize]];
        }
        
        if (theBoldFont == nil)     // just in case there's no alternate
        {
            theBoldFont = theFont;
        }

        NSUInteger row = i;
        
        NSArray *formattedGreekVerse;
        if (row < [formattedGreekChapter count])
        {
            formattedGreekVerse = [formattedGreekChapter objectAtIndex:row];
        }
        else 
        {
            formattedGreekVerse = nil;
        }
        NSArray *formattedEnglishVerse;
        if (row < [formattedEnglishChapter count])
        {
            formattedEnglishVerse = [formattedEnglishChapter objectAtIndex:row];
        }
        else
        {
            formattedEnglishVerse = nil;
        }
        
        CGFloat greekColumnWidth = [PKBible columnWidth:1 forBounds:self.view.bounds];
        NSMutableArray *theLabelArray = [[NSMutableArray alloc]init];

        // insert Greek labels
        for (int i=0; i<[formattedGreekVerse count]; i++)
        {
            NSArray *theWordElement = [formattedGreekVerse objectAtIndex:i];
            NSString *theWord = [theWordElement objectAtIndex:0];
            int theWordType = [[theWordElement objectAtIndex:1] intValue];
            CGFloat wordX = [[theWordElement objectAtIndex:2] floatValue];
            CGFloat wordY = [[theWordElement objectAtIndex:3] floatValue];
            CGFloat wordW = [[theWordElement objectAtIndex:4] floatValue];
            CGFloat wordH = [[theWordElement objectAtIndex:5] floatValue];
            
            UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(wordX, wordY, wordW, wordH)];
            theLabel.text = theWord; //#573920 87, 57, 32
            theLabel.textColor = [UIColor colorWithRed:0.341176 green:0.223529 blue:0.125490 alpha:1.0];
            theLabel.backgroundColor = self.tableView.backgroundColor;
            if (theWordType == 10) 
            {   //#204057
                theLabel.textColor = [UIColor colorWithRed:0.125490 green:0.250980 blue:0.341176 alpha:1.0]; 
            }
            if (theWordType == 20) 
            {   //#305720
                theLabel.textColor = [UIColor colorWithRed:0.188235 green:0.341176 blue:0.125490 alpha:1.0]; 
            }
            theLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
            theLabel.shadowOffset = CGSizeMake(1, 1);
            theLabel.font = theFont;
            if (theWordType == 0)
            {
                theLabel.font = theBoldFont;
            }
            theLabel.accessibilityLanguage = @"en";
            if (theWordType == 0) { theLabel.accessibilityLanguage = @"gr"; }
            theLabel.accessibilityLabel = theWord;
            [theLabelArray addObject:theLabel];
        }
        // insert English labels
        for (int i=0; i<[formattedEnglishVerse count]; i++)
        {

            NSArray *theWordElement = [formattedEnglishVerse objectAtIndex:i];
            NSString *theWord = [theWordElement objectAtIndex:0];
            CGFloat wordX = [[theWordElement objectAtIndex:2] floatValue];
            CGFloat wordY = [[theWordElement objectAtIndex:3] floatValue];
            CGFloat wordW = [[theWordElement objectAtIndex:4] floatValue];
            CGFloat wordH = [[theWordElement objectAtIndex:5] floatValue];
            
            UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(wordX + greekColumnWidth, wordY, wordW, wordH)];
            theLabel.text = theWord;
            theLabel.textColor = [UIColor colorWithRed:0.341176 green:0.223529 blue:0.125490 alpha:1.0];
            theLabel.backgroundColor = self.tableView.backgroundColor;
            theLabel.font = theFont;
            theLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
            theLabel.shadowOffset = CGSizeMake(1, 1);
            theLabel.accessibilityLanguage = @"en";
            theLabel.accessibilityLabel = theWord;
            [theLabelArray addObject:theLabel];
        }
        [formattedCells addObject:theLabelArray];
    }

    [self loadHighlights];

}

/**
 *
 * reloadTableCache nukes the old cellHeights and cells array,
 * recalculates them, and then tells the tableView to reload its data.
 *
 * RE: ISSUE #1
 */
- (void) reloadTableCache
{
    cellHeights = nil;
    
    cellHeights = [[NSMutableArray alloc] init];
    
    for (int row=0; row<MAX([formattedGreekChapter count],[formattedEnglishChapter count]); row++)
    {
        [cellHeights addObject: [NSNumber numberWithFloat:[self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]]];
    }
    
    cells = nil;
    cells = [[NSMutableArray alloc] init];
    for (int row=0; row<MAX([formattedGreekChapter count],[formattedEnglishChapter count]); row++)
    {
        [cells addObject: [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]];
    }
    
    [self.tableView reloadData];
    [self calculateShadows];
}

#pragma mark -
#pragma mark View Lifecycle

/**
 *
 * Set our view title
 *
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Read Bible"];
    }
    return self;
}

/**
 *
 * Whenever we appear, we need to reload the chapter. (Highlights / Settings / etc., may have changed)
 *
 */
- (void)viewWillAppear:(BOOL)animated
{
//    [((PKRootViewController *)self.parentViewController.parentViewController ) showWaitingIndicator];
//    PKWait(
        [self loadChapter];
        //[self.tableView reloadData];
        [self reloadTableCache];
        [self.tableView scrollToRowAtIndexPath: 
             [NSIndexPath indexPathForRow:
                 [[PKSettings instance] topVerse]-1 inSection:0] 
             atScrollPosition:UITableViewScrollPositionTop animated:NO];
       [self calculateShadows];
//    ) ;
}

- (void)viewWillDisappear:(BOOL)animated
{
   int theVerse = [[[self.tableView indexPathsForVisibleRows] objectAtIndex:0] row]+1;
   ((PKSettings *)[PKSettings instance]).topVerse = theVerse;
   [[PKSettings instance] saveCurrentReference];
   
   if (fullScreen)
   {
    [self goRegularScreen:nil];
   }
}

/**
 *
 * Set up our background color, add gestures for going forward and backward, add the longpress recognizer
 * and handle a small bar on the left that will allow for swiping open the left-side navigation.
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [TestFlight passCheckpoint:@"VIEW_BIBLE"];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.945098 green:0.933333 blue:0.898039 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // add our gestures
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didReceiveRightSwipe:)];
    UISwipeGestureRecognizer *swipeLeft =[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(didReceiveLeftSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
    [swipeRight setNumberOfTouchesRequired:1];
    [swipeLeft  setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:swipeRight];
    [self.tableView addGestureRecognizer:swipeLeft];
    
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(didReceiveLongPress:)];
    longPress.minimumPressDuration = 0.5;
    longPress.numberOfTapsRequired = 0;
    longPress.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:longPress];
    
    // init our selectedVeres
    selectedVerses = [[NSMutableDictionary alloc] init];
    
    // add navbar items
    UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                        initWithImage:[UIImage imageNamed:@"Listb.png"] 
                                        style:UIBarButtonItemStylePlain 
                                        target:self //self.parentViewController.parentViewController.parentViewController
                                        action:@selector(revealToggle:)];

    if ([changeReference respondsToSelector:@selector(setTintColor:)])
    {
        changeReference.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    }
    changeReference.accessibilityLabel = @"Go to passage";
    // need a highlight item
    changeHighlight = [[UIBarButtonItem alloc]
                        initWithTitle:@""
                                style:UIBarButtonItemStylePlain 
                               target:self action:@selector(changeHighlightColor:)];
    changeHighlight.accessibilityLabel = @"Highlight Color";
    if (![changeHighlight respondsToSelector:@selector(setTintColor:)])
    {
        changeHighlight.title = ((PKSettings *)[PKSettings instance]).highlightTextColor;
    }
    if ([self.navigationItem respondsToSelector:@selector(setLeftBarButtonItems:)])
    {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:changeReference, 
                                                                           changeHighlight, nil];
    }
    else 
    {
        changeHighlight.style = UIBarButtonItemStyleBordered;
        changeReference.style = UIBarButtonItemStyleBordered;
        NSArray *buttons = [NSArray arrayWithObjects:changeReference, changeHighlight, nil];
        UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
        tb.backgroundColor = [UIColor clearColor];
        [tb setItems:buttons animated:NO];
        
         
       // [tb sizeToFit];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tb];
    }
    
    UIBarButtonItem *goFullScreen = [[UIBarButtonItem alloc] initWithTitle:@"Full Screen" 
                                                                     style:UIBarButtonItemStyleBordered 
                                                                    target:self 
                                                                    action:@selector(goFullScreen:)];
    if ([goFullScreen respondsToSelector:@selector(setTintColor:)])
    {
        goFullScreen.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    }
    self.navigationItem.rightBarButtonItem = goFullScreen;
    // handle pan from left to right to reveal sidebar
    /*CGRect leftFrame = self.view.frame;
    leftFrame.origin.x = 0;
    leftFrame.origin.y = 0;
    leftFrame.size.width=10;
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:leftFrame];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.userInteractionEnabled = YES;
    [self.view addSubview:leftLabel];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self.parentViewController.parentViewController.parentViewController
                                          action:@selector(revealGesture:)];

    [leftLabel addGestureRecognizer:panGesture];*/

    if ([changeHighlight respondsToSelector:@selector(setTintColor:)])
    {
    changeHighlight.tintColor = [[PKSettings instance] highlightColor];
    }
   
    ourMenu = [UIMenuController sharedMenuController];
    ourMenu.menuItems = [NSArray arrayWithObjects:
                            [[UIMenuItem alloc] initWithTitle:@"Copy"      action:@selector(copySelection:)],
                            [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(askHighlight:)],
                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)],
                            [[UIMenuItem alloc] initWithTitle:@"Search"    action:@selector(askSearch:)],
                            [[UIMenuItem alloc] initWithTitle:@"Define"    action:@selector(defineWord:)],
                            [[UIMenuItem alloc] initWithTitle:@"Explain"   action:@selector(explainVerse:)],
                            [[UIMenuItem alloc] initWithTitle:@"Clear"     action:@selector(clearSelection:)],
                            // handle second-tier items
                            [[UIMenuItem alloc] initWithTitle:@"Add Highlight" action:@selector(highlightSelection:)],
                            [[UIMenuItem alloc] initWithTitle:@"Remove"        action:@selector(removeHighlights:)],
                            [[UIMenuItem alloc] initWithTitle:@"Search Bible"  action:@selector(searchBible:)],
                            [[UIMenuItem alloc] initWithTitle:@"Search Strong's" action:@selector(searchStrongs:)]
                         , nil ];

}

/**
 *
 * Determine what actions can occur when a menu is displayed.
 *
 */
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (ourMenuState == 0)
    {
        if (action == @selector(copySelection:))    { return YES; }
        if (action == @selector(doAnnotate:))      { return YES; }
        if (action == @selector(defineWord:))       { return selectedWord!=nil; } 
        if (action == @selector(explainVerse:))     { return [PKBibleViewController hasConnectivity]; }
        if (action == @selector(clearSelection:))   { return YES; }

        if (SYSTEM_VERSION_LESS_THAN(@"5.0")) // < ios 5
        {
            if (action == @selector(highlightSelection:))  { return YES; }
            if (action == @selector(removeHighlights:)) { return YES; }
            if (action == @selector(searchBible:))      { return selectedWord!=nil; }
            if (action == @selector(searchStrongs:))    { return selectedWord!=nil; }
            if (action == @selector(askHighlight:))     { return NO; }
            if (action == @selector(askSearch:))        { return NO; }            
        }
        else
        {
            if (action == @selector(askHighlight:))     { return YES; }
            if (action == @selector(askSearch:))        { return selectedWord!=nil; }
        }
    }
    
    if (ourMenuState == 1)  // we're asking about highlighting
    {
        if (action == @selector(highlightSelection:))  { return YES; }
        if (action == @selector(removeHighlights:)) { return YES; }
    }
    
    if (ourMenuState == 2) // we're asking about searching
    {
        if (action == @selector(searchBible:))      { return selectedWord!=nil; }
        if (action == @selector(searchStrongs:))    { return selectedWord!=nil; }
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
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    currentGreekChapter = nil;
    currentEnglishChapter = nil;
    
    formattedGreekChapter = nil;
    formattedEnglishChapter = nil;
    
    formattedGreekVerseHeights = nil;
    formattedEnglishVerseHeights = nil;
    
    selectedVerses = nil;
    highlightedVerses = nil;
    
    changeHighlight = nil;
    formattedCells = nil;
    ourMenu = nil;
    
    selectedWord = nil;
    selectedPassage =nil;
    
    ourPopover = nil;
    
    theCachedCell = nil;
    cells = nil;
    cellHeights = nil;
    
    btnRegularScreen =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self calculateShadows];
    // get the top verse so we can scroll back to it after the rotation change
    int theVerse = [[[self.tableView indexPathsForVisibleRows] objectAtIndex:0] row]+1;
    
    [self loadChapter];
    [self reloadTableCache];
    [self.tableView scrollToRowAtIndexPath: 
         [NSIndexPath indexPathForRow:
             theVerse-1 inSection:0] 
         atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)calculateShadows
{
    CGFloat topOpacity = 0.0f;
    CGFloat theContentOffset = (self.tableView.contentOffset.y);
    if (theContentOffset > 15)
    {
        theContentOffset = 15;
    }
    topOpacity = (theContentOffset/15)*0.5;
    
    [((PKRootViewController *)self.parentViewController.parentViewController ) showTopShadowWithOpacity:topOpacity];

    CGFloat bottomOpacity = 0.0f;
    
    theContentOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y -
                       self.tableView.bounds.size.height;
    if (theContentOffset > 15)
    {
        theContentOffset = 15;
    }
    bottomOpacity = (theContentOffset/15)*0.5;
    
    [((PKRootViewController *)self.parentViewController.parentViewController ) showBottomShadowWithOpacity:bottomOpacity];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
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
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 *
 * It's possible for the greek & english columns to have a different number of verses. (Romans 13, 16)
 * Return the largest verse count.
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of verses in the current passage
    int currentGreekVerseCount = [currentGreekChapter count];
    int currentEnglishVerseCount = [currentEnglishChapter count];
    int currentVerseCount = MAX(currentGreekVerseCount, currentEnglishVerseCount);
    
    return currentVerseCount;
}

/**
 *
 * Return the height for each row
 *
 */
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[cellHeights objectAtIndex: indexPath.row] floatValue];
}

-(CGFloat) heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    // the height is the MAX of both the formattedGreekVerseHeights and EnglishVerseHeights for row
    float greekVerseHeight = 0.0;
    float englishVerseHeight = 0.0;
    
    if (row < [formattedGreekVerseHeights count])
    {
        greekVerseHeight = [[formattedGreekVerseHeights objectAtIndex:row] floatValue];
    }
    
    if (row < [formattedEnglishVerseHeights count])
    {
        englishVerseHeight = [[formattedEnglishVerseHeights objectAtIndex:row] floatValue] ;
    }
    
    float theMax= MAX( greekVerseHeight, englishVerseHeight );
    //NSLog (@"heightForRowAtIndexPath(%i): Maximum = %f", row, theMax);
    
    // if we have a note to display, add to theMax
    int theBook = [[PKSettings instance] currentBook];
    int theChapter = [[PKSettings instance] currentChapter];

    NSArray *theNote = [[PKNotes instance] getNoteForPassage:[PKBible stringFromBook:theBook forChapter:theChapter forVerse:row+1]];
    if (theNote != nil && [[PKSettings instance] showNotesInline])
    {
        NSString *theNoteText = [NSString stringWithFormat:@"%@ - %@", 
                                 [theNote objectAtIndex:0],
                                 [theNote objectAtIndex:1]];
        CGSize theSize=[theNoteText sizeWithFont:[UIFont fontWithName:[[PKSettings instance] textFontFace]
                                          size:[[PKSettings instance] textFontSize]] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width-20, 999)];
        theMax += 10 + theSize.height + 10;
    }
    
    return theMax;
}

/**
 *
 * Determine the cell's highlighted/selection status
 *
 */
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // determine if the cell is selected
    NSUInteger row = [indexPath row];
    BOOL curValue;
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    
    // are we selected? If so, it takes precedence
    NSString *passage = [PKBible stringFromBook:currentBook forChapter:currentChapter forVerse:row+1];
    curValue = [[selectedVerses objectForKey:passage] boolValue];

    if (curValue)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.75 green:0.875 blue:1.0 alpha:1.0];
    }
    else 
    {
        // are we highlighted?
        
        if ([highlightedVerses objectForKey:[NSString stringWithFormat:@"%i",row+1] ]!=nil)
        {
            cell.backgroundColor = [highlightedVerses objectForKey:[NSString stringWithFormat:@"%i",row+1]];
        }
        else // not highlighted, be transparent.
        {
            cell.backgroundColor = self.tableView.backgroundColor;
        }
    }
    
    // all our subviews need to change to the background color
    for (UIView *view in cell.subviews)
    {
        view.backgroundColor = cell.backgroundColor;

    }
    
    
    
}

/**
 *
 * Render the cell. We're pre-calcing the layout, so this is pretty fast.
 *
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
#warning - do we need to include a deque?
    return [cells objectAtIndex:[indexPath row]];

}

-(UITableViewCell *) cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bibleCellID = @"PKBibleCellID";
    UITableViewCell *cell = nil; //[tableView dequeueReusableCellWithIdentifier:bibleCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:bibleCellID];
    }
    // need to remove the cell's subviews, if they exist...
    for (UIView *view in cell.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger row = [indexPath row];
    
    // add in a verse #
    UILabel *theVerseNumber = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width-120, 0, 120, 80)];

    theVerseNumber.text = [NSString stringWithFormat:@"%i", row+1];
    theVerseNumber.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0625];
    theVerseNumber.backgroundColor = [UIColor clearColor];
    theVerseNumber.textAlignment = UITextAlignmentRight;
    theVerseNumber.font = [UIFont fontWithName:@"Helvetica" size:96];
    
    // and check if we have a note
    int theBook = [[PKSettings instance] currentBook];
    int theChapter = [[PKSettings instance] currentChapter];

    NSArray *theNote = [[PKNotes instance] getNoteForPassage:[PKBible stringFromBook:theBook forChapter:theChapter forVerse:row+1]];

    float greekVerseHeight = 0.0;
    float englishVerseHeight = 0.0;
    
    if (row < [formattedGreekVerseHeights count])
    {
        greekVerseHeight = [[formattedGreekVerseHeights objectAtIndex:row] floatValue];
    }
    
    if (row < [formattedEnglishVerseHeights count])
    {
        englishVerseHeight = [[formattedEnglishVerseHeights objectAtIndex:row] floatValue] ;
    }
    
    float theMax= MAX( greekVerseHeight, englishVerseHeight );

    if (theNote != nil && [[PKSettings instance] showNotesInline])
    {


        NSString *theNoteText = [NSString stringWithFormat:@"%@ - %@", 
                                 [theNote objectAtIndex:0],
                                 [theNote objectAtIndex:1]];
        CGSize theSize=[theNoteText sizeWithFont:[UIFont fontWithName:[[PKSettings instance] textFontFace]
                                          size:[[PKSettings instance] textFontSize]] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width-20, 999)];
        CGRect theRect = CGRectMake(10, theMax + 10, self.tableView.bounds.size.width-20, theSize.height);
        
        UILabel *theNoteLabel = [[UILabel alloc] initWithFrame:theRect];
        theNoteLabel.text = theNoteText;
        theNoteLabel.numberOfLines = 0;
        theNoteLabel.font = [UIFont fontWithName:[[PKSettings instance] textFontFace]
                                          size:[[PKSettings instance] textFontSize]];
                                          //#502057, 80, 32, 97
        theNoteLabel.textColor = [UIColor colorWithRed:.313725 green:0.125490 blue:0.380392 alpha:1.0];
        theNoteLabel.backgroundColor = self.tableView.backgroundColor;
        theNoteLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        theNoteLabel.shadowOffset = CGSizeMake(1, 1);
        [cell addSubview:theNoteLabel];
    }
    else 
    {
        if (theNote != nil)
        {
            // need to indicate /somehow/ that we have a note.
            UIImageView *theImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pencil.png"]];
            theImage.frame = CGRectMake(self.tableView.bounds.size.width-52, theMax-42, 32, 32);
            [cell addSubview:theImage];
        }
    }
    

    NSMutableArray *formattedCell = [formattedCells objectAtIndex:row];
    
    NSMutableString *theAString = [[NSMutableString alloc] init];
    
    for (int i=0; i<[formattedCell count]; i++)
    {
        [cell addSubview:[formattedCell objectAtIndex:i]];
        [theAString appendString:[[formattedCell objectAtIndex:i] text]];
        [theAString appendString:@" "];
    }
    //[cell addSubview:theVerseNumber];
    
    cell.accessibilityLabel = theAString;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/**
 *
 * If the user taps the row, we change the selection status.
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if we have a menu open, we don't want to change anything....
    if (ourMenu.isMenuVisible)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    NSUInteger row = [indexPath row];
    BOOL curValue;
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    NSString *passage = [PKBible stringFromBook:currentBook forChapter:currentChapter forVerse:row+1];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    // toggle the selection state

    curValue = [[selectedVerses objectForKey:passage] boolValue];
    [selectedVerses setObject:[NSNumber numberWithBool:!curValue] forKey:passage];
    curValue = [[selectedVerses objectForKey:passage] boolValue];

    if (curValue)
    {
        newCell.backgroundColor = [UIColor colorWithRed:0.75 green:0.875 blue:1.0 alpha:1.0];
    }
    else 
    {
        // are we highlighted?
        
        if ([highlightedVerses objectForKey:[NSString stringWithFormat:@"%i",row+1] ]!=nil)
        {
            newCell.backgroundColor = [highlightedVerses objectForKey:[NSString stringWithFormat:@"%i",row+1]];
        }
        else // not highlighted, be transparent.
        {
            newCell.backgroundColor = self.tableView.backgroundColor;
        }

    }
    for (UIView *view in newCell.subviews)
    {
        view.backgroundColor = newCell.backgroundColor;

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UISwipeGestureRecognizer
/**
 *
 * We swiped right, load the previous chapter
 *
 */
-(void) didReceiveRightSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    if (p.x < 75)
    {
        // show the sidebar, if not visible
        ZUUIRevealController *rc = (ZUUIRevealController*) self.parentViewController.parentViewController.parentViewController;
        if ( [rc currentFrontViewPosition] == FrontViewPositionLeft )
        {
            [rc revealToggle:nil];
            return;
        }
    }
    [self previousChapter];
//    [self.tableView reloadData];
}

/**
 *
 * We swiped left, load the next chapter
 *
 */
-(void) didReceiveLeftSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
//    CGPoint p = [gestureRecognizer locationInView:self.tableView];
//    if (p.x < 75)
//    {
        // hide the sidebar, if visible
        ZUUIRevealController *rc = (ZUUIRevealController*) self.parentViewController.parentViewController.parentViewController;
        if ( [rc currentFrontViewPosition] == FrontViewPositionRight )
        {
            [rc revealToggle:nil];
            return;
        }
//    }
    //NSDate *startTime = [NSDate date];
    [self nextChapter];
    //NSDate *endTime = [NSDate date];
    //NSLog (@"Time to go to next chapter: %f", [endTime timeIntervalSinceDate:startTime]);
    //startTime = [NSDate date];
//    [self.tableView reloadData];
    //endTime = [NSDate date];
    //NSLog (@"Time to reload data: %f", [endTime timeIntervalSinceDate:startTime]);
    //startTime = [NSDate date];
    //endTime = [NSDate date];
    //NSLog (@"Time to scroll to top: %f", [endTime timeIntervalSinceDate:startTime]);
}

/**
 *
 * We long-pressed on a cell. Determine the cell (and the word we're over: TODO)
 * and open the long-press popover
 *
 */
-(void) didReceiveLongPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p]; // nil if no row
        
        selectedWord = nil;
        
        if (indexPath != nil)
        {
            NSUInteger row = [indexPath row];

            // determine the word we're closest to
            float minDistance = 999;
            UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
            CGPoint wp = [gestureRecognizer locationInView:theCell];
            NSString *theWord = nil;
            for (int i=0;i<[theCell.subviews count]; i++)
            {
                UIView *theView = [theCell.subviews objectAtIndex:i];
                CGRect theRect = theView.frame;
                
                CGPoint theCenter = CGPointMake( theRect.origin.x + (theRect.size.width/2), 
                                                 theRect.origin.y + (theRect.size.height/2));
                float theDistance = sqrtf( ABS(theCenter.x - wp.x)*2 +
                                           ABS(theCenter.y - wp.y)*2 );
                if (theDistance < minDistance)
                {
                    if ([theView respondsToSelector:@selector(text)])
                    {
                        theWord = ((UILabel *)theView).text;
                        minDistance = theDistance;
                    }
                }
            }
            if (theWord != nil)
            {
                // strip any junk characters
                NSCharacterSet *junkChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                theWord = [theWord stringByTrimmingCharactersInSet:junkChars];
                if ([theWord isEqualToString:@""])
                {
                    theWord = nil;
                }
            }
            selectedWord = theWord;
            NSLog(@"The word is %@", theWord);

            // select the row
            BOOL curValue;
            NSUInteger currentBook = [[PKSettings instance] currentBook];
            NSUInteger currentChapter = [[PKSettings instance] currentChapter];
            NSString *passage = [PKBible stringFromBook:currentBook forChapter:currentChapter forVerse:row+1];
            
            selectedPassage = passage;
            
            UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
            [selectedVerses setObject:[NSNumber numberWithBool:YES] forKey:passage];
            curValue = [[selectedVerses objectForKey:passage] boolValue];
            if (curValue)
            {
                newCell.backgroundColor = [UIColor colorWithRed:0.75 green:0.875 blue:1.0 alpha:1.0];
            }
            else 
            {
                newCell.backgroundColor = self.tableView.backgroundColor;
            }
            for (UIView *view in newCell.subviews)
            {
                view.backgroundColor = newCell.backgroundColor;

            }
        }
        
        CGRect theRect;
        theRect.origin.x = p.x;
        theRect.origin.y = p.y;
        theRect.size.width = 1;
        theRect.size.height = 1;
        ourMenuState = 0; // show entire menu (not second-tier)
        [self becomeFirstResponder];
        [ourMenu update]; // just in case
        [ourMenu setTargetRect:theRect inView:self.tableView ];
        [ourMenu setMenuVisible:YES animated:YES];
        
    }
}

#pragma mark -
#pragma mark miscellaneous selectors (called from popovers, buttons, etc.)

-(void) goFullScreen: (id)sender
{
    ((PKRootViewController *)self.parentViewController.parentViewController).aViewHasFullScreen = YES;
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    CGRect theRect = ((PKRootViewController *)self.parentViewController.parentViewController).tabBar.frame;
    theRect.origin.y += 49;
    [((PKRootViewController *)self.parentViewController.parentViewController).tabBar setFrame:theRect];
    
    theRect = self.parentViewController.parentViewController.view.frame;
    //theRect.origin.y -= 20;
    theRect.size.height += 49;
    [self.parentViewController.parentViewController.view setFrame:theRect];
    [((PKRootViewController *)self.parentViewController.parentViewController) calcShadowPosition:[[UIDevice currentDevice] orientation]];
  
    self.fullScreen = YES;
    
    // create a button to get us back!
    theRect = self.parentViewController.parentViewController.view.frame;
    theRect.origin.x = theRect.size.width - 100;
    theRect.origin.y = 10;
    theRect.size.width = 90;
    theRect.size.height = 32;

    btnRegularScreen = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnRegularScreen setFrame:theRect];
    [btnRegularScreen setTitle:@"Back" forState:UIControlStateNormal];
    [btnRegularScreen setTitle:@"Back" forState:UIControlStateHighlighted];
    [btnRegularScreen setTitle:@"Back" forState:UIControlStateDisabled];
    [btnRegularScreen setTitle:@"Back" forState:UIControlStateSelected];
    btnRegularScreen.titleLabel.textColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    btnRegularScreen.layer.opacity = 0.5;
    btnRegularScreen.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [btnRegularScreen addTarget:self action:@selector(goRegularScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentViewController.view addSubview:btnRegularScreen];
    [self.parentViewController.view bringSubviewToFront:btnRegularScreen];    
}

-(void) goRegularScreen: (id)sender
{
    [btnRegularScreen removeFromSuperview];
    btnRegularScreen = nil;

    ((PKRootViewController *)self.parentViewController.parentViewController).aViewHasFullScreen = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    CGRect theRect = ((PKRootViewController *)self.parentViewController.parentViewController).tabBar.frame;
    theRect.origin.y -= 49;
    [((PKRootViewController *)self.parentViewController.parentViewController).tabBar setFrame:theRect];
    
    theRect = self.parentViewController.parentViewController.view.frame;
   // theRect.origin.y += 20;
    theRect.size.height -= 49;
    [self.parentViewController.parentViewController.view setFrame:theRect];
    [((PKRootViewController *)self.parentViewController.parentViewController) calcShadowPosition:[[UIDevice currentDevice] orientation]];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
  
    self.fullScreen = NO;
    
}

/**
 *
 * When "Highlight" is pressed on the menu, we need to present new options.
 *
 */
-(void) askHighlight: (id)sender
{
    ourMenuState = 1;
    [ourMenu update];
    [ourMenu setMenuVisible:YES animated:YES];
}

/**
 *
 * When "Search" is pressed on the menu, we need to present new options.
 *
 */
-(void) askSearch: (id)sender
{
    ourMenuState = 2;
    [ourMenu update];
    [ourMenu setMenuVisible:YES animated:YES];
}

/**
 *
 * Display a drop-down for the highlight color button
 *
 */
-(void) changeHighlightColor:(id)sender
{
    [ourPopover dismissWithClickedButtonIndex:-1 animated:YES];

    UIActionSheet *theActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"Choose Color" 
                                          delegate:self 
                                 cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil 
                                 otherButtonTitles:@"Yellow", @"Green", @"Magenta", 
                                                   @"Pink",   @"Blue",    nil ];
    theActionSheet.tag = 1999; // color chooser
    ourPopover = theActionSheet;
    [theActionSheet showFromBarButtonItem:sender animated:YES];
}

/**
 *
 * Clear the user's selection
 *
 */
-(void) clearSelection: (id) sender
{
    selectedVerses = [[NSMutableDictionary alloc] init]; // clear selection
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
    [ourPopover dismissWithClickedButtonIndex:-1 animated:YES];
    [(ZUUIRevealController *)[[PKAppDelegate instance] rootViewController] revealToggle: sender];
}

/**
 *
 * let the left-hand navigation know that highlights have changed
 *
 */
-(void) notifyChangedHighlights
{
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex:1] reloadHighlights];
}

/**
 *
 * let the left-hand navigation know that history has changed
 *
 */
-(void) notifyChangedHistory
{
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex:3] reloadHistory];
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
    for (NSString* key in selectedVerses)
    {
        if ( [[selectedVerses objectForKey:key] boolValue])
        {
            [(PKHighlights *)[PKHighlights instance] 
                removeHighlightFromPassage:key];
        }
    }
    [self notifyChangedHighlights];
    [self loadHighlights]; // get our new highlights
    [self clearSelection:nil];
}

/**
 *
 * Copy the selection to the pasteboard
 *
 */
-(void) copySelection: (id)sender
{
    NSMutableString *theText = [[NSMutableString alloc] init];
    
    for (NSString* key in selectedVerses)
    {
        if ( [[selectedVerses objectForKey:key] boolValue])
        {
            int theVerse = [PKBible verseFromString:key];
            if (theVerse <= [currentEnglishChapter count] )
            {
                [theText appendString:[currentEnglishChapter objectAtIndex:theVerse]];
            }
            [theText appendString:@"\n"];
            if (theVerse <= [currentGreekChapter count])
            {
                [theText appendString:[currentGreekChapter objectAtIndex:theVerse]];
            }
            
            int theBook = [[PKSettings instance] currentBook];
            int theChapter = [[PKSettings instance] currentChapter];
            NSArray *theNote = [[PKNotes instance] getNoteForPassage:[PKBible stringFromBook:theBook forChapter:theChapter forVerse:theVerse]];
            if (theNote != nil)
            {
                [theText appendFormat:@"\n%@ - %@", [theNote objectAtIndex:0], [theNote objectAtIndex:1]];
            }
            [theText appendString:@"\n\n"];
        }
    }
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = theText;
    
    [self clearSelection:nil];
}

/**
 *
 * Highlight the selection with the currently selected highlight color
 *
 */
-(void) highlightSelection: (id)sender
{
    // we're highlighting the selection
    for (NSString* key in selectedVerses)
    {
        if ( [[selectedVerses objectForKey:key] boolValue])
        {
            [(PKHighlights *)[PKHighlights instance] 
                setHighlight: ((PKSettings *)[PKSettings instance]).highlightColor
                  forPassage: key];
        }
    }
    [self notifyChangedHighlights];
    [self loadHighlights]; // get our new highlights
    [self clearSelection:nil];
}

/**
 *
 * Define the selectedWord
 *
 */
-(void)defineWord: (id)sender
{
    // if the word is a strong's #, we'll do that lookup instead.
    if ( [[selectedWord substringToIndex:1] isEqualToString:@"G"] &&
         [[selectedWord substringFromIndex:1] intValue] > 0 )
    {
        [self searchStrongs:sender];
        return;
    }

    UIReferenceLibraryViewController *dictionary = [[UIReferenceLibraryViewController alloc] initWithTerm:selectedWord];
    if (dictionary != nil)
    {
        [self presentModalViewController:dictionary animated:YES];
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
-(void)searchBible: (id)sender
{
    ZUUIRevealController *rc = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKSearchViewController *svc = [[[rvc.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    
    [svc doSearchForTerm:selectedWord];
}

/**
 *
 * Switches to the Strong's Lookup tab and searches for the selectedWord. If the word is a 
 * strong's number, we indicate that we only want that value (not partial matches).
 *
 */
-(void)searchStrongs: (id)sender
{
    BOOL isStrongs = [[selectedWord substringToIndex:1] isEqualToString:@"G"] &&
                     [[selectedWord substringFromIndex:1] intValue] > 0;

    ZUUIRevealController *rc = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKStrongsController *svc = [[[rvc.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0];
    
    [svc doSearchForTerm:selectedWord byKeyOnly:isStrongs];
    

}

/**
 *
 * Explains a verse by loading bible.cc's website.
 *
 */
-(void)explainVerse: (id)sender
{
    // TODO: check for internet
    int theBook = [PKBible bookFromString:selectedPassage];
    int theChapter=[PKBible chapterFromString:selectedPassage];
    int theVerse=[PKBible verseFromString:selectedPassage];
    
    NSString *theTransformedURL = [NSString stringWithFormat:@"http://bible.cc/%@/%i-%i.htm",
                                                            [[PKBible nameForBook:theBook] lowercaseString],
                                                            theChapter, theVerse];
    theTransformedURL = [theTransformedURL stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"The URL:%@", theTransformedURL);
    NSURL *theURL = [[NSURL alloc] initWithString:theTransformedURL];
    TSMiniWebBrowser *wb = [[TSMiniWebBrowser alloc] initWithUrl:theURL];
    wb.showURLStringOnActionSheetTitle = YES;
    wb.showPageTitleOnTitleBar = YES;
    wb.showActionButton = YES;
    wb.showReloadButton = YES;
    wb.mode = TSMiniWebBrowserModeModal;
    wb.barStyle = UIBarStyleBlack;
    wb.modalDismissButtonTitle = @"Done";
    [self presentModalViewController:wb animated:YES];
}

/**
 *
 * creates a NoteEditorViewController, tells it the passage we're annotating, and shows it modally.
 *
 */
-(void)doAnnotate: (id)sender
{
    PKNoteEditorViewController *nevc = [[PKNoteEditorViewController alloc] initWithPassage:selectedPassage];
    UINavigationController *mvnc = [[UINavigationController alloc] initWithRootViewController:nevc];
    mvnc.modalPresentationStyle = UIModalPresentationFormSheet;

        UINavigationBar *navBar = [mvnc navigationBar];
        if ([navBar respondsToSelector:@selector(setBackgroundImage:)])
        {
            [navBar setBackgroundImage:[UIImage imageNamed:@"BlueNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
            [navBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextShadowColor,
            [UIColor whiteColor], UITextAttributeTextColor, nil]];
        }


    [self presentModalViewController:mvnc animated:YES];
}

#pragma mark -
#pragma mark popover responder
/**
 *
 * Handle the response to an actionsheet
 *
 */
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1999)
    {
        // handle color change options
        UIColor *newColor;
        NSString *textColor;
        switch (buttonIndex)
        {
case 0:
            newColor = [UIColor yellowColor];
            textColor = @"Yellow";
            break;
case 1:
            newColor = [UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0];
            textColor = @"Green";
            break;
case 2:
            newColor = [UIColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:1.0];
            textColor = @"Magenta";
            break;
case 3:
            newColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.75 alpha:1.0];
            textColor = @"Pink";
            break;
case 4:
            newColor = [UIColor colorWithRed:0.5 green:0.75 blue:1.0 alpha:1.0];
            textColor = @"Blue";
            break;
default:
            return; // either cancelling, or out of range. we don't care.
        }
        
        if ([changeHighlight respondsToSelector:@selector(setTintColor:)])
        {
            self.changeHighlight.tintColor = newColor;
        }
        else
        { 
            self.changeHighlight.title = textColor;
        }
        ((PKSettings *)[PKSettings instance]).highlightColor = newColor;
        ((PKSettings *)[PKSettings instance]).highlightTextColor = textColor;
        [(PKSettings *)[PKSettings instance] saveCurrentHighlight];
    }
}

@end
