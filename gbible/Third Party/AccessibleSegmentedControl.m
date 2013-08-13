//
//  AccessibleSegmentedControl.m
//
//  Created by Canis Lupus on 02/02/2012.
//  Copyright (c) 2012 Wooji Juice. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of the company nor the names of its contributors may be 
//    used to endorse or promote products derived from this software without 
//    specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "AccessibleSegmentedControl.h"


@interface AccessibleSegmentedControl ()
{
    NSArray*                segmentAccessibilityLabels;
}
@end


@implementation AccessibleSegmentedControl

@synthesize segmentAccessibilityLabels;


- (void)dealloc 
{
    self.segmentAccessibilityLabels = nil;
    [super dealloc];
}


- (void)ensureAccessibilityLabels
{
    if (!segmentAccessibilityLabels) return;
    
    NSArray* sortedSegments = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView* view1, UIView* view2) {
        return view1.frame.origin.x - view2.frame.origin.x;
    }];
    
    int index = 0;
    for (UIView* view in sortedSegments)
    {
        if (self.accessibilityLabel)
            view.accessibilityLabel = [NSString stringWithFormat:@"%@: %@",self.accessibilityLabel,[segmentAccessibilityLabels objectAtIndex:index]];
        else
            view.accessibilityLabel = [segmentAccessibilityLabels objectAtIndex:index];
        
        if (index==self.selectedSegmentIndex)
            view.accessibilityTraits |= UIAccessibilityTraitSelected;
        else
            view.accessibilityTraits &= ~UIAccessibilityTraitSelected;
        
        if ([self isEnabledForSegmentAtIndex:index])
            view.accessibilityTraits &= ~UIAccessibilityTraitNotEnabled;
        else
            view.accessibilityTraits |= UIAccessibilityTraitNotEnabled;
        index++;
    }    
}


- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
    [super setImage:image forSegmentAtIndex:segment];
    [self ensureAccessibilityLabels];
}


- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    [self ensureAccessibilityLabels];
}


- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment
{
    [super setEnabled:enabled forSegmentAtIndex:segment];
    [self ensureAccessibilityLabels];
}


- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [super insertSegmentWithTitle:title atIndex:segment animated:animated];
    [self ensureAccessibilityLabels];
}


- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [super insertSegmentWithImage:image atIndex:segment animated:animated];
    [self ensureAccessibilityLabels];
}


- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [super removeSegmentAtIndex:segment animated:animated];
    [self ensureAccessibilityLabels];
}


- (void)setSegmentAccessibilityLabels:(NSArray *)newSegmentAccessibilityLabels
{
    [newSegmentAccessibilityLabels retain];
    [segmentAccessibilityLabels release];
    segmentAccessibilityLabels = newSegmentAccessibilityLabels;
    [self ensureAccessibilityLabels];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self ensureAccessibilityLabels];
}


@end
