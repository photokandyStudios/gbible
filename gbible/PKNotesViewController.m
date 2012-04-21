//
//  PKNotesViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKNotesViewController.h"
#import "PKNotes.h"
#import "PKBible.h"
#import "ZUUIRevealController.h"
#import "PKBibleViewController.h"
#import "PKRootViewController.h"

@interface PKNotesViewController ()

@end

@implementation PKNotesViewController

    @synthesize notes;

- (void)reloadNotes
{
    notes = [(PKNotes *)[PKNotes instance] allNotes];
    [self.tableView reloadData];
}

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
    [TestFlight passCheckpoint:@"ANNOTATIONS"];
    self.tableView.backgroundView = nil; 
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/**
 *
 * Force our width and then reload our highlights
 *
 */
- (void)viewDidAppear:(BOOL)animated
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
    [self reloadNotes];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    notes = nil;
}

/**
 *
 * When animating for rotation, keep our frame at 260
 *
 */
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

/**
 *
 * We have one section
 *
 */
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 *
 * Return the number of highlights
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [notes count];
}

/**
 *
 * Generate a cell for the table. We will fill the cell with the "pretty" passage.
 *
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *highlightCellID = @"PKHighlightCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:highlightCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleSubtitle
                reuseIdentifier:highlightCellID];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *thePassage = [notes objectAtIndex:row];
//    int theBook = [PKBible bookFromString:thePassage];
//    int theChapter = [PKBible chapterFromString:thePassage];
//    int theVerse = [PKBible verseFromString:thePassage];
//    NSString *thePrettyPassage = [NSString stringWithFormat:@"%@ %i:%i",
//                                           [PKBible nameForBook:theBook], theChapter, theVerse];
                                           
    NSArray *theNoteArray = [(PKNotes *)[PKNotes instance] getNoteForPassage:thePassage];
    NSString *theTitle = [theNoteArray objectAtIndex:0];
    NSString *theNote = [theNoteArray objectAtIndex:1];
                                           
    cell.textLabel.text = theTitle;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = theNote;
    cell.detailTextLabel.textColor = [UIColor whiteColor];

    return cell;
}

/**
 *
 * If the user clicks on a highlight, we should navigate to that position in the Bible text.
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSString *thePassage = [notes objectAtIndex:row];
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
