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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        labels = nil;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    // do our regular drawing (for subviews and such)
    [super drawRect:rect];
    
    // now do our quick label drawing
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    {
        if (labels)
        {
            for (int i=0; i<[labels count]; i++)
            {
                PKLabel* theLabel = [labels objectAtIndex:i];
                [theLabel draw:ctx];
            }
        }
    }
    CGContextRestoreGState(ctx);
}

- (void)dealloc
{
    labels = nil;
}

@end
