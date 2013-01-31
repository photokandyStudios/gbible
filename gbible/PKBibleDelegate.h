//
//  PKBibleDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 1/30/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKBibleDelegate;

@protocol PKBibleDelegate <NSObject>

@required
-(void) installedBiblesChanged;

@end