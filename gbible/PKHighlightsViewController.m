//
//  PKHighlightsViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKHighlightsViewController.h"
#import "PKHighlights.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
#import "PKBibleViewController.h"
#import "PKRootViewController.h"

@interface PKHighlightsViewController ()

@end

@implementation PKHighlightsViewController

    @synthesize highlights;

# pragma mark -
# pragma mark view lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.backgroundView = nil; 
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)reloadHighlights
{
    // load all highlights
    highlights = [[PKHighlights instance] allHighlightedPassages];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
    [self reloadHighlights];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

#pragma mark -
#pragma mark tableview

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [highlights count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *highlightCellID = @"PKHighlightCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:highlightCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier:highlightCellID];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *thePassage = [highlights objectAtIndex:row];
    int theBook = [PKBible bookFromString:thePassage];
    int theChapter = [PKBible chapterFromString:thePassage];
    int theVerse = [PKBible verseFromString:thePassage];
    NSString *thePrettyPassage = [NSString stringWithFormat:@"%@ %i:%i",
                                           [PKBible nameForBook:theBook], theChapter, theVerse];
                                           
    
    cell.textLabel.text = thePrettyPassage;
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath   
{
    NSUInteger row = [indexPath row];
    NSString *thePassage = [highlights objectAtIndex:row];

    UIColor *theColor = [[PKHighlights instance] highlightForPassage:thePassage];
    if (theColor != nil)
    {
        cell.backgroundColor = theColor;
    }
    else 
    {
        cell.backgroundColor = [UIColor clearColor];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *thePassage = [highlights objectAtIndex:row];
    int theBook = [PKBible bookFromString:thePassage];
    int theChapter = [PKBible chapterFromString:thePassage];
    int theVerse = [PKBible verseFromString:thePassage];
    
    ZUUIRevealController  *rc = (ZUUIRevealController *)self.parentViewController
                                                            .parentViewController;
    PKRootViewController *rvc = (PKRootViewController *)rc.frontViewController;
        
    PKBibleViewController *bvc = [[[rvc.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];     
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [rc revealToggle:self];

    [bvc displayBook:theBook andChapter:theChapter andVerse:theVerse];
    
  
}

@end
