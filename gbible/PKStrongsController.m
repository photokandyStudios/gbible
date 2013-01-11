//
//  PKStrongsController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKStrongsController.h"
#import "PKStrongs.h"
#import "PKSettings.h"
#import "PKHistory.h"
#import "PKAppDelegate.h"
#import "ZUUIRevealController.h"
#import "PKSearchViewController.h"
#import "PKRootViewController.h"
#import "TestFlight.h"
#import "PKHistoryViewController.h"

#import "PKHotLabel.h"

@interface PKStrongsController ()

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:__T(@"Strong's")];
        self.theSearchTerm = [[PKSettings instance] lastStrongsLookup];
        self.byKeyOnly = NO;
    }
    return self;
}

-(void)doSearchForTerm:(NSString *)theTerm  
{
    [self doSearchForTerm:theTerm byKeyOnly:self.byKeyOnly];
}

-(void)doSearchForTerm:(NSString *)theTerm byKeyOnly:(BOOL)keyOnly
{
    self.byKeyOnly = byKeyOnly;
    [((PKRootViewController *)self.parentViewController.parentViewController ) showWaitingIndicator];
    [[PKHistory instance] addStrongsSearch:theTerm];
    [[[[PKAppDelegate instance] segmentController].viewControllers objectAtIndex:3] reloadHistory];

    PKWait(
        theSearchResults = nil;
        theSearchTerm = theTerm;
        
        if ([theTerm isEqualToString:@""])
        {
            theSearchResults = nil;
        }
        else
        {
            theSearchResults = [PKStrongs keysThatMatch:theTerm byKeyOnly:keyOnly];
        }
        [self.tableView reloadData];
        
        theSearchBar.text = theTerm;
        
        ((PKSettings *)[PKSettings instance]).lastStrongsLookup = theTerm;

        UITabBarController *tbc = (UITabBarController *)self.parentViewController.parentViewController;
        tbc.selectedIndex = 2;
        self.byKeyOnly = NO;
         if ([theSearchResults count] == 0)
            {
                noResults.text = __Tv(@"no-results",@"No results. Please try again.");
            }
            else 
            {
                noResults.text = @"";
            }
    );
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [TestFlight passCheckpoint:@"SEARCH_STRONGS"];
    
    // add search bar
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    theSearchBar.delegate = self;
    theSearchBar.placeholder = __T(@"Strong's # or search term");
    theSearchBar.showsCancelButton = NO;
    theSearchBar.tintColor = [PKSettings PKBaseUIColor];

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

  
    self.tableView.tableHeaderView = theSearchBar;
    
    // add navbar items
    UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                        initWithImage:[UIImage imageNamed:@"Listb.png"] 
                                        style:UIBarButtonItemStylePlain 
                                        target:self.parentViewController.parentViewController.parentViewController
                                        action:@selector(revealToggle:)];

    if ([changeReference respondsToSelector:@selector(setTintColor:)])
    {
        changeReference.tintColor = [PKSettings PKBaseUIColor];
    }
    changeReference.accessibilityLabel = __T(@"Go to passage");
    self.navigationItem.leftBarButtonItem = changeReference;

    CGRect theRect = CGRectMake(0, self.tableView.center.y + 40, self.tableView.bounds.size.width, 60);
    noResults = [[UILabel alloc] initWithFrame:theRect];
    noResults.textColor = [PKSettings PKTextColor];
    noResults.font = [UIFont fontWithName:@"Zapfino" size:15];
    noResults.textAlignment = UITextAlignmentCenter;
    noResults.backgroundColor = [UIColor clearColor];
    noResults.shadowColor = [UIColor whiteColor];
    noResults.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    noResults.numberOfLines = 0;
    [self.view addSubview:noResults];
        
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [PKSettings PKPageColor];

//    [self doSearchForTerm:self.theSearchTerm];
    theSearchBar.text = self.theSearchTerm;


}
-(void) updateAppearanceForTheme
{
    // get the font
    self.theFont = [UIFont fontWithName:[[PKSettings instance] textFontFace]
                                      size:[[PKSettings instance] textFontSize]];
    if (self.theFont == nil)
    {
        self.theFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular", [[PKSettings instance] textFontFace]]
                                              size:[[PKSettings instance] textFontSize]];
    }
    if (self.theFont == nil)
    {
        self.theFont = [UIFont fontWithName:@"Helvetica"
                                              size:[[PKSettings instance] textFontSize]];
    }
    self.theBigFont = [UIFont fontWithName:[self.theFont fontName] size: [[PKSettings instance] textFontSize] + 6 ];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [PKSettings PKPageColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{

    // reload the search? TODO
    [self updateAppearanceForTheme];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    theSearchResults = nil;
    theSearchTerm = nil;

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation  
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self calculateShadows];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
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
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self calculateShadows];
// ISSUE #61
  [self becomeFirstResponder];
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self calculateShadows];
}
#pragma mark
#pragma mark Table View Data Source Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];

    NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:row]];
    
    CGSize theSize;
    CGFloat theHeight = 0;
    CGFloat theCellWidth = (self.tableView.bounds.size.width-30);
