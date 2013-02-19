//
//  PKTableViewController.m
//  gbible
//
//  Created by Kerri Shotts on 2/16/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "PKTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WKVerticalScrollBar.h"

@interface PKTableViewController ()

@property (strong, nonatomic) UIImageView  *topShadow;
@property (strong, nonatomic) UIImageView *bottomShadow;

@property (strong, nonatomic) WKVerticalScrollBar *verticalScrollBar;

@end

@implementation PKTableViewController
@synthesize topShadow;
@synthesize bottomShadow;
@synthesize verticalScrollBar;

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

    topShadow                     = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"topShadow.png"]];
    bottomShadow                  = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bottomShadow.png"]];
    
    topShadow.frame               = CGRectMake(0, 44, self.view.bounds.size.width, 15);
    bottomShadow.frame            = CGRectMake(0, self.view.bounds.size.height - 44 - 20, self.view.bounds.size.width, 15);
    
    topShadow.contentMode         = UIViewContentModeScaleToFill;
    bottomShadow.contentMode      = UIViewContentModeScaleToFill;
    
    topShadow.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
    bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    topShadow.layer.opacity       = 0.0f;
    bottomShadow.layer.opacity    = 0.0f;
    
    [self.view addSubview: topShadow];
    [self.view addSubview: bottomShadow];
  
    self.navigationItem.leftItemsSupplementBackButton = YES;
  
    verticalScrollBar = [[WKVerticalScrollBar alloc] initWithFrame:self.view.bounds];
    verticalScrollBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    verticalScrollBar.scrollView = self.tableView;
  
    [self.view addSubview:verticalScrollBar];
  

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showTopShadowWithOpacity: (CGFloat) opacity;
{
  topShadow.layer.opacity = opacity;
}
-(void) showBottomShadowWithOpacity: (CGFloat) opacity;
{
  bottomShadow.layer.opacity = opacity;
}

-(void)calcShadowPosition: (UIInterfaceOrientation) toInterfaceOrientation
{
  return;
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
  {
    // for iphone we have 44 and 32(?) for the navbar height
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
      topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
    }
    else
    {
      topShadow.frame = CGRectMake(0, 32, self.view.bounds.size.width, 15);
    }
  }
  else
  {
    topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
  }
  
  if ( self.navigationController.isNavigationBarHidden != YES )
  {
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 15);
  }
}

-(void)calculateShadows
{
  CGFloat topOpacity       = 0.0f;
  CGFloat theContentOffset = (self.tableView.contentOffset.y);

  CGRect theFrame = topShadow.frame;
  theFrame.origin.y = theContentOffset;
  //if (!self.navigationController.isNavigationBarHidden && !self.navigationController.navigationBar.isOpaque)
  //{
  //  theFrame.origin.y += self.navigationController.navigationBar.bounds.size.height;
 // }
  [topShadow setFrame:theFrame];
    
  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  topOpacity = (theContentOffset / 15) * 0.5;

  [self showTopShadowWithOpacity: topOpacity];

  CGFloat bottomOpacity = 0.0f;

  theContentOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y -
                     self.tableView.bounds.size.height;

  theFrame = bottomShadow.frame;
  theFrame.origin.y = self.tableView.contentOffset.y + self.tableView.bounds.size.height - theFrame.size.height;
  [bottomShadow setFrame:theFrame];

  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  bottomOpacity = (theContentOffset / 15) * 0.5;

  [self showBottomShadowWithOpacity: bottomOpacity];
  
  theFrame = self.view.bounds;
  theFrame.origin.y = self.tableView.contentOffset.y;
  [verticalScrollBar setFrame:theFrame];
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
  [self calcShadowPosition: toInterfaceOrientation];
}

-(void)scrollViewDidScroll: (UIScrollView *) scrollView
{
  [self calculateShadows];
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}

@end
