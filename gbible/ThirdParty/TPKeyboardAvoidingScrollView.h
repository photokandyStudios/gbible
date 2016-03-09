//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

@interface TPKeyboardAvoidingScrollView : UIScrollView {
    UIEdgeInsets    _priorInset;
    BOOL            _priorInsetSaved;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _originalContentSize;
}

- (void)adjustOffsetToIdealIfNeeded;

// add auto sizing from http://codethink.no-ip.org/wordpress/archives/357
- (void) adjustHeightForCurrentSubviews: (int) verticalPadding;
- (void) adjustWidthForCurrentSubviews: (int) horizontalPadding;
- (void) adjustWidth: (bool) changeWidth andHeight: (bool) changeHeight withHorizontalPadding: (int) horizontalPadding andVerticalPadding: (int) verticalPadding;

@end
