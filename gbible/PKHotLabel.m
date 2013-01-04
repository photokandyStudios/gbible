//
//  PKHotLabel.m
//  gbible
//
//  Created by Kerri Shotts on 1/1/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "PKHotLabel.h"

@implementation PKHotLabel

@synthesize hotBackgroundColor;
@synthesize hotColor;
@synthesize hotFont;
@synthesize hotWord;
@synthesize boldFontWhenhot;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
  NSString *theText = self.text;      // the text of the label that we need to draw
  NSArray *theWords = [theText componentsSeparatedByString:@" "]; // each word in the text
  
  if ( [theText hasPrefix:@"Matthew 20:30 and"])
  {
    NSLog (@"here!");
  }
  
  UIColor *theRegularColor = self.textColor;
    
  UIFont *theRegularFont = self.font;
  UIFont *theHotFont = self.hotFont;
  if (!theHotFont)
  {
    // no font; find one -- assume self.font's bolded equivalent.
    if (boldFontWhenhot)
    {
        theHotFont = [UIFont fontWithName: [[theRegularFont fontName] stringByAppendingString:@"-Bold"]
                                     size: [theRegularFont pointSize]];
    }
    if (!theHotFont)
    {
      // still no font?
      theHotFont = theRegularFont;
    }
  }
  
  // clear any hot areas
  if ( hotWords )
  {
    [hotWords removeAllObjects];
    [hotWordsRect removeAllObjects];
  }
  else
  {
    hotWords = [[NSMutableArray alloc] init];
    hotWordsRect = [[NSMutableArray alloc] init];
  }
  
  CGFloat x = 0;
  CGFloat y = 0;
  CGFloat rectWidth = rect.size.width;
  CGFloat spaceWidth = [@" " sizeWithFont:theRegularFont].width;
  CGFloat fontHeight = [@"M" sizeWithFont:theRegularFont].height;

  for (int i=0; i<[theWords count]; i++)
  {
    NSString *theWord = theWords[i];
    
    // is theWord a hotWord?
    BOOL isHot = ([theWord rangeOfString:hotWord options:NSDiacriticInsensitiveSearch &&
                                                         NSCaseInsensitiveSearch].location != NSNotFound);
    
    // do we have a comparator?
    if (self.hotComparator)
    {
      isHot |= self.hotComparator(theWord);
    }
    
    CGSize sizeOfTheWord = [theWord sizeWithFont: (isHot ? theHotFont : theRegularFont) ];
    
    // will the word go off the side?
    if ( x + sizeOfTheWord.width > rectWidth )
    {
      x = 0;
      y += fontHeight;
    }
    
    //draw the word
    if (isHot)
    {
      // set the color and background
      if (hotBackgroundColor)
      {
        [hotBackgroundColor setFill];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect( context, CGRectMake(x, y, sizeOfTheWord.width, sizeOfTheWord.height) );
      }
      [hotColor setFill];
      
      // oh, and by the way -- since we're hot, add this to our arrays
      [hotWords addObject:theWord];
      [hotWordsRect addObject:[NSValue valueWithCGRect:CGRectMake(x, y, sizeOfTheWord.width, sizeOfTheWord.height)]];
    }
    else
    {
      [theRegularColor setFill];
    }
    
    [theWord drawAtPoint:CGPointMake(x, y) withFont:(isHot ? theHotFont : theRegularFont)];
    
    x += sizeOfTheWord.width + spaceWidth;
    
  }

}

- (NSString *)wordFromPoint: (CGPoint)thePoint
{
  for (int i=0; i<[hotWords count]; i++)
  {
    NSString *theWord = hotWords[i];
    CGRect theWordRect = [ ((NSValue *)hotWordsRect[i]) CGRectValue ];
    
    if (CGRectContainsPoint(theWordRect, thePoint))
    {
      return theWord;
    }
  }
  return nil;
}

@end
