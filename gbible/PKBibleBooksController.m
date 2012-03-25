//
//  PKBibleBooksController.m
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKBibleBooksController.h"

@interface PKBibleBooksController ()

@end

@implementation PKBibleBooksController

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
//        self.modalPresentationStyle = UIModalPresentationFormSheet;
}

- (void)viewDidAppear:(BOOL)animated
{
    //CGRect newFrame = self.view.frame;
    //newFrame.size.width = 260;
    //self.view.frame = newFrame;
    
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

@end
