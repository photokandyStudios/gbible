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
#import "PKStrongs.h"
#import "SVProgressHUD.h"
#import "UIFont+Utility.h"
#import "NSString+PKFont.h"
#import "UIImage+PKUtility.h"

@interface PKSimpleBibleViewController ()

@end

@implementation PKSimpleBibleViewController
{
  NSUInteger globalVerse;
  NSArray * /**__strong**/ _currentGreekChapter;
  NSArray * /**__strong**/ _currentEnglishChapter;
  NSMutableArray * /**__strong**/ _formattedGreekChapter;
  NSMutableArray * /**__strong**/ _formattedEnglishChapter;
  NSMutableArray * /**__strong**/ _formattedGreekVerseHeights;
  NSMutableArray * /**__strong**/ _formattedEnglishVerseHeights;
  NSMutableDictionary * /**__strong**/ _selectedVerses;
  NSMutableDictionary * /**__strong**/ _highlightedVerses;
  NSMutableArray * /**__strong**/ _cellHeights;     // RE: ISSUE #1
  NSMutableArray * /**__strong**/ _cells;           // RE: ISSUE #1
  NSMutableArray * /**__strong**/ _formattedCells;
  UITableViewCell * /**__strong**/ _theCachedCell;
  NSArray * /**__strong**/ _bibleTextIDs;
  NSUInteger _currentBook;
  NSUInteger _currentChapter;
  int _reusableLabelQueuePosition;
  BOOL _dirty;
}

@synthesize delegate, notifyWithCopyOfVerse, incognito;

#pragma mark - 
#pragma mark content loading and formatting

/**
 *
 * Load the desired chapter for the desired book. Also saves the settings.
 *
 */
-(void)loadChapter: (NSUInteger) theChapter forBook: (NSUInteger) theBook
{
  _selectedVerses             = [[NSMutableDictionary alloc] init];
  globalVerse = 0;
  _currentBook    = theBook;
  _currentChapter = theChapter;
  _dirty = YES;
  [self.tableView reloadData];
}

-(void)selectVerse: (NSUInteger)theVerse
{
  NSUInteger row            = theVerse -1;
  globalVerse = theVerse;
  BOOL curValue;
  NSString *passage         = [PKReference referenceWithBook:_currentBook andChapter:_currentChapter andVerse:row+1].reference;

  curValue = [_selectedVerses[passage] boolValue];
  _selectedVerses[passage] = [NSNumber numberWithBool: !curValue];
  
  [self.tableView reloadData];

}

-(void)scrollToVerse: (NSUInteger)theVerse
{
  __weak typeof(self) weakSelf = self;
  [self performBlockAsynchronouslyInForeground:^(void)
    {
      if (theVerse > 1)
      {
        if ([weakSelf.tableView numberOfRowsInSection: 0] >  1)
        {
          if (theVerse - 1 < [weakSelf.tableView numberOfRowsInSection: 0])
          {
            [weakSelf.tableView scrollToRowAtIndexPath:
             [NSIndexPath                    indexPathForRow:
              theVerse - 1 inSection: 0]
                                  atScrollPosition: UITableViewScrollPositionMiddle animated: YES];
          }
        }
      }
      else
      {
        [weakSelf.tableView scrollRectToVisible: CGRectMake(0, 0, 1, 1) animated: YES];
      }
    }
  afterDelay:0.01];
}

-(void)loadHighlights
{
  // load our highlighted verses
  _highlightedVerses = [[PKHighlights instance] allHighlightedReferencesForBook: _currentBook
                                                                                  andChapter: _currentChapter];
}

