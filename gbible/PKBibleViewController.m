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

@interface PKBibleViewController ()

@end

@implementation PKBibleViewController
    
    @synthesize gotoRefBook;
    @synthesize gotoRefVerse;
    @synthesize gotoRefChapter;
    
    @synthesize currentGreekChapter;
    @synthesize currentEnglishChapter;
    
    @synthesize formattedGreekChapter;
    @synthesize formattedEnglishChapter;
    
    @synthesize formattedGreekVerseHeights;
    @synthesize formattedEnglishVerseHeights;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Settings"];
    }
    return self;
}
- (void)loadChapter: (int)theChapter forBook: (int)theBook
{
    PKSettings *theSettings = [PKSettings instance];
    theSettings.currentBook = theBook;
    theSettings.currentChapter = theChapter;
    [theSettings saveSettings];
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

    currentGreekChapter = [PKBible getTextForBook:currentBook forChapter:currentChapter forSide:1];
    currentEnglishChapter = [PKBible getTextForBook:currentBook forChapter:currentChapter forSide:2];
    self.title = [[PKBible nameForBook:currentBook] stringByAppendingFormat:@" %i",currentChapter];    
    
    // now, get the formatting for both sides, verse by verse
    // greek side first
    formattedGreekChapter = [[NSMutableArray alloc]init];
    formattedGreekVerseHeights = [[NSMutableArray alloc]init];
    for (int i=0; i<[currentGreekChapter count]; i++)
    {
        NSLog (@"Greek side(%i): Formatting text...", i);
        NSArray *formattedText = [PKBible formatText:[currentGreekChapter objectAtIndex:i] 
                                           forColumn:1 withBounds:self.view.bounds withParsings:parsed];
        
        [formattedGreekChapter addObject: 
            formattedText
        ];
        
        NSLog (@"Greek side(%i): End Format", i);
        [formattedGreekVerseHeights addObject:
            [NSNumber numberWithFloat: [PKBible formattedTextHeight:formattedText withParsings:parsed]]
        ];
    }

    // english next
    formattedEnglishChapter = [[NSMutableArray alloc]init];
    formattedEnglishVerseHeights = [[NSMutableArray alloc]init];
    for (int i=0; i<[currentEnglishChapter count]; i++)
    {
        NSLog (@"English side(%i): Formatting text...", i);
        NSArray *formattedText = [PKBible formatText:[currentEnglishChapter objectAtIndex:i] 
                                           forColumn:2 withBounds:self.view.bounds withParsings:parsed];

        [formattedEnglishChapter addObject: 
            formattedText
        ];
        
        NSLog (@"English side(%i): End Format", i);
        [formattedEnglishVerseHeights addObject:
            [NSNumber numberWithFloat: [PKBible formattedTextHeight:formattedText withParsings:parsed]]
        ];
    }
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

/*
-(void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
}
*/
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
    float theMax= MAX( [[formattedGreekVerseHeights objectAtIndex:row] floatValue],
                [[formattedEnglishVerseHeights objectAtIndex:row] floatValue] );
    //NSLog (@"heightForRowAtIndexPath(%i): Maximum = %f", row, theMax);
    return theMax;
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
    
    NSArray *formattedGreekVerse = [formattedGreekChapter objectAtIndex:row];
    NSArray *formattedEnglishVerse = [formattedEnglishChapter objectAtIndex:row];
    
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
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSUInteger section = [indexPath section];
//    NSUInteger row = [indexPath row];
//    NSArray *cellData = [[settingsGroup objectAtIndex:section] objectAtIndex:row];
//    BOOL curValue;
//    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
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
    [self nextChapter];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end
