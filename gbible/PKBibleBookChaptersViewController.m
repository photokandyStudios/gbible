//
//  PKBibleBookChaptersViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBibleBookChaptersViewController.h"
#import "PKBibleBookChapterVersesViewController.h"
#import "PKBible.h"

@interface PKBibleBookChaptersViewController ()

@end

@implementation PKBibleBookChaptersViewController

    @synthesize selectedBook;
    
#pragma mark -
#pragma mark view lifecycle    

/**
 *
 * Initialize; set our selectedBook to the incoming book
 *
 */
- (id)initWithBook:(int)theBook
{
    self = [super init];
    if (self) {
        // Custom initialization
        selectedBook = theBook;
    }
    return self;
}

/**
 *
 * Set our title, adjust background
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = @"Select Chapter";
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
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
 * Get number of chapters for the book
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [PKBible countOfChaptersForBook:selectedBook];
}

/**
 *
 * Return book + chapter in the cell
 *
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bibleBookChapterCellID = @"PKBibleBookChapterCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bibleBookChapterCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier:bibleBookChapterCellID];
    }
    
    NSUInteger row = [indexPath row];
    
    cell.textLabel.text = [[PKBible nameForBook: selectedBook] stringByAppendingFormat:@" %i",row + 1];  // get book + chapter
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

/**
 *
 * When we select a row, push a Verses controller to select the verse
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];
    
    PKBibleBookChapterVersesViewController *bcvc = [[PKBibleBookChapterVersesViewController alloc]
                                                initWithBook:selectedBook withChapter:row+1];

    [self.navigationController pushViewController:bcvc animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
