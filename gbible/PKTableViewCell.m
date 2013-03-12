//
//  PKTableViewCell.m
//  gbible
//
//  Created by Kerri Shotts on 4/25/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
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
// ====================================================================
//
// NOTE: THIS FILE IN PARTICULAR IS LICENSED UNDER THE MIT LICENSE.
//
// ====================================================================
#import "PKTableViewCell.h"
#import "PKLabel.h"
#import "PKSettings.h"


@interface PKTableViewCell()

@property (strong, nonatomic) NSMutableArray *accessibilityElements;

@end

@implementation PKTableViewCell

@synthesize labels = _labels;
@synthesize accessibilityElements;
@synthesize highlightColor;
@synthesize selectedColor;

-(void)setLabels:(NSArray *)labels
{
  _labels = labels;
  accessibilityElements = nil;
  if (UIAccessibilityIsVoiceOverRunning())
  {
    accessibilityElements = [[NSMutableArray alloc] initWithCapacity:_labels.count];
    for (int i=0;i<_labels.count; i++)
    {
      PKLabel *theLabel = _labels[i];
      UIAccessibilityElement *ae = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
      ae.accessibilityFrame = [self convertRect:theLabel.frame toView:nil];
      ae.accessibilityLabel = theLabel.text;
      ae.accessibilityTraits = UIAccessibilityTraitStaticText;
      if ( [theLabel.trait hasSuffix:@"Word"] )
      {
        if ([theLabel.trait hasPrefix:@"Greek"])
        {
          ae.accessibilityLanguage = @"grc";
        }
      }
      else
      {
        ae.accessibilityHint = __T(theLabel.trait);
      }
      [accessibilityElements addObject:ae];
    }
  }
}

-(NSArray *)labels
{
  return _labels;
}



-(id)initWithStyle: (UITableViewCellStyle) style reuseIdentifier: (NSString *) reuseIdentifier
{
  self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
  
  if (self)
  {
    // Initialization code
    _labels         = nil;
    highlightColor = nil;
    selectedColor  = nil;
    accessibilityElements = nil;
  }
  return self;
}

-(void)setSelected: (BOOL) selected animated: (BOOL) animated
{
  [super setSelected: selected animated: animated];
  
  // Configure the view for the selected state
}

-(void)drawRect: (CGRect) rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  
  // draw our highlight/select colors
  if (selectedColor)
  {
    [selectedColor set];
    CGContextFillRect(ctx, rect);
  }
  
  if (highlightColor)
  {
    if ( [[PKSettings instance] extendHighlights] )
    {
      CGRect newRect;
      if (rect.size.width >= 1024) // FIX ISSUE #77
      {
        newRect = CGRectMake(rect.origin.x+30, rect.origin.y, rect.size.width-60, rect.size.height);
      }
      else
      {
        newRect = CGRectMake(rect.origin.x+5, rect.origin.y, rect.size.width-10, rect.size.height);
      }
      [highlightColor set];
      CGContextFillRect(ctx, newRect);
    }
    else
    {
      CGContextSetLineWidth(ctx, 1.0);
      [highlightColor set];
      CGRect newRect;
      
      if (rect.size.width >= 1024) // FIX ISSUE #77
      {
        newRect = CGRectMake(rect.origin.x + 5, rect.origin.y + 5, 30, rect.size.height - 10);
      }
      else
      {
        newRect = CGRectMake(rect.origin.x + rect.size.width - 40, rect.origin.y + 10, 30, 30);
      }
      UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect: newRect cornerRadius: 6];
      [roundRect fill];
      
      [[UIColor colorWithWhite: 0.0 alpha: 0.33] set];
      CGRect insetRect = CGRectInset(newRect, -0.5, -0.5);
      
      roundRect = [UIBezierPath bezierPathWithRoundedRect: insetRect cornerRadius: 6];
      [roundRect stroke];
    }
  }
  
  CGContextRestoreGState(ctx);
  
  // do our regular drawing (for subviews and such)
  [super drawRect: rect];
  
  // now do our quick label drawing
  ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  {
    if (_labels)
    {
      for (int i = 0; i < [_labels count]; i++)
      {
        PKLabel *theLabel = [_labels objectAtIndex: i];        
        [theLabel draw: ctx];
      }
    }
  }
  CGContextRestoreGState(ctx);
}

-(void)dealloc
{
  _labels = nil;
  accessibilityElements = nil;
}

#pragma mark -
#pragma mark accessibility

- (void) _recalculateAccessibilityElements
{
  if (accessibilityElements)
  {
    for (int i=0; i<accessibilityElements.count; i++)
    {
      UIAccessibilityElement *ae = accessibilityElements[i];
      PKLabel *theLabel = _labels[i];
      ae.accessibilityFrame = [self convertRect:theLabel.frame toView:nil];
    }
  }
}

- (void) _recalculateAccessibilityElementByIndex: (NSInteger) index
{
  UIAccessibilityElement *ae = accessibilityElements[index];
  PKLabel *theLabel = _labels[index];
  CGRect theFrame = theLabel.frame;
  ae.accessibilityFrame = [self.window convertRect:theFrame fromView:self];
  
}

- (void) setNeedsDisplay
{
  [super setNeedsDisplay];
  //[self _recalculateAccessibilityElements];
}

- (void) setNeedsLayout
{
  [super setNeedsLayout];
  //[self _recalculateAccessibilityElements];
}



- (BOOL) isAccessibilityElement
{
  return UIAccessibilityIsVoiceOverRunning() ? NO : YES;
}

- (NSInteger) accessibilityElementCount
{
  //NSLog (@"Accessibility Count: %i", [_labels count] + [self.subviews count]);
  if (accessibilityElements)
    return [accessibilityElements count] + [self.subviews count];
  else
    return [self.subviews count];
}

- (id) accessibilityElementAtIndex:(NSInteger)index
{
  //NSLog (@"accessibilityElementAtIndex: %i", index);
  NSInteger aCount = 0;
  if (accessibilityElements)
    aCount = accessibilityElements.count;
  
  if (index < aCount)
  {
    if (accessibilityElements)
    {
      UIAccessibilityElement *ae = accessibilityElements[index];
      [self _recalculateAccessibilityElementByIndex:index];
      return ae;
    }
    else
    {
      return nil;
    }
  }
  else
  {
    NSInteger subViewIndex = index - aCount;
    if (self.subviews.count>0)
    {
      if (subViewIndex < self.subviews.count)
      {
        UIView *aView =  self.subviews[subViewIndex] ;
        return aView;
      }
      else
      {
       return nil;
      }
    }
    else
    {
      return nil;
    }
  }
}

- (NSInteger) indexOfAccessibilityElement:(id)element
{
  //NSLog ( @"indexOfAccessibilityElement: %@", [((UIView *)element) description]);
  NSInteger anIndex = NSNotFound;
  if (accessibilityElements)
  {
    anIndex = [accessibilityElements indexOfObject:element];
  }
  if (anIndex == NSNotFound)
  {
    anIndex = [self.subviews indexOfObject:element];
    if (anIndex != NSNotFound)
    {
      anIndex += [self accessibilityElementCount];
    }
  }
  return anIndex;

}


@end