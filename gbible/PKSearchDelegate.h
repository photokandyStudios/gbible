//
//  PKSearchDelegate.h
//  gbible
//
//  Created by Kerri Shotts on 2/14/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PKSearchDelegate <NSObject>

@required

-(void) doBibleSearchFor: (NSString *)theTerm;
-(void) doStrongsSearchFor: (NSString *)theTerm;

@end