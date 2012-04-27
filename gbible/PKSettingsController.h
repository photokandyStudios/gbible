//
//  PKSettingsController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKSettingsController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

    @property (strong, nonatomic) NSArray *layoutSettings;
    @property (strong, nonatomic) NSArray *textSettings;
    @property (strong, nonatomic) NSArray *iCloudSettings;
    @property (strong, nonatomic) NSArray *importSettings;
    @property (strong, nonatomic) NSArray *exportSettings;
    @property (strong, nonatomic) NSArray *versionSettings;
    
    @property (strong, nonatomic) NSArray *settingsGroup;
    
    @property (strong, nonatomic) NSIndexPath *currentPathForPopover;
    @property (strong, nonatomic) UITableViewCell *theTableCell;
@end
