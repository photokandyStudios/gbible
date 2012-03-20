//
//  PKBibleViewController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBibleViewController.h"
#import "PKBible.h"
#import "PKSettings.h"

@interface PKBibleViewController ()

@end

@implementation PKBibleViewController
    
    @synthesize gotoRefBook;
    @synthesize gotoRefVerse;
    @synthesize gotoRefChapter;
    
    @synthesize currentGreekChapter;
    @synthesize currentEnglishChapter;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Settings"];
    }
    return self;
}
- (void)loadChapter
{
    NSUInteger currentBook = [[PKSettings instance] currentBook];
    NSUInteger currentChapter = [[PKSettings instance] currentChapter];
    currentGreekChapter = [PKBible getTextForBook:currentBook forChapter:currentChapter forSide:1];
    currentEnglishChapter = [PKBible getTextForBook:currentBook forChapter:currentChapter forSide:1];
    self.title = [[PKBible nameForBook:currentBook] stringByAppendingFormat:@" %i",currentChapter];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadChapter];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.945098 green:0.933333 blue:0.898039 alpha:1];
    [self loadChapter];
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
#pragma mark Table View Data Source Methods


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of verses in the current passage
    int currentGreekVerseCount = [currentGreekChapter count];
    int currentEnglishVerseCount = [currentEnglishChapter count];
    int currentVerseCount = MAX(currentGreekVerseCount, currentEnglishVerseCount);
    
    return currentVerseCount;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bibleCellID = @"PKBibleCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bibleCellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:bibleCellID];
    }
//    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *cellData = [currentGreekChapter objectAtIndex:row]; // get verse

    cell.textLabel.text = cellData;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *popover;
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
//    NSArray *cellData = [[settingsGroup objectAtIndex:section] objectAtIndex:row];
    BOOL curValue;
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
