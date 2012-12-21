//
//  PKHistory.m
//  gbible
//
//  Created by Kerri Shotts on 4/7/12.
//  Copyright (c) 2012 photoKandy Studios LLC. All rights reserved.
//

#import "PKHistory.h"
#import "PKDatabase.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PKBible.h"

@implementation PKHistory

    static id _instance;

    +(id) instance
    {
        @synchronized (self)
        {
            if (!_instance)
            {
                _instance = [[self alloc] init];
                
                //create our scheme, if not already done. TODO: What about cleaning it up?
                [_instance createSchema];
            }
        }
        return _instance;
    }

    -(NSMutableArray *)mostRecentPassages
    {
        return [self mostRecentPassagesWithLimit:200];
    }
    -(NSMutableArray *)mostRecentPassagesWithLimit: (int) theLimit
    {
        FMDatabase *content = ((PKDatabase*) [PKDatabase instance]).content;
        FMResultSet *s = [content executeQuery:@"SELECT DISTINCT book,chapter,verse FROM history ORDER BY seq DESC LIMIT ?",
                                                [NSNumber numberWithInt:theLimit] ];
        NSMutableArray *theArray = [[NSMutableArray alloc] init];
        while ([s next])
        {
            int theBook = [s intForColumnIndex:0];
            int theChapter = [s intForColumnIndex:1];
            int theVerse = [s intForColumnIndex:2];
            
            NSString *thePassage = [PKBible stringFromBook:theBook forChapter:theChapter forVerse:theVerse];
            [theArray addObject:thePassage];
        }
        return theArray;
    }

    -(void) addPassage: (NSString *)thePassage
    {
        int theBook = [PKBible bookFromString:thePassage];
        int theChapter = [PKBible chapterFromString:thePassage];
        int theVerse = [PKBible verseFromString:thePassage];
        [self addPassagewithBook:theBook andChapter:theChapter andVerse:theVerse];
    }
    -(void) addPassagewithBook: (int) theBook andChapter: (int) theChapter andVerse: (int) theVerse
    {
        FMDatabase *content = ((PKDatabase*) [PKDatabase instance]).content;
        BOOL theResult = YES;
        
        theResult = [content executeUpdate:@"INSERT INTO history VALUES (NULL,?,?,?)",
                         [NSNumber numberWithInt:theBook], 
                         [NSNumber numberWithInt:theChapter], 
                         [NSNumber numberWithInt:theVerse]];
        if (!theResult)
        {
            NSLog ( @"Couldn't add history.");
        }
        
    }
    -(void) createSchema
    {
        BOOL returnVal = YES;
        // get local versions of our databases
        FMDatabase *content = ((PKDatabase*) [PKDatabase instance]).content;

        returnVal = [content executeUpdate:@"CREATE TABLE history ( seq INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                book INT NOT NULL, \
                                                chapter INT NOT NULL, \
                                                verse INT NOT NULL \
                                             )"];
        if (returnVal)
        {
            NSLog (@"Created schema for history.");
        }
    }

@end
