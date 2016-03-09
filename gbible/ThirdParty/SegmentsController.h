//
//  SegmentManager.h
//  NavBasedSeg
//
//  Created by Marcus Crafter on 25/06/10.
//  Copyright 2010 Red Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SegmentsController : NSObject {
    NSArray                * viewControllers;
    UINavigationController * navigationController;
}

@property (nonatomic, strong, readonly) NSArray                * viewControllers;
@property (nonatomic, strong, readonly) UINavigationController * navigationController;

- (id)initWithNavigationController:(UINavigationController *)aNavigationController
                   viewControllers:(NSArray *)viewControllers;

- (void)indexDidChangeForSegmentedControl:(UISegmentedControl *)aSegmentedControl;

@end
