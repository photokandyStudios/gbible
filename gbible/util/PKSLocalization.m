//
//  PKSLocalization.m
//  gbible
//
//  Created by Kerri Shotts on 9/12/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>



NSString * __T(NSString * k) {
  return [[NSBundle mainBundle] localizedStringForKey : k value : k table : nil];
}

NSString * __Tv(NSString * k, NSString * v) {
  return [[NSBundle mainBundle] localizedStringForKey : k value : v table : nil];
}

NSString * __Tvt(NSString * k, NSString * v, NSString * t) {
  return [[NSBundle mainBundle] localizedStringForKey : k value : v table : t];
  
}
