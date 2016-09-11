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
#import "PKSettings.h"

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
        _enableVerticalScrollBar = NO; // disables odd scroller; TODO leave enabled for iOS 6?
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showTopShadowWithOpacity: (CGFloat) opacity
{
  return;
}
-(void) showBottomShadowWithOpacity: (CGFloat) opacity
{
  return;
}

-(void)calcShadowPosition: (UIInterfaceOrientation) toInterfaceOrientation
{
  return;
}

-(void)calculateShadows
{
  return;
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
  return;
}

-(void)scrollViewDidScroll: (UIScrollView *) scrollView
{
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

-(UIStatusBarStyle) preferredStatusBarStyle
{
  return [PKSettings PKStatusBarStyle];
}


@end
