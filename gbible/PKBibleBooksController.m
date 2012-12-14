//
//  PKBibleBooksController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBibleBooksController.h"
#import "PKBibleBookChaptersViewController.h"
#import "PKBible.h"
#import "PKSettings.h"

@interface PKBibleBooksController ()

@end

@implementation PKBibleBooksController


# pragma mark -
# pragma mark view lifecycle

/**
 *
 * Initialize
 *
 */
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization

    }
    return self;
}

/**
 *
 * set the background color
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [TestFlight passCheckpoint:@"BIBLE_BOOKS"];
    

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [PKSettings PKSelectionColor];
    //PKBaseUIColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"Goto";
    
    [self.view bringSubviewToFront:self.tableView];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

}

-(void) updateAppearanceForTheme
{
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [PKSettings PKSidebarPageColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
}


/**
 *
 * Set our width
 *
 */
- (void)viewDidAppear:(BOOL)animated
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
  [self updateAppearanceForTheme];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

/**
 *
 * keep our width during rotation animation
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
 * 1 section
 *
 */
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 *
 * 27rows
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 27;
}

/**
 *
 * Return the cell with the name of the book
 *
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bibleBookCellID = @"PKBibleBookCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bibleBookCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier:bibleBookCellID];
    }
    
    NSUInteger row = [indexPath row];
    
    cell.textLabel.text = [PKBible nameForBook: row + 40];  // get book name
    cell.textLabel.textColor = [PKSettings PKSidebarTextColor];
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/**
 *
 * Push the Chapter view controller when we select a book.
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];
    
    PKBibleBookChaptersViewController *bcvc = [[PKBibleBookChaptersViewController alloc]
                                                initWithBook: row + 40];

    [self.navigationController pushViewController:bcvc animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
