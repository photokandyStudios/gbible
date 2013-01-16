//
//  PKAboutViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKAboutViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *aboutWebView;

@end