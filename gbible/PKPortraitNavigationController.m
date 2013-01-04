//
//  PKPortraitNavigationController.m
//  gbible
//
//  Created by Kerri Shotts on 1/4/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "PKPortraitNavigationController.h"

@interface PKPortraitNavigationController ()

@end

@implementation PKPortraitNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

@end
