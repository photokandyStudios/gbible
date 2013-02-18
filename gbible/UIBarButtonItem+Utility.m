//
//  UIBarButtonItem+Utility.m
//  gbible
//
//  Created by Kerri Shotts on 2/17/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "UIBarButtonItem+Utility.h"
#import "NSString+FontAwesome.h"

@implementation UIBarButtonItem (Utility)

+(UIBarButtonItem *) barButtonItemUsingFontAwesomeIcon: (NSString *)iconKey
                                                target: (id)theTarget
                                                action: (SEL)theAction
                               withTitleTextAttributes: (NSDictionary *)textAttributes
                                    andBackgroundImage: (UIImage *)theImage
{
/*
  UIButton *theButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [theButton addTarget:theTarget action:theAction forControlEvents:UIControlEventTouchUpInside];
  [theButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconKey] forState:UIControlStateNormal];
  [theButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconKey] forState:UIControlStateDisabled];
  [theButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconKey] forState:UIControlStateSelected];
  [theButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:iconKey] forState:UIControlStateHighlighted];
  theButton.backgroundColor = [UIColor clearColor];
  [theButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [theButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
  [theButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
  [theButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
  [theButton setFrame:CGRectMake(0,0,44,44)];

  UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithCustomView:theButton];
*/

  UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier: iconKey]
                                                        style:UIBarButtonItemStylePlain target:theTarget action:theAction];
  [b setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
  [b setBackgroundImage:theImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  b.tag = 498;
  return b;
}

+(UIBarButtonItem *) barButtonItemWithTitle: (NSString *)theTitle
                                     target: (id)theTarget
                                     action: (SEL)theAction
                    withTitleTextAttributes: (NSDictionary *)textAttributes
                         andBackgroundImage: (UIImage *)theImage
{
  UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithTitle:theTitle style:UIBarButtonItemStylePlain target:theTarget action:theAction];
  
  [b setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
  [b setBackgroundImage:theImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  b.tag = 498;
  return b;
}


@end
