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
#import "PKAppDelegate.h"
#import "ZUUIRevealController.h"
#import "PKSearchViewController.h"
#import "PKRootViewController.h"

@interface PKStrongsController ()

@end

@implementation PKStrongsController
    @synthesize theSearchTerm;
    @synthesize theSearchResults;
    @synthesize theSearchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // set our title
        [self.navigationItem setTitle:@"Strong's Lookup"];
        self.theSearchTerm = [[PKSettings instance] lastStrongsLookup];
    }
    return self;
}

-(void)doSearchForTerm:(NSString *)theTerm  
{
    [self doSearchForTerm:theTerm byKeyOnly:NO];
}

-(void)doSearchForTerm:(NSString *)theTerm byKeyOnly:(BOOL)keyOnly
{
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

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // add search bar
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    theSearchBar.delegate = self;
    theSearchBar.placeholder = @"Strong's # or search term";
    theSearchBar.showsCancelButton = NO;
    theSearchBar.tintColor = [UIColor colorWithRed:0.250980 green:0.282352 blue:0.313725 alpha:1.0];

    
    self.tableView.tableHeaderView = theSearchBar;
    
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
    // Release any retained subviews of the main view.
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
    CGFloat theColumnWidth = (theCellWidth) / 2;
    CGSize maxSize = CGSizeMake(theCellWidth, 300);

    theHeight += 10; // the top margin
    theHeight += 20; // the top labels

    theSize = [[theResult objectAtIndex:1] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

    theSize = [[theResult objectAtIndex:3] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    theHeight += theSize.height + 10;

    theSize = [[theResult objectAtIndex:4] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
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
    UILabel *theStrongsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, theColumnWidth, 20)];
    theStrongsLabel.text = [theSearchResults objectAtIndex:row];
    theStrongsLabel.textColor = [UIColor blueColor];
    theStrongsLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
    
    NSArray *theResult = [PKStrongs entryForKey:[theSearchResults objectAtIndex:row]];
    
    UILabel *theLemmaLabel = [[UILabel alloc] initWithFrame:CGRectMake(theColumnWidth+20, 10, theColumnWidth, 20)];
    theLemmaLabel.text = [theResult objectAtIndex:2];
    theLemmaLabel.textAlignment = UITextAlignmentRight;
    theLemmaLabel.textColor = [UIColor blackColor];
    theLemmaLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
    
    CGSize maxSize = CGSizeMake (theCellWidth, 300);
    
    CGSize theSize = [[theResult objectAtIndex:1] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    UILabel *theDerivationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, theCellWidth, theSize.height)];
    theDerivationLabel.text = [theResult objectAtIndex:1];
    theDerivationLabel.textColor = [UIColor blackColor];
    theDerivationLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    theDerivationLabel.lineBreakMode = UILineBreakModeWordWrap;
    theDerivationLabel.numberOfLines = 0;
    
    CGSize theKJVSize = [[theResult objectAtIndex:3] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    UILabel *theKJVLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50 + theSize.height, 
                                                                     theCellWidth, theKJVSize.height)];
    theKJVLabel.text = [theResult objectAtIndex:3];
    theKJVLabel.textColor = [UIColor blackColor];
    theKJVLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    theKJVLabel.lineBreakMode = UILineBreakModeWordWrap;
    theKJVLabel.numberOfLines  = 0;
    
    CGSize theStrongsSize = [[theResult objectAtIndex:4] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:maxSize];
    UILabel *theStrongsDefLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50 + theSize.height + 10 + theKJVSize.height,
                                                                     theCellWidth, theStrongsSize.height)];
    theStrongsDefLabel.text = [theResult objectAtIndex:4];
    theStrongsDefLabel.textColor = [UIColor blackColor];
    theStrongsDefLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    theStrongsDefLabel.lineBreakMode = UILineBreakModeWordWrap;
    theStrongsDefLabel.numberOfLines =0 ;

    [cell addSubview:theStrongsLabel];
    [cell addSubview:theLemmaLabel];
    [cell addSubview:theDerivationLabel];
    [cell addSubview:theKJVLabel];
    [cell addSubview:theStrongsDefLabel];
    

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];


    ZUUIRevealController *rc = (ZUUIRevealController *)[[PKAppDelegate instance] rootViewController];
    PKRootViewController *rvc = (PKRootViewController *)[rc frontViewController];
    PKSearchViewController *svc = [[[rvc.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    
    [svc doSearchForTerm:[theSearchResults objectAtIndex:row] requireParsings:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Searching
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self doSearchForTerm:searchBar.text];
    [self becomeFirstResponder];
}

@end
