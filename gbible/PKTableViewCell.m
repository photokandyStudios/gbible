//
//  PKTableViewCell.m
//  gbible
//
//  Created by Kerri Shotts on 4/25/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKTableViewCell.h"
#import "PKLabel.h"

@implementation PKTableViewCell

@synthesize labels;
@synthesize highlightColor;
@synthesize selectedColor;

-(id)initWithStyle: (UITableViewCellStyle) style reuseIdentifier: (NSString *) reuseIdentifier
{
  self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
  
  if (self)
  {
    // Initialization code
    labels         = nil;
    highlightColor = nil;
    selectedColor  = nil;
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
    CGContextSetLineWidth(ctx, 1.0);
    [highlightColor set];
    CGRect newRect;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
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
  
  CGContextRestoreGState(ctx);
  
  // do our regular drawing (for subviews and such)
  [super drawRect: rect];
  
  // now do our quick label drawing
  ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  {
    if (labels)
    {
      for (int i = 0; i < [labels count]; i++)
      {
        PKLabel *theLabel = [labels objectAtIndex: i];
        [theLabel draw: ctx];
      }
    }
  }
  CGContextRestoreGState(ctx);
}

-(void)dealloc
{
  labels = nil;
}

@end