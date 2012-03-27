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

@interface PKBibleBooksController ()

@end

@implementation PKBibleBooksController


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
    //[UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect newFrame = self.navigationController.view.frame;
    newFrame.size.width = 260;
    self.navigationController.view.frame = newFrame;
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
    return 27;
}

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
    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];
    
    PKBibleBookChaptersViewController *bcvc = [[PKBibleBookChaptersViewController alloc]
                                                initWithBook: row + 40];

    [self.navigationController pushViewController:bcvc animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
