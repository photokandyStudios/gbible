//
//  PKLayoutController.h
//  gbible
//
//  Created by Kerri Shotts on 12/14/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKLayoutControllerDelegate.h"

@interface PKLayoutController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <PKLayoutControllerDelegate> delegate;

@end