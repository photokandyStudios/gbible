//
//  PKLayoutControllerDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 1/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKLayoutController;

@protocol PKLayoutControllerDelegate <NSObject>

@required
-(void) didChangeLayout: (PKLayoutController *) sender;

@end