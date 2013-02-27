//
//  UIBarButtonItem+Utility.m
//  gbible
//
//  Created by Kerri Shotts on 2/17/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

// ============================ LICENSE ============================
//
// The code that is not otherwise licensed or is owned by photoKandy
// Studios LLC is hereby licensed under a CC BY-NC-SA 3.0 license.
// That is, you may copy the code and use it for non-commercial uses
// under the same license. For the entire license, see
// http://creativecommons.org/licenses/by-nc-sa/3.0/.
//
// Furthermore, you may use the code in this app for your own
// personal or educational use. However you may NOT release a
// competing app on the App Store without prior authorization and
// significant code changes. If authorization is granted, attribution
// must be kept, but you must also add in your own attribution. You
// must also use your own API keys (TestFlight, Parse, etc.) and you
// must provide your own support. As the code is released for non-
// commercial purposes, any directly competing app based on this code
// must not require payment of any form (including ads).
//
// Attribution must be visual and be of the form:
//
//   Portions of this code from Greek Interlinear Bible,
//   (C) photokandy Studios LLC and Kerri Shotts, released
//   under a CC BY-NC-SA 3.0 license.
//
// NOTE: The graphical assets are not covered under the above license.
// They are copyright their respective owners. Any third party code
// (such as that under the Third Party section) are licensed under
// their respective licenses.
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
