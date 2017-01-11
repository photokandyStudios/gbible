//
//  searchutils.c
//  gbible
//
//  Created by Kerri Shotts on 1/21/13.
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

#include "PKReference.h"
#include "PKBible.h"

NSString * convertSearchToSQL ( NSString *theTerm, NSString *theColumn )
{

  // in order to support Issue #32 (multiple words), we need to craft a SQL statement
  // based on the inputs. There's really very little risk of SQL injection here --
  // but it should be properly handled.

  // search support is as follows:
  //   * "Jesus Mercy" results in an /Exact Phrase/ search.
  //   * Jesus Mercy results in an OR search: "Jesus" OR "Mercy"
  //   * Jesus +Mercy results in an AND search: "Jesus" AND "Mercy"
  //     * note: a prepended + should be removed
  //   * Jesus -Mercy results in an NAND search: "Jesus" AND NOT "Mercy"
  //   * Jesus%Mercy results in a wildcard search: Jesus, followed by Mercy in the verse.
  //
  NSMutableString *searchPhrase =
    [[theTerm stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] mutableCopy];

  BOOL exactMatch               = NO;
  
  if (searchPhrase.length == 0) {
    return nil;
  }

/*  if (searchPhrase.length>0)
  {
    if ([searchPhrase characterAtIndex: 0] == '"'
        && [searchPhrase characterAtIndex: [searchPhrase length] - 1] == '"')
    {
      exactMatch = YES;
    }
  }
  else
  {
    return nil;
  }
  [searchPhrase replaceOccurrencesOfString: @"\"" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @";" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @"/" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @"\\" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];*/
  [searchPhrase replaceOccurrencesOfString: @"\"" withString: @"\"\"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @"%" withString: @"%%" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  
  while ([searchPhrase rangeOfString:@"  "].location != NSNotFound)
  {
    [searchPhrase replaceOccurrencesOfString: @"  " withString: @" " options: 0 range: NSMakeRange(0, [searchPhrase length])];
  }

  if (!exactMatch)
  {
    NSArray *allTerms = [searchPhrase componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    searchPhrase = [@"" mutableCopy];

    for (int i = 0; i < [allTerms count]; i++)
    {
      NSMutableString *theWord = [allTerms[i] mutableCopy];
      
      BOOL isRef = NO;
      
      if ([theWord hasPrefix:@"["] && [theWord hasSuffix:@"]"]) {
        // reference?
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[in:([A-Za-z0-9]{0,1}[A-Za-z]*)(\\d*)(\\:)*(\\d*)*(\\-*)([A-Za-z0-9]{0,1}[A-Za-z]*)(\\d*)(\\:)*(\\d*)\\]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:theWord options:0 range:NSMakeRange(0,theWord.length)];
        if (matches.count > 0) {
          isRef = YES;
          
          NSUInteger startBook = [PKBible bookForAbbreviation: [theWord substringWithRange: [matches[0] rangeAtIndex:1]]];
          NSUInteger startChapter = [[theWord substringWithRange: [matches[0] rangeAtIndex:2]] integerValue];
          NSUInteger startVerse = [[theWord substringWithRange: [matches[0] rangeAtIndex:4]] integerValue];

          NSUInteger endBook = [PKBible bookForAbbreviation: [theWord substringWithRange: [matches[0] rangeAtIndex:6]]];
          NSUInteger endChapter = [[theWord substringWithRange: [matches[0] rangeAtIndex:7]] integerValue];
          NSUInteger endVerse = [[theWord substringWithRange: [matches[0] rangeAtIndex:9]] integerValue];
          
          if (startBook < 40) {
            startBook = 40;
          }
          if (startChapter < 1) {
            startChapter = 1;
          }
          if (startVerse < 1) {
            startVerse = 1;
          }
          
          if (endBook == startBook && endChapter == 0) {
            endChapter = 999;
          } else if (endChapter == 0) {
            endChapter = startChapter;
          }
          
          if (endBook == startBook && endVerse == 0) {
            endVerse = 999;
          } else if (endVerse == 0) {
            endVerse = startVerse;
          }

          if (endBook < startBook) {
            endBook = startBook;
          }
          
          
          PKReference *startRef = [PKReference referenceWithBook:startBook andChapter:startChapter andVerse:startVerse];
          PKReference *endRef = [PKReference referenceWithBook:endBook andChapter:endChapter andVerse:endVerse];
          
          [searchPhrase appendString: (i != 0 ? @"AND ( ": @"( ")];
          [searchPhrase appendString: @"printf('%sN.%03i.%03i', bibleBook, bibleChapter, bibleVerse) between "];
          [searchPhrase appendFormat: @"'%@' and '%@'", [startRef getPaddedReference], [endRef getPaddedReference]];
          [searchPhrase appendString: @") "];
        }
      }
      
      if (!isRef) {
        switch ([theWord characterAtIndex: 0])
        {
        case '.':
        case '+':[searchPhrase appendString: (i != 0 ? @"AND ( ": @"( ")];
          [theWord deleteCharactersInRange: NSMakeRange(0, 1)];
          break;

        case '!' :
        case '-':[searchPhrase appendString: (i != 0 ? @"AND ( NOT ": @"( NOT ")];
          [theWord deleteCharactersInRange: NSMakeRange(0, 1)];
          break;

        default :            [searchPhrase appendString: (i != 0 ? @"OR ( ": @"( ")];
          break;
        }

        [searchPhrase appendFormat: @"doesContain(TRIM(%@),\"", theColumn];
        [searchPhrase appendString: [theWord stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [
                                       NSLocale currentLocale]]];
        [searchPhrase appendString: @"\", \"\"))"];
      }
    }
  }
  else
  {
    NSString *theWord = searchPhrase;
    searchPhrase = [@"" mutableCopy];
    [searchPhrase appendFormat: @"doesContain(TRIM(%@),\"", theColumn];
    [searchPhrase appendString: [[theWord lowercaseString] stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [
                                   NSLocale currentLocale]]];
    [searchPhrase appendString: @"\", \"\")"];
  }

  return searchPhrase;
}
