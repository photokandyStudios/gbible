//
//  PKSimpleBibleViewController.m
//  gbible
//
//  Created by Kerri Shotts on 2/7/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
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
#import "PKSimpleBibleViewController.h"
#import "PKBible.h"
#import "PKSettings.h"
#import "PKConstants.h"
#import "PKHighlights.h"
#import "PKHighlightsViewController.h"
#import "PKHistoryViewController.h"
#import "PKHistory.h"
#import "PKNotes.h"
#import "PKTableViewCell.h"
#import "PKLabel.h"
#import "TestFlight.h"
#import "PKStrongs.h"
#import "SVProgressHUD.h"
#import "UIFont+Utility.h"

@interface PKSimpleBibleViewController ()

@property (strong, nonatomic) NSArray *currentGreekChapter;
@property (strong, nonatomic) NSArray *currentEnglishChapter;
@property (strong, nonatomic) NSMutableArray *formattedGreekChapter;
@property (strong, nonatomic) NSMutableArray *formattedEnglishChapter;
@property (strong, nonatomic) NSMutableArray *formattedGreekVerseHeights;
@property (strong, nonatomic) NSMutableArray *formattedEnglishVerseHeights;
@property (strong, nonatomic) NSMutableDictionary *selectedVerses;
@property (strong, nonatomic) NSMutableDictionary *highlightedVerses;
@property (strong, nonatomic) NSMutableArray *cellHeights;     // RE: ISSUE #1
@property (strong, nonatomic) NSMutableArray *cells;           // RE: ISSUE #1
@property (strong, nonatomic) NSMutableArray *reusableLabels;
@property (strong, nonatomic) NSMutableArray *formattedCells;
@property (strong, nonatomic) UITableViewCell *theCachedCell;
@property (strong, nonatomic) NSArray *bibleTextIDs;
@property int currentBook;
@property int currentChapter;
@property int reusableLabelQueuePosition;
@property BOOL dirty;

@end

@implementation PKSimpleBibleViewController
{
  int globalVerse;
}

@synthesize currentGreekChapter, currentEnglishChapter, formattedGreekChapter, formattedEnglishChapter, formattedGreekVerseHeights, formattedEnglishVerseHeights, selectedVerses, highlightedVerses, cellHeights, cells, reusableLabels, formattedCells, theCachedCell, bibleTextIDs, currentBook, currentChapter, reusableLabelQueuePosition, dirty;
@synthesize delegate, notifyWithCopyOfVerse;

#pragma mark - 
#pragma mark content loading and formatting

/**
 *
 * Load the desired chapter for the desired book. Also saves the settings.
 *
 */
-(void)loadChapter: (int) theChapter forBook: (int) theBook
{
  selectedVerses             = [[NSMutableDictionary alloc] init];
  globalVerse = 0;
  currentBook    = theBook;
  currentChapter = theChapter;
  [self.tableView reloadData];
}

-(void)selectVerse: (int)theVerse
{
  NSUInteger row            = theVerse -1;
  globalVerse = theVerse;
  BOOL curValue;
  NSString *passage         = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:row+1].reference;

  curValue = [[selectedVerses objectForKey: passage] boolValue];
  [selectedVerses setObject: [NSNumber numberWithBool: !curValue] forKey: passage];
  
  [self.tableView reloadData];

}

