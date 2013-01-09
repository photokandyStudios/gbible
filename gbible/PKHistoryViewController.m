//
//  PKHistoryViewController.m
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKHistoryViewController.h"
#import "PKHistory.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
#import "PKRootViewController.h"
#import "PKBibleViewController.h"
#import "PKSearchViewController.h"
#import "PKStrongsController.h"
#import "PKSettings.h"
#import "TestFlight.h"

@interface PKHistoryViewController ()

@end

@implementation PKHistoryViewController

    @synthesize history;
      @synthesize noResults;
  
- (void)reloadHistory
{
    history = [(PKHistory *)[PKHistory instance] mostRecentHistory];
    [self.tableView reloadData];
    if ([history count] == 0)
    {
        noResults.text = __Tv(@"no-history", @"You've no history.");
    }
    else 
    {
        noResults.text = @"";
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TestFlight passCheckpoint:@"HISTORY"];

    self.tableView.backgroundView = nil; 
    self.tableView.backgroundColor = [PKSettings PKSelectionColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    CGRect theRect = CGRectMake(0, self.tableView.center.y + 20, 260, 60);
    noResults = [[UILabel alloc] initWithFrame:theRect];
    noResults.textColor = [PKSettings PKTextColor];
    noResults.font = [UIFont fontWithName:@"Zapfino" size:15];
    noResults.textAlignment = UITextAlignmentCenter;
    noResults.backgroundColor = [UIColor clearColor];
    noResults.shadowColor = [UIColor clearColor];
    noResults.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    noResults.numberOfLines = 0;
    [self.view addSubview:noResults];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    history = nil;
    noResults = nil;
}

-(void) updateAppearanceForTheme
{
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
    [self reloadHistory];
    [self updateAppearanceForTheme];
}


- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
    return [history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *historyCellID = @"PKHistoryCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier:historyCellID];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.textColor = [PKSettings PKSidebarTextColor];
  
    NSString *theHistoryItem = [history objectAtIndex:row];
    if ( [theHistoryItem characterAtIndex:0] == 'P')
    {
      // passage
      NSString *thePassage = [theHistoryItem substringFromIndex:1];
      int theBook = [PKBible bookFromString:thePassage];
      int theChapter = [PKBible chapterFromString:thePassage];
      int theVerse = [PKBible verseFromString:thePassage];
      NSString *thePrettyPassage = [NSString stringWithFormat:@"%@ %i:%i",
                                             [PKBible nameForBook:theBook], theChapter, theVerse];
                                             
      cell.textLabel.text = thePrettyPassage;
    }
    else if ( [theHistoryItem characterAtIndex:0] == 'B')
    {
      // Bible search
      NSString *theSearchTerm = [theHistoryItem substringFromIndex:1];
      cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", __T(@"Bible"), theSearchTerm];
    }
    else if ( [theHistoryItem characterAtIndex:0] == 'S')
    {
      // Strongs search
      NSString *theStrongsTerm = [theHistoryItem substringFromIndex:1];
      cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", __T(@"Strong's"), theStrongsTerm];
    }
  

    return cell;

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *theHistoryItem = [history objectAtIndex:row];
    ZUUIRevealController  *rc = (ZUUIRevealController *)self.parentViewController
                                                            .parentViewController;
    PKRootViewController *rvc = (PKRootViewController *)rc.frontViewController;
        
    PKBibleViewController *bvc = [[[rvc.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    PKSearchViewController *sbvc = [[[rvc.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    PKStrongsController *ssvc = [[[rvc.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [rc revealToggle:self];
    if ( [theHistoryItem characterAtIndex:0] == 'P')
    {
      // passage
      NSString *thePassage = [theHistoryItem substringFromIndex:1];
      int theBook = [PKBible bookFromString:thePassage];
      int theChapter = [PKBible chapterFromString:thePassage];
      int theVerse = [PKBible verseFromString:thePassage];
      [bvc displayBook:theBook andChapter:theChapter andVerse:theVerse];
    }
    else if ( [theHistoryItem characterAtIndex:0] == 'B')
    {
      // Bible search
      NSString *theSearchTerm = [theHistoryItem substringFromIndex:1];
      [sbvc doSearchForTerm:theSearchTerm];
    }
    else if ( [theHistoryItem characterAtIndex:0] == 'S')
    {
      // Strongs search
      NSString *theStrongsTerm = [theHistoryItem substringFromIndex:1];
      [ssvc doSearchForTerm:theStrongsTerm];
    }
}

@end
