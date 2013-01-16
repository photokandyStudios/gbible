//
//  PKHotLabelDelagate.h
//  gbible
//
//  Created by Kerri Shotts on 1/1/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKHotLabel;

@protocol PKHotLabelDelegate <NSObject>

@required
-(void)label: (PKHotLabel *) label didTapWord: (NSString *) theWord;

@end