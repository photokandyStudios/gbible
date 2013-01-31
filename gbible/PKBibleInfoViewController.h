//
//  PKBibleInfoViewController.h
//  gbible
//
//  Created by Kerri Shotts on 1/30/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAConfirmButton.h"
#import "PKBibleDelegate.h"

@interface PKBibleInfoViewController : UIViewController

@property int theBibleID;
@property (strong, nonatomic) UILabel * theBibleTitle;
@property (strong, nonatomic) UILabel * theBibleAbbreviation;
@property (strong, nonatomic) UIImageView * theBibleImage;
@property (strong, nonatomic) UILabel * theBibleImageAbbr;
@property (strong, nonatomic) UIWebView * theBibleInformation;
@property (strong, nonatomic) MAConfirmButton * theActionButton;

@property (nonatomic, assign) id <PKBibleDelegate> delegate;

- (id)initWithBibleID: (int) bibleID;

@end