//    CGFloat theColumnWidth = (theCellWidth) / 2;
    CGSize maxSize = CGSizeMake(theCellWidth, 300);

    theHeight += 10; // the top margin
    theHeight += self.theBigFont.lineHeight; // the top labels

    theSize = [[theResult objectAtIndex:1] sizeWithFont:self.theFont constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

//    theSize = [[[theResult objectAtIndex:1] stringByAppendingFormat:@" %@", [[theResult objectAtIndex:3] stringByReplacingOccurrencesOfString:@"  " withString:@" "]] sizeWithFont:self.theFont constrainedToSize:maxSize];
    theSize = [[[theResult objectAtIndex:3] stringByReplacingOccurrencesOfString:@"  " withString:@" "] sizeWithFont:self.theFont constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

    theHeight += 10;
    
    return theHeight;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strongsCellID = @"PKStrongsCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strongsCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:strongsCellID];
    }
    // need to remove the cell's subviews, if they exist...
    for (UIView *view in cell.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger row = [indexPath row];
    
    CGFloat theCellWidth = (self.tableView.bounds.size.width-30);
    CGFloat theColumnWidth = (theCellWidth) / 2;
    
    // now create the new subviews
    UILabel *theStrongsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, theColumnWidth, theBigFont.lineHeight)];
    theStrongsLabel.text = [theSearchResults objectAtIndex:row];
    theStrongsLabel.textColor = [PKSettings PKStrongsColor];
    theStrongsLabel.font = theBigFont;
    theStrongsLabel.backgroundColor = [UIColor clearColor];
//    theStrongsLabel.numberOfLines =1;
//    [theStrongsLabel sizeToFit];
    
    NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:row]];
    
    UILabel *theLemmaLabel = [[UILabel alloc] initWithFrame:CGRectMake(theColumnWidth+20, 10, theColumnWidth, theBigFont.lineHeight)];
    theLemmaLabel.text = [[theResult objectAtIndex:1] stringByAppendingFormat:@" (%@)", [theResult objectAtIndex:2]];
    theLemmaLabel.textAlignment = UITextAlignmentRight;
    theLemmaLabel.textColor = [PKSettings PKTextColor];
    theLemmaLabel.font = theBigFont;
    theLemmaLabel.backgroundColor = [UIColor clearColor];
//    theLemmaLabel.numberOfLines=1;
//    [theLemmaLabel sizeToFit];
    
    CGSize maxSize = CGSizeMake (theCellWidth, 300);
    
//    CGSize theSize = [[[theResult objectAtIndex:1] stringByAppendingFormat:@" %@", [[theResult objectAtIndex:3] stringByReplacingOccurrencesOfString:@"  " withString:@" "]] sizeWithFont:theFont constrainedToSize:maxSize];
    CGSize theSize = [[[theResult objectAtIndex:3] stringByReplacingOccurrencesOfString:@"  " withString:@" "] sizeWithFont:theFont constrainedToSize:maxSize];
    PKHotLabel *theDefinitionLabel = [[PKHotLabel alloc] initWithFrame:CGRectMake(10, 20 + theBigFont.lineHeight, theCellWidth, theSize.height)];
//    theDefinitionLabel.text = [[theResult objectAtIndex:1] stringByAppendingFormat:@" %@", [[theResult objectAtIndex:3] stringByReplacingOccurrencesOfString:@"  " withString:@" "]];
    theDefinitionLabel.text = [[theResult objectAtIndex:3] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    theDefinitionLabel.textColor = [PKSettings PKTextColor];
    theDefinitionLabel.font = theFont;
    theDefinitionLabel.lineBreakMode = UILineBreakModeWordWrap;
    theDefinitionLabel.numberOfLines = 0;
    theDefinitionLabel.backgroundColor = [UIColor clearColor];
    theDefinitionLabel.hotColor = [PKSettings PKStrongsColor];
    theDefinitionLabel.hotBackgroundColor = [PKSettings PKSelectionColor];
    theDefinitionLabel.hotWord = theSearchTerm;
    theDefinitionLabel.hotComparator = ^(NSString *theWord) {
      if ([theWord length]>1)
      {
        return (BOOL)([[theWord substringToIndex:1] isEqualToString:@"G"] && [[theWord substringFromIndex:1] intValue] > 0);
      }
      else
      {
        return NO;
      }
    };
    theDefinitionLabel.delegate = self;
    theDefinitionLabel.userInteractionEnabled = YES;

    [cell addSubview:theStrongsLabel];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
      [cell addSubview:theLemmaLabel];
    }
    [cell addSubview:theDefinitionLabel];
  

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (ourMenu.isMenuVisible)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
  //return;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ourMenu = [UIMenuController sharedMenuController];
    ourMenu.menuItems = [NSArray arrayWithObjects:
//Issue #61
//                            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")         action:@selector(copyStrongs:)],
                            [[UIMenuItem alloc] initWithTitle:__T(@"Define")       action:@selector(defineStrongs:)],
                            [[UIMenuItem alloc] initWithTitle:__T(@"Search Bible") action:@selector(searchBible:)]
//                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)]
                         , nil ];


    NSUInteger row = [indexPath row];
    selectedWord = nil;
    selectedRow = row;
    UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];

    [self becomeFirstResponder];
    [ourMenu update]; // just in case
    [ourMenu setTargetRect:theCell.frame inView:self.tableView ];
    [ourMenu setMenuVisible:YES animated:YES];

}

