//
//  PKNotesViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKNotesViewController : UITableViewController

    @property (strong, nonatomic) NSArray *notes;
    @property (strong, nonatomic) UILabel *noResults;

- (void)reloadNotes;

@end