-(void)scrollToVerse: (int)theVerse
{
  PKWaitDelay(0.05, {
                if (theVerse > 1)
                {
                  if ([self.tableView numberOfRowsInSection: 0] >  1)
                  {
                    if (theVerse - 1 < [self.tableView numberOfRowsInSection: 0])
                    {
                      [self.tableView scrollToRowAtIndexPath:
                       [NSIndexPath                    indexPathForRow:
                        theVerse - 1 inSection: 0]
                                            atScrollPosition: UITableViewScrollPositionMiddle animated: YES];
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

-(void)loadHighlights
{
  // load our highlighted verses
  highlightedVerses = [(PKHighlights *)[PKHighlights instance] allHighlightedReferencesForBook: currentBook
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

-(void)loadChapter
{
  BOOL parsed               = NO;
  reusableLabelQueuePosition = -1;
  NSUInteger currentBible   = [[PKSettings instance] greekText];
  parsed = [PKBible isStrongsSupportedByText:currentBible] ||
           [PKBible isMorphologySupportedByText:currentBible] ||
           [PKBible isTranslationSupportedByText:currentBible];

  NSDate *startTime;
  NSDate *endTime;
  NSDate *tStartTime;
  NSDate *tEndTime;

  tStartTime            = [NSDate date];
  self.title            = [[PKBible nameForBook: currentBook] stringByAppendingFormat: @" %i", currentChapter];
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
                                      startingAt: 0.0 withCompression:YES];

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
    /*
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
         || UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) )
    {
      greekHeightIPhone = 0.0;
    }
    else
    {
    */
      if (i < formattedGreekVerseHeights.count)
      {
        greekHeightIPhone = [formattedGreekVerseHeights[i] floatValue];
      }
      else
      {
        greekHeightIPhone = 0.0;
      }
    //}

    NSArray *formattedText = [PKBible formatText: [currentEnglishChapter objectAtIndex: i]
                                       forColumn: 2 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: greekHeightIPhone withCompression:YES];

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
                                 andSize: [[PKSettings instance] textFontSize]];

  UIFont *theBoldFont = [UIFont fontWithName: [[PKSettings instance] textGreekFontFace]
                                     andSize: [[PKSettings instance] textFontSize]];
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

    //CGFloat greekColumnWidth      = [PKBible columnWidth: 1 forBounds: self.view.bounds withCompression:YES];
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
      theLabel.text         = theWord; 
      theLabel.textColor    = [PKSettings PKTextColor];
      theLabel.shadowColor  = [PKSettings PKLightShadowColor];
      theLabel.shadowOffset = CGSizeMake(0, 1);

      if (theWordType == 5)
      {
        theLabel.textColor = [PKSettings PKInterlinearColor];
      }

      if (theWordType == 10)
      {         
        theLabel.textColor = [PKSettings PKStrongsColor];
      }

      if (theWordType == 20)
      {         
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
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
    //     && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) )
    //{
    //  greekColumnWidth = 0;
    //}

    for (int i = 0; i < [formattedEnglishVerse count]; i++)
    {
      NSArray *theWordElement = [formattedEnglishVerse objectAtIndex: i];
      NSString *theWord       = [theWordElement objectAtIndex: 0];
      CGFloat wordX           = [[theWordElement objectAtIndex: 2] floatValue];
      CGFloat wordY           = [[theWordElement objectAtIndex: 3] floatValue];
      CGFloat wordW           = [[theWordElement objectAtIndex: 4] floatValue];
      CGFloat wordH           = [[theWordElement objectAtIndex: 5] floatValue];

      PKLabel *theLabel       = [self deQueueReusableLabel]; 
      [theLabel setFrame: CGRectMake(wordX, wordY, wordW, wordH)];
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

-(void) updateAppearanceForTheme
{
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  [self reloadTableCache];
}


#pragma mark -
#pragma mark View lifecycle


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// ISSUE #61
-(void)viewDidAppear: (BOOL) animated
{
  [super viewDidAppear:animated];
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
  if (dirty)
  {
    [self loadChapter];
    [self reloadTableCache];
    [(PKHistory *)[PKHistory instance] addReferenceWithBook: currentBook andChapter: currentChapter
     andVerse: 1];
    dirty = NO;
  }
  [self updateAppearanceForTheme];

}


- (void)viewDidLoad
{
    [super viewDidLoad];

  dirty = YES;
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  // init our selectedVeres
  selectedVerses = [[NSMutableDictionary alloc] init];

  if (self.navigationItem)
  {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithTitle: __T(@"Done") style: UIBarButtonItemStylePlain target: self action: @selector(closeMe:)
      ];
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationItem.title              = __T(@"Select Verse");
  }
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                             initWithTarget: self action: @selector(didReceiveLongPress:)];
  longPress.minimumPressDuration    = 0.5;
  longPress.numberOfTapsRequired    = 0;
  longPress.numberOfTouchesRequired = 1;
  [self.tableView addGestureRecognizer: longPress];
  

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
  int theBook      = currentBook;
  int theChapter   = currentChapter;

  NSArray *theNote =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:row+1]];

  if (theNote != nil
      && [[PKSettings instance] showNotesInline])
  {
    NSString *theNoteText = [NSString stringWithFormat: @"%@ - %@",
                             [theNote objectAtIndex: 0],
                             [theNote objectAtIndex: 1]];
    CGSize theSize        = [theNoteText sizeWithFont: [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                                    andSize: [[PKSettings instance] textFontSize]]
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

  // are we selected? If so, it takes precedence
  NSString *passage         = [PKReference referenceWithBook:currentBook andChapter:currentChapter andVerse:row+1].reference;
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
  return [self cellForRowAtIndexPath: indexPath];
}

-(UITableViewCell *) cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
  static NSString *bibleCellID = @"PKBibleCellID";
  PKTableViewCell *cell        =
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

  // and check if we have a note
  int theBook              = currentBook;
  int theChapter           = currentChapter;

  NSArray *theNote         =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:row+1]];
  
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
                                                                    andSize: [[PKSettings instance] textFontSize]]
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width - 20, 999)];
    CGRect theRect        = CGRectMake(10, theMax + 10, self.tableView.bounds.size.width - 20, theSize.height);

    UILabel *theNoteLabel = [[UILabel alloc] initWithFrame: theRect];
    theNoteLabel.text            = theNoteText;
    theNoteLabel.numberOfLines   = 0;
    theNoteLabel.font            = [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                andSize: [[PKSettings instance] textFontSize]];
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

  cell.accessibilityLabel = theAString;
  [cell setNeedsDisplay];

  cell.selectionStyle     = UITableViewCellSelectionStyleNone;

  return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  NSUInteger row            = [indexPath row];
  [tableView deselectRowAtIndexPath: indexPath animated: YES];
  if (self.delegate)
  {
    if (self.notifyWithCopyOfVerse)
    {
      [self.delegate newVerseByBook:currentBook andChapter:currentChapter andVerse:row+1];
    }
    else
    {
      [self.delegate newReferenceByBook:currentBook andChapter:currentChapter andVerse:row+1];
    }
    [self dismissModalViewControllerAnimated: YES];
  }
}

#pragma mark -
#pragma mark buttons
-(void) closeMe: (id) sender
{
  [self dismissModalViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark gesture recognizer
-(void) didReceiveLongPress: (UILongPressGestureRecognizer *) gestureRecognizer
{
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
  {
    // restore our menu items after a strongs view shows
    UIMenuController *ourMenu           = [UIMenuController sharedMenuController];

    CGPoint p              = [gestureRecognizer locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: p];    // nil if no row
    CGRect theRect;
    theRect.origin.x    = p.x;
    theRect.origin.y    = p.y;
    theRect.size.width  = 1;
    theRect.size.height = 1;

    if (indexPath != nil)
    {
      NSUInteger row           = [indexPath row];
      globalVerse = row + 1;

      [self becomeFirstResponder];
      [ourMenu update];   // just in case
      [ourMenu setTargetRect: theRect inView: self.tableView];
      [ourMenu setMenuVisible: YES animated: YES];
    }
  }
}

-(BOOL) canBecomeFirstResponder
{
  return YES;
}

-(BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
  if ( action == @selector(copy:) )
  {
    return YES;
  }
  return NO;
}

-(void) copy: (id) sender
{
  [self copyVerse: nil];
}

-(void) copyVerse: (id) sender
{
  NSMutableString *theText   = [[NSMutableString alloc] init];

  int theVerse = globalVerse;

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

  int theBook      = currentBook;
  int theChapter   = currentChapter;
  NSArray *theNote =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:theVerse]];

  if (theNote != nil)
  {
    [theText appendFormat: @"\n%@ - %@", [theNote objectAtIndex: 0], [theNote objectAtIndex: 1]];
  }
  [theText appendString: @"\n\n"];

  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  pasteBoard.string = theText;
}


@end
