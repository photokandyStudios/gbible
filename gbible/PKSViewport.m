//
//  PKSViewport.m
//  gbible
//
//  Created by Kerri Shotts on 9/14/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL viewportIsWide() {
  return ([UIApplication sharedApplication].keyWindow.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular);
}

BOOL isWide(UIView *view) {
  return (view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular);
}

BOOL viewportIsNarrow() {
  return ([UIApplication sharedApplication].keyWindow.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
}

BOOL isNarrow(UIView *view) {
  return (view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
}

