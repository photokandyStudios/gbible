//
//  PKSearchViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKSearchViewController.h"
#import "PKSettings.h"
#import "PKBible.h"
#import "PKAppDelegate.h"
#import "ZUUIRevealController.h"
#import "PKRootViewController.h"
#import "PKBibleViewController.h"

@interface PKSearchViewController ()

@end

@implementation PKSearchViewController

    @synthesize theSearchBar;
    @synthesize theSearchTerm;
    @synthesize theSearchResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:@"Search"];
        self.theSearchTerm = [[PKSettings instance] lastSearch];
    }
    return self;
}

-(void)doSearchForTerm:(NSString *)theTerm
{
    [self doSearchForTerm:theTerm requireParsings:NO];
}

-(void)doSearchForTerm:(NSString *)theTerm requireParsings:(BOOL)parsings
{
    theSearchResults = nil;
    theSearchTerm = theTerm;
    
    if ([theTerm isEqualToString:@""])
    {
        theSearchResults = nil;
    }
    else
    {
        theSearchResults = [PKBible passagesMatching:theTerm requireParsings:parsings];
    }
    [self.tableView reloadData];
    
    theSearchBar.text = theTerm;
    
    ((PKSettings *)[PKSettings instance]).lastSearch = theTerm;

    UITabBarController *tbc = (UITabBarController *)self.parentViewController.parentViewController;
    tbc.selectedIndex = 1;

}




- (void)viewDidLoad
{
    [super viewDidLoad];

    // add search bar
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    theSearchBar.delegate = self;
    theSearchBar.placeholder = @"Search Term";
    theSearchBar.showsCancelButton = NO;
    theSearchBar.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];

    
    self.tableView.tableHeaderView = theSearchBar;

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
    
    // add navbar items
    UIBarButtonItem *changeReference = [[UIBarButtonItem alloc]
                                        initWithImage:[UIImage imageNamed:@"Listb.png"] 
                                        landscapeImagePhone:[UIImage imageNamed:@"listLandscape.png"]
                                        style:UIBarButtonItemStylePlain 
                                        target:self.parentViewController.parentViewController.parentViewController
                                        action:@selector(revealToggle:)];
    changeReference.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    changeReference.accessibilityLabel = @"Go to passage";
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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self doSearchForTerm:self.theSearchTerm];
}

- (void)viewWillAppear:(BOOL)animated
{
    // reload the search? TODO
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    theSearchResults = nil;
    theSearchTerm = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation  
{
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (theSearchResults != nil)
    {
        return [theSearchResults count];
    }
    else 
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchCellID = @"PKSearchCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:searchCellID];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *thePassage = [theSearchResults objectAtIndex:row];
    int theBook = [PKBible bookFromString:thePassage];
    int theChapter = [PKBible chapterFromString:thePassage];
    int theVerse = [PKBible verseFromString:thePassage];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %i:%@", 
                                                    [PKBible nameForBook:theBook],
                                                    theChapter,
                                                    [PKBible getTextForBook:theBook 
                                                                 forChapter:theChapter 
                                                                   forVerse:theVerse 
                                                                    forSide:2]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %i:%i - %@", 
                                                    [PKBible nameForBook:theBook],
                                                    theChapter,
                                                    theVerse,
                                                    [PKBible getTextForBook:theBook 
                                                                 forChapter:theChapter 
                                                                   forVerse:theVerse 
                                                                    forSide:1]];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    ZUUIRevealController *rc = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKBibleViewController *bvc = [[[rvc.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    NSString *thePassage = [theSearchResults objectAtIndex:row];
    int theBook = [PKBible bookFromString:thePassage];
    int theChapter = [PKBible chapterFromString:thePassage];
    int theVerse = [PKBible verseFromString:thePassage];

    [bvc displayBook:theBook andChapter:theChapter andVerse:theVerse];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Searching
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self doSearchForTerm:searchBar.text];
    [self becomeFirstResponder];
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
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
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

@end
