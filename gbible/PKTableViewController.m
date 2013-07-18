//
//  PKTableViewController.m
//  gbible
//
//  Created by Kerri Shotts on 2/16/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
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
/*
@synthesize topShadow;
@synthesize bottomShadow;
@synthesize verticalScrollBar;
@synthesize enableVerticalScrollBar;
*/
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _enableVerticalScrollBar = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _topShadow                     = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"topShadow.png"]];
    _bottomShadow                  = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"bottomShadow.png"]];
    
    _topShadow.frame               = CGRectMake(0, 44, self.view.bounds.size.width, 15);
    _bottomShadow.frame            = CGRectMake(0, self.view.bounds.size.height - 44 - 20, self.view.bounds.size.width, 15);
    
    _topShadow.contentMode         = UIViewContentModeScaleToFill;
    _bottomShadow.contentMode      = UIViewContentModeScaleToFill;
    
    _topShadow.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
    _bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _topShadow.layer.opacity       = 0.0f;
    _bottomShadow.layer.opacity    = 0.0f;
    
    [self.view addSubview: _topShadow];
    [self.view addSubview: _bottomShadow];
  
    self.navigationItem.leftItemsSupplementBackButton = YES;
  
    if (_enableVerticalScrollBar)
    {
      _verticalScrollBar = [[WKVerticalScrollBar alloc] initWithFrame:self.view.bounds];
      _verticalScrollBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      _verticalScrollBar.scrollView = self.tableView;
    
      [self.tableView addSubview:_verticalScrollBar];
    }
  

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showTopShadowWithOpacity: (CGFloat) opacity
{
  _topShadow.layer.opacity = opacity;
}
-(void) showBottomShadowWithOpacity: (CGFloat) opacity
{
  _bottomShadow.layer.opacity = opacity;
}

-(void)calcShadowPosition: (UIInterfaceOrientation) toInterfaceOrientation
{
  return;
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
  {
    // for iphone we have 44 and 32(?) for the navbar height
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
      _topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
    }
    else
    {
      _topShadow.frame = CGRectMake(0, 32, self.view.bounds.size.width, 15);
    }
  }
  else
  {
    _topShadow.frame = CGRectMake(0, 44, self.view.bounds.size.width, 15);
  }
  
  if ( self.navigationController.isNavigationBarHidden != YES )
  {
    _topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 15);
  }
}

-(void)calculateShadows
{
  CGFloat topOpacity       = 0.0f;
  CGFloat theContentOffset = (self.tableView.contentOffset.y);

  CGRect theFrame = _topShadow.frame;
  theFrame.origin.y = theContentOffset;
  //if (!self.navigationController.isNavigationBarHidden && !self.navigationController.navigationBar.isOpaque)
  //{
  //  theFrame.origin.y += self.navigationController.navigationBar.bounds.size.height;
 // }
  [_topShadow setFrame:theFrame];
    
  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  //topOpacity = (theContentOffset / 15) * 0.5;

  [self showTopShadowWithOpacity: topOpacity];

  CGFloat bottomOpacity = 0.0f;

  theContentOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y -
                     self.tableView.bounds.size.height;

  theFrame = _bottomShadow.frame;
  theFrame.origin.y = self.tableView.contentOffset.y + self.tableView.bounds.size.height - theFrame.size.height;
  [_bottomShadow setFrame:theFrame];

  if (theContentOffset > 15)
  {
    theContentOffset = 15;
  }
  //bottomOpacity = (theContentOffset / 15) * 0.5;

  [self showBottomShadowWithOpacity: bottomOpacity];
  
  theFrame = self.view.bounds;
  theFrame.origin.y = self.tableView.contentOffset.y;
  [_verticalScrollBar setFrame:theFrame];
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
  [self calcShadowPosition: toInterfaceOrientation];
}

-(void)scrollViewDidScroll: (UIScrollView *) scrollView
{
  [self calculateShadows];
  // THIS SECTION: MIT LICENSE
  if (UIAccessibilityIsVoiceOverRunning())
  {
    // based on based on http://stackoverflow.com/a/8209674/741043
    // This loop has a side effects, see the cell accesor code.
    for (id cell in self.tableView.visibleCells)
      if ( [cell accessibilityElementCount] >0 )
        for (int f = 0; [cell accessibilityElementAtIndex:f]; f++);
  }
  // END MIT LICENSED SECTION
}

-(BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
  return YES;
}


@end
