//
//  PKBibleBooksController.h
//  gbible
//
//  Created by Kerri Shotts on 3/16/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "PKBibleReferenceDelegate.h"

@interface PKBibleBooksController : PSUICollectionViewController

@property (nonatomic, weak) id <PKBibleReferenceDelegate> delegate;
@property BOOL notifyWithCopyOfVerse;

-(void) updateAppearanceForTheme;


@end