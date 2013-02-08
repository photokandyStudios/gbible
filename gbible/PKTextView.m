//
//  PKTextView.m
//  gbible
//
//  Created by Kerri Shotts on 2/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

#import "PKTextView.h"
#import "PKBible.h"

@implementation PKTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
          [self setupMenu];

    }
    return self;
}

-(void) setupMenu
{
  //add to our menu
  UIMenuController *menuCont = [UIMenuController sharedMenuController];
  menuCont.menuItems = @[ [[UIMenuItem alloc] initWithTitle:__T(@"Insert Reference") action:@selector(insertVerseReference:)],
                          [[UIMenuItem alloc] initWithTitle:__T(@"Insert Verse") action:@selector(insertVerse:)],
                          [[UIMenuItem alloc] initWithTitle:__T(@"Show Verse") action:@selector(showVerse:)],
                          [[UIMenuItem alloc] initWithTitle:__T(@"Define Strong's") action:@selector(defineStrongs:)] ];
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
  NSString *theSelectedWord;
  if (self.selectedTextRange)
  {
    theSelectedWord = [self.text substringWithRange:self.selectedRange];
  }
  if (action == @selector(insertVerseReference:) ||
     (action == @selector(insertVerse:)))
  {
    return YES;
  }
  if (action == @selector(showVerse:))
  {
    if ([theSelectedWord rangeOfString:@":"].location != NSNotFound)
    {
      // might have a verse? Format should be of the form
      // abcdef[space]number:number
      int foundBook = -1;
      int startIndex = -1;
      // first, do we start with a book name?
      for (int i=1; i<=66; i++)
      {
        NSString *theBookName = __T([PKBible nameForBook:i]);
        NSString *theBookAbbr = __T([PKBible abbreviationForBook:i]);
        if ([theSelectedWord hasPrefix:theBookAbbr])
        {
          foundBook = i;
          startIndex = theBookAbbr.length;
        }
        if ([theSelectedWord hasPrefix:theBookName])
        {
          foundBook = i;
          startIndex = theBookName.length;
        }
      }
      if (foundBook>-1)
      {
        NSString *the3LC = [PKBible numericalThreeLetterCodeForBook:foundBook];
        NSString *theRemainder = [theSelectedWord substringFromIndex:startIndex];
        theRemainder = [theRemainder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        theRemainder = [theRemainder stringByReplacingOccurrencesOfString:@":" withString:@"."];
        NSString *theReference = [NSString stringWithFormat:@"%@.%@", the3LC, theRemainder];
        
        int book = [PKBible bookFromString:theReference];
        int chapter = [PKBible chapterFromString:theReference];
        int verse = [PKBible verseFromString:theReference];
        
        if (book>39 && chapter>0 && verse>0)
        {
          return YES; // we have a mostly valid reference
        }
      }
    }
    return NO;
  }
  if (action == @selector(defineStrongs:))
  {
    if ([theSelectedWord hasPrefix:@"G"])
    {
      if ([theSelectedWord length] > 1)
      {
        NSString *theStringIndex = [theSelectedWord substringFromIndex:1];
        int theIndex = [theStringIndex intValue];
        if (theIndex > 0 && theIndex <= 5624)
        {
          return YES;
        }
      }
    }
    return NO;
  }



  return [super canPerformAction:action withSender:sender];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self setupMenu];
  [super touchesBegan:touches withEvent:event];
}

- (void) insertVerseReference: (id)sender
{
  if (self.actionDelegate)
  {
    [self.actionDelegate insertVerseReference];
  }
}

- (void) insertVerse: (id)sender
{
  if (self.actionDelegate)
  {
    [self.actionDelegate insertVerse];
  }
}

-(void) showVerse: (id)sender
{
  if (self.actionDelegate)
  {
    [self.actionDelegate showVerse];
  }
}

-(void) defineStrongs: (id)sender
{
  if (self.actionDelegate)
  {
    [self.actionDelegate defineStrongs];
  }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
