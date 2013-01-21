//
//  searchutils.c
//  gbible
//
//  Created by Kerri Shotts on 1/21/13.
//  Copyright (c) 2013 photoKandy Studios LLC. All rights reserved.
//

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
  // Words separated by SPACES will thus be transformed into LIKE "%word%". Any suspicious
  // characters (", /, ;) will be removed prior. All words will be transformed to lowercase
  // for proper searching.
  NSMutableString *searchPhrase =
    [[[theTerm lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] mutableCopy];

  BOOL exactMatch               = NO;

  if ([searchPhrase characterAtIndex: 0] == '"'
      && [searchPhrase characterAtIndex: [searchPhrase length] - 1] == '"')
  {
    exactMatch = YES;
  }

  [searchPhrase replaceOccurrencesOfString: @"\"" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @";" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @"/" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @"\\" withString: @"" options: 0 range: NSMakeRange(0, [searchPhrase length])];
  [searchPhrase replaceOccurrencesOfString: @"%" withString: @"%%" options: 0 range: NSMakeRange(0, [searchPhrase length])];

  if (!exactMatch)
  {
    NSArray *allTerms = [searchPhrase componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    searchPhrase = [@"" mutableCopy];

    for (int i = 0; i < [allTerms count]; i++)
    {
      NSMutableString *theWord = [[allTerms objectAtIndex: i] mutableCopy];

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
      [searchPhrase appendString: [[theWord lowercaseString] stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [
                                     NSLocale currentLocale]]];
      [searchPhrase appendString: @"\"))"];
    }
  }
  else
  {
    NSString *theWord = searchPhrase;
    searchPhrase = [@"" mutableCopy];
    [searchPhrase appendFormat: @"doesContain(TRIM(%@),\"", theColumn];
    [searchPhrase appendString: [[theWord lowercaseString] stringByFoldingWithOptions: NSDiacriticInsensitiveSearch locale: [
                                   NSLocale currentLocale]]];
    [searchPhrase appendString: @"\")"];
  }

  return searchPhrase;
}