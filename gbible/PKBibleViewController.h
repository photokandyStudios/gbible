//
//  PKBibleViewController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKBibleViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

    @property int gotoRefBook;
    @property int gotoRefChapter;
    @property int gotoRefVerse;
    
    @property (strong, nonatomic) NSArray *currentGreekChapter;
    @property (strong, nonatomic) NSArray *currentEnglishChapter;
    
    @property (strong, nonatomic) NSMutableArray *formattedGreekChapter;
    @property (strong, nonatomic) NSMutableArray *formattedEnglishChapter;
    
    @property (strong, nonatomic) NSMutableArray *formattedGreekVerseHeights;
    @property (strong, nonatomic) NSMutableArray *formattedEnglishVerseHeights;
    
@end
