
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
#import "ZUUIRevealController.h"

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

#pragma mark -
#pragma mark Content Loading and Display

- (void)displayBook: (int)theBook andChapter: (int)theChapter andVerse: (int)theVerse
{
    [self loadChapter:theChapter forBook:theBook];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:theVerse-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UITabBarController *tbc = (UITabBarController *)self.parentViewController.parentViewController;
    tbc.selectedIndex = 0;
}

- (void)loadChapter: (int)theChapter forBook: (int)theBook
{
    // clear selectedVerses
    selectedVerses = [[NSMutableDictionary alloc] init];
    PKSettings *theSettings = [PKSettings instance];
    theSettings.currentBook = theBook;
    theSettings.currentChapter = theChapter;
    [theSettings saveCurrentReference];
    [self loadChapter];
}
- (void)nextChapter
{
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
}

- (void)previousChapter
{
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
}


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
}

#pragma mark -
#pragma mark View Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Settings"];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [self loadChapter];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    longPress.minimumPressDuration = 1.0;
    longPress.numberOfTapsRequired = 0;
    longPress.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:longPress];
    
    // init our selectedVeres
    selectedVerses = [[NSMutableDictionary alloc] init];
    
    // add navbar items
    UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                        initWithImage:[UIImage imageNamed:@"Listb.png"] 
                                        landscapeImagePhone:[UIImage imageNamed:@"listLandscape.png"]
                                        style:UIBarButtonItemStylePlain 
                                        target:self.parentViewController.parentViewController.parentViewController
                                        action:@selector(revealToggle:)];
    changeReference.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:changeReference, nil];
    
    // handle pan from left to right to reveal sidebar
    CGRect leftFrame = self.view.frame;
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

    [leftLabel addGestureRecognizer:panGesture];
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self loadChapter];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table View Data Source Methods


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of verses in the current passage
    int currentGreekVerseCount = [currentGreekChapter count];
    int currentEnglishVerseCount = [currentEnglishChapter count];
    int currentVerseCount = MAX(currentGreekVerseCount, currentEnglishVerseCount);
    
    return currentVerseCount;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    return theMax;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // determine if the cell is selected
    NSUInteger row = [indexPath row];
    BOOL curValue;
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    NSString *passage = [PKBible stringFromBook:currentBook forChapter:currentChapter forVerse:row+1];
    curValue = [[selectedVerses objectForKey:passage] boolValue];

    if (curValue)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.75 green:0.875 blue:1.0 alpha:1.0];
    }
    else 
    {
        cell.backgroundColor = [UIColor clearColor];
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *theFont = [UIFont fontWithName:[[PKSettings instance] textFontFace]
                                      size:[[PKSettings instance] textFontSize]];

    static NSString *bibleCellID = @"PKBibleCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bibleCellID];
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
        theLabel.text = theWord;
        theLabel.textColor = [UIColor blackColor];
        theLabel.backgroundColor = [UIColor clearColor];
        if (theWordType == 10) { theLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0]; }
        if (theWordType == 20) { theLabel.textColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]; }
        theLabel.font = theFont;
        [cell addSubview:theLabel];
        
        //NSLog(@"cellForRowAtIndexPath(%i): Greek Word @(%f,%f,%f,%f)=%@",
        //          row, wordX, wordY, wordW, wordH, theWord);
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
        theLabel.textColor = [UIColor blackColor];
        theLabel.backgroundColor = [UIColor clearColor];
        theLabel.font = theFont;
        [cell addSubview:theLabel];

        //NSLog(@"cellForRowAtIndexPath(%i): English Word @(%f,%f,%f,%f)=%@",
        //          row, wordX, wordY, wordW, wordH, theWord);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        newCell.backgroundColor = [UIColor clearColor];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UISwipeGestureRecognizer
-(void) didReceiveRightSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self previousChapter];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}
-(void) didReceiveLeftSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSDate *startTime = [NSDate date];
    [self nextChapter];
    NSDate *endTime = [NSDate date];
    //NSLog (@"Time to go to next chapter: %f", [endTime timeIntervalSinceDate:startTime]);
    startTime = [NSDate date];
    [self.tableView reloadData];
    endTime = [NSDate date];
    //NSLog (@"Time to reload data: %f", [endTime timeIntervalSinceDate:startTime]);
    startTime = [NSDate date];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    endTime = [NSDate date];
    //NSLog (@"Time to scroll to top: %f", [endTime timeIntervalSinceDate:startTime]);
}
-(void) didReceiveLongPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p]; // nil if no row
        NSLog (@"Long pressed.");
    }
}

@end
