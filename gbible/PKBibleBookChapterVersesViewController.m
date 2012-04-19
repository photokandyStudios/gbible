//
//  PKBibleBookChapterVersesViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBibleBookChapterVersesViewController.h"
#import "PKBible.h"
#import "PKBibleViewController.h"
#import "PKRootViewController.h"
#import "ZUUIRevealController.h"

@interface PKBibleBookChapterVersesViewController ()

@end

@implementation PKBibleBookChapterVersesViewController

    @synthesize selectedBook;
    @synthesize selectedChapter;

#pragma mark -
#pragma mark view lifecycle    

/**
 *
 * Set the book and chapter
 *
 */
- (id)initWithBook:(int)theBook withChapter:(int)theChapter
{
    self = [super init];
    if (self) {
        // Custom initialization
        selectedBook = theBook;
        selectedChapter = theChapter;
    }
    return self;
}

/**
 *
 * Set our title and background
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [TestFlight passCheckpoint:@"BIBLE_BOOK_CHAPTER_VERSES"];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = @"Select Verse";
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
 * Return # of verses for the book & chapter
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [PKBible countOfVersesForBook:selectedBook forChapter:selectedChapter];
}

/**
 *
 * Return the cell with a typical reference, like Matthew 1:1
 *
 */
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bibleBookChapterVerseCellID = @"PKBibleBookChapterVerseCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bibleBookChapterVerseCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier:bibleBookChapterVerseCellID];
    }
    
    NSUInteger row = [indexPath row];
    
    cell.textLabel.text = [[PKBible nameForBook: selectedBook] stringByAppendingFormat:@" %i:%i",selectedChapter, row + 1];  // get book + chapter
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

/**
 *
 * If we press a row, we need to tell the BibleView controller to go there
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];

    // we can now form a complete reference. Pass that back to the bible view
    
    ZUUIRevealController  *rc = (ZUUIRevealController *)self.parentViewController
                                                            .parentViewController;
    PKRootViewController *rvc = (PKRootViewController *)rc.frontViewController;
        
    PKBibleViewController *bvc = [[[rvc.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];     
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [rc revealToggle:self];

    [bvc displayBook:selectedBook andChapter:selectedChapter andVerse:row+1];
}


@end