-(void)loadChapter
{
  BOOL parsed               = NO;
  _reusableLabelQueuePosition = -1;
  NSUInteger currentBible   = [[PKSettings instance] greekText];
  parsed = [PKBible isStrongsSupportedByText:currentBible] ||
           [PKBible isMorphologySupportedByText:currentBible] ||
           [PKBible isTranslationSupportedByText:currentBible];

  NSDate *startTime;
  NSDate *endTime;
  NSDate *tStartTime;
  NSDate *tEndTime;

  tStartTime            = [NSDate date];
  self.title            = [[PKBible nameForBook: _currentBook] stringByAppendingFormat: @" %lu", (unsigned long)_currentChapter];
  startTime             = [NSDate date];
  _currentGreekChapter   = [PKBible getTextForBook: _currentBook forChapter: _currentChapter forSide: 1];
  _currentEnglishChapter = [PKBible getTextForBook: _currentBook forChapter: _currentChapter forSide: 2];
  endTime               = [NSDate date];

  // now, get the formatting for both sides, verse by verse
  // greek side first
  startTime                  = [NSDate date];
  _formattedGreekChapter      = [[NSMutableArray alloc] init];
  _formattedGreekVerseHeights = [[NSMutableArray alloc] init];
  CGFloat greekHeightIPhone;

  for (int i = 0; i < [_currentGreekChapter count]; i++)
  {
    NSArray *formattedText = [PKBible formatText: _currentGreekChapter[i]
                                       forColumn: 1 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: 0.0 withCompression:YES];

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

  for (int i = 0; i < [_currentEnglishChapter count]; i++)
  {
      if (i < _formattedGreekVerseHeights.count)
      {
        greekHeightIPhone = [_formattedGreekVerseHeights[i] floatValue];
      }
      else
      {
        greekHeightIPhone = 0.0;
      }

    NSArray *formattedText = [PKBible formatText: _currentEnglishChapter[i]
                                       forColumn: 2 withBounds: self.view.bounds withParsings: parsed
                                      startingAt: greekHeightIPhone withCompression:YES];

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

  for (int i = 0; i < MAX([_currentGreekChapter count], [_currentEnglishChapter count]); i++)
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
  _cellHeights = nil;

  _cellHeights = [[NSMutableArray alloc] init];

  for (int row = 0; row < MAX([_formattedGreekChapter count], [_formattedEnglishChapter count]); row++)
  {
    [_cellHeights addObject: @([self heightForRowAtIndexPath: [NSIndexPath indexPathForRow: row inSection:
                                                                                       0]])];
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
  if (_dirty)
  {
    [self loadChapter];
    [self reloadTableCache];
    if (!self.incognito) {
      [[PKHistory instance] addReferenceWithBook: _currentBook andChapter: _currentChapter
                                        andVerse: 1];
    }
    _dirty = NO;
  }

}

/**
 *
 * Whenever we appear, we need to reload the chapter. (Highlights / Settings / etc., may have changed)
 *
 */
-(void)viewWillAppear: (BOOL) animated
{
  [super viewWillAppear:animated];
  [self updateAppearanceForTheme];

}


- (void)viewDidLoad
{
  self.enableVerticalScrollBar = NO;
    [super viewDidLoad];

  _dirty = YES;
  [self.tableView setBackgroundView: nil];
  self.tableView.backgroundColor = [PKSettings PKPageColor];
  self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
  
  // init our selectedVeres
  _selectedVerses = [[NSMutableDictionary alloc] init];

  if (self.navigationItem)
  {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
      self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    else
      self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
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
  NSUInteger theVerse = [[self.tableView indexPathsForVisibleRows][0] row] + 1;

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
  NSUInteger theBook      = _currentBook;
  NSUInteger theChapter   = _currentChapter;

  NSArray *theNote =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:row+1]];

  if (theNote != nil
      && [[PKSettings instance] showNotesInline])
  {
    NSString *theNoteText = [NSString stringWithFormat: @"%@ - %@",
                             theNote[0],
                             theNote[1]];
    CGSize theSize        = [theNoteText sizeWithFont: [UIFont fontWithName: [[PKSettings instance] textFontFace]
                                                                    andSize: [[PKSettings instance] textFontSize]]
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width - 20, 999) usingLigatures:YES];
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
  NSString *passage         = [PKReference referenceWithBook:_currentBook andChapter:_currentChapter andVerse:row+1].reference;
  curValue = [_selectedVerses[passage] boolValue];

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
  for (UIView *view in cell.contentView.subviews)
  {
    [view removeFromSuperview];
  }

  cell.contentMode         = UIViewContentModeRedraw;
  cell.autoresizesSubviews = NO;
  cell.backgroundColor     = [UIColor clearColor];
  NSUInteger row = [indexPath row];

  // and check if we have a note
  NSUInteger theBook              = _currentBook;
  NSUInteger theChapter           = _currentChapter;

  NSArray *theNote         =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:row+1]];
  
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
                             constrainedToSize: CGSizeMake(self.tableView.bounds.size.width - 20, 999) usingLigatures:YES];
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

  for (int i = 0; i < [formattedCell count]; i++)
  {
    [theAString appendString: [formattedCell[i] text]];
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
      [self.delegate newVerseByBook:_currentBook andChapter:_currentChapter andVerse:row+1];
    }
    else
    {
      [self.delegate newReferenceByBook:_currentBook andChapter:_currentChapter andVerse:row+1];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

#pragma mark -
#pragma mark buttons
-(void) closeMe: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

  NSUInteger theVerse = globalVerse;

    PKReference *theReference = [PKReference referenceWithBook:_currentBook andChapter:_currentChapter andVerse:theVerse];
    [theText appendFormat:@"%@\n\n", [theReference prettyReference]];


  if (theVerse <= [_currentEnglishChapter count])
  {
    // FIX ISSUE #43a
    [theText appendString: _currentEnglishChapter[theVerse - 1]];
  }
  [theText appendString: @"\n"];

  if (theVerse <= [_currentGreekChapter count])
  {
    // FIX ISSUE #43a
    [theText appendString: _currentGreekChapter[theVerse - 1]];
  }

  NSUInteger theBook      = _currentBook;
  NSUInteger theChapter   = _currentChapter;
  NSArray *theNote =
    [[PKNotes instance] getNoteForReference: [PKReference referenceWithBook:theBook andChapter:theChapter andVerse:theVerse]];

  if (theNote != nil)
  {
    [theText appendFormat: @"\n%@ - %@", theNote[0], theNote[1]];
  }
  [theText appendString: @"\n\n"];

  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  pasteBoard.string = theText;
  [SVProgressHUD showSuccessWithStatus:__T(@"Copied!")]; // Fixes Issue #85
}


@end