#pragma mark -
#pragma mark Searching
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideKeyboard];
    [self doSearchForTerm:searchBar.text];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGRect theRect = self.tableView.frame;
    theRect.origin.y += 44;
    clickToDismiss = [[UIButton alloc] initWithFrame:theRect];
    clickToDismiss.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight;
    clickToDismiss.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [clickToDismiss addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchDown |
                                                                                   UIControlEventTouchDragInside
    ];
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:clickToDismiss];
}

//FIX ISSUE #50
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [clickToDismiss removeFromSuperview];
    clickToDismiss = nil;
    self.tableView.scrollEnabled = YES;
}

-(void) hideKeyboard
{
    [clickToDismiss removeFromSuperview];
    clickToDismiss = nil;
    [self becomeFirstResponder];
    self.tableView.scrollEnabled = YES;
}

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
}

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
}

/**
 *
 * Determine what actions can occur when a menu is displayed.
 *
 */
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
//    if (action == @selector(copyStrongs:))        { return YES; }
// ISSUE #61
    if (action == @selector(copy:))        { return YES; }
    if (action == @selector(searchBible:))         { return YES; }
    if (action == @selector(defineStrongs:))      { return selectedWord != nil; }
    return NO;
}
// ISSUE #61
-(void) copy: (id)sender
{
  [self copyStrongs:nil];
}
-(void) copyStrongs: (id)sender
{
  NSMutableString *theText = [[theSearchResults objectAtIndex:selectedRow] mutableCopy];
  NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:selectedRow]];

  [theText appendFormat:@"\n%@: %@\n%@: %@\n%@: %@",
      __T(@"Lemma"),         [theResult objectAtIndex:1],
      __T(@"Pronunciation"), [theResult objectAtIndex:2],
      __T(@"Definition"),    [theResult objectAtIndex:3]
  ];

  UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
  pasteBoard.string = theText;

  UIAlertView *anAlert = [[UIAlertView alloc]
      initWithTitle:__T(@"Notice") message:__Tv(@"definition-copied", @"Definition copied to clipboard") delegate:nil cancelButtonTitle:__T(@"Ok") otherButtonTitles: nil ];
  [anAlert show];
}

-(void) defineStrongs: (id)sender
{
  [self doSearchForTerm:selectedWord byKeyOnly:true];
}

-(void) searchBible: (id)sender
{
    ZUUIRevealController *rc = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKSearchViewController *svc = [[[rvc.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
  
  if (!selectedWord)
  {
    NSString *theSVCTerm = [NSString stringWithFormat:@"\"%@ \"",[theSearchResults objectAtIndex:selectedRow]];
    [svc doSearchForTerm:theSVCTerm
         requireParsings:YES];
  }
  else
  {
    [svc doSearchForTerm: [NSString stringWithFormat:@"\"%@ \"", selectedWord] requireParsings:YES];
  }

}

-(void) didReceiveLongPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p]; // nil if no row
      
        if (indexPath != nil)
        {
            NSUInteger row = [indexPath row];
          
            UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
            NSArray *theSubViews = [theCell subviews];
            PKHotLabel *ourLabel = (PKHotLabel *)[theSubViews lastObject];
          
            CGPoint wp = [gestureRecognizer locationInView: ourLabel ];
            NSString *hotWord = [ourLabel wordFromPoint:wp];
    ourMenu = [UIMenuController sharedMenuController];
    ourMenu.menuItems = [NSArray arrayWithObjects:
// ISSUE #61
//                            [[UIMenuItem alloc] initWithTitle:__T(@"Copy")         action:@selector(copyStrongs:)],
                            [[UIMenuItem alloc] initWithTitle:__T(@"Define")       action:@selector(defineStrongs:)],
                            [[UIMenuItem alloc] initWithTitle:__T(@"Search Bible") action:@selector(searchBible:)]
//                            [[UIMenuItem alloc] initWithTitle:@"Annotate"  action:@selector(doAnnotate:)]
                         , nil ];

            if (hotWord)
            {
              // we have a hot word in the cell...
              selectedWord = hotWord;
              selectedRow = row;
            }
            else
            {
              selectedWord = nil;
              selectedRow = row;
            }
            [self becomeFirstResponder];
            [ourMenu update]; // just in case
            [ourMenu setTargetRect:CGRectMake(p.x, p.y, 1, 1) inView:self.tableView ];
            [ourMenu setMenuVisible:YES animated:YES];

        }
    }
}


#pragma mark -
#pragma mark Hot Label Delegate; this is essentially dead code

-(void) label:(PKHotLabel *)label didTapWord:(NSString *)theWord
{
  // search for the selected word
  //NSLog(@"Received word: %@", theWord);
  [self doSearchForTerm:theWord byKeyOnly:true];
}


@end
