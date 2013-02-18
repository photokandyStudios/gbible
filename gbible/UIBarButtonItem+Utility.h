//
//  UIBarButtonItem+Utility.h
//  gbible
//
//  Created by Kerri Shotts on 2/17/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Utility)

+(UIBarButtonItem *) barButtonItemUsingFontAwesomeIcon: (NSString *)iconKey
                                                target: (id)theTarget
                                                action: (SEL)theAction
                               withTitleTextAttributes: (NSDictionary *)textAttributes
                                    andBackgroundImage: (UIImage *)theImage;

+(UIBarButtonItem *) barButtonItemWithTitle: (NSString *)theTitle
                                     target: (id)theTarget
                                     action: (SEL)theAction
                    withTitleTextAttributes: (NSDictionary *)textAttributes
                         andBackgroundImage: (UIImage *)theImage;

@end
