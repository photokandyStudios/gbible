//
//  PKHistoryViewController.h
//  gbible
//
//  Created by Kerri Shotts on 4/2/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKHistoryViewController : UITableViewController

    @property (strong, nonatomic) NSArray *history;
    @property (strong, nonatomic) UILabel *noResults;
    
    -(void)reloadHistory;

@end
