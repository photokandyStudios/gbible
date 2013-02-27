//
//  PKTextView.m
//  gbible
//
//  Created by Kerri Shotts on 2/3/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
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
#import "PKTextView.h"
#import "PKBible.h"

@implementation PKTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];

          [self setupMenu];

    }
    return self;
}


-(void) menuWillShow: (id)sender
{
  [self setupMenu];
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
/*
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self setupMenu];
  [super touchesBegan:touches withEvent:event];
}
*/
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
