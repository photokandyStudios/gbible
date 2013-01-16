//
//  PKTableViewCell.h
//  gbible
//
//  Created by Kerri Shotts on 4/25/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKTableViewCell : UITableViewCell

    @property (strong, nonatomic) NSArray * labels;
    @property (strong, nonatomic) UIColor * highlightColor;
    @property (strong, nonatomic) UIColor * selectedColor;
    
@end
