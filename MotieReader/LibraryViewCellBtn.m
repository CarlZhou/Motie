//
//  LibraryViewCellBtn.m
//  MotieReader
//
//  Created by Zian Zhou on 2013-02-21.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import "LibraryViewCellBtn.h"

#define HEX_COLOR_777 [UIColor colorWithRed:0.467 green:0.467 blue:0.467 alpha:1]
#define HEX_COLOR_FFF [UIColor colorWithRed:1 green:1 blue:1 alpha:1]

@implementation LibraryViewCellBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    UIImage *stretchedFollowNormal = [[UIImage imageNamed:@"btn_grey_normal.png"] stretchableImageWithLeftCapWidth:6.5 topCapHeight:14.5];
    UIImage *stretchedFollowPressed = [[UIImage imageNamed:@"btn_grey_pressed.png"] stretchableImageWithLeftCapWidth:6.5 topCapHeight:14.5];
    [self setBackgroundImage:stretchedFollowNormal forState:UIControlStateNormal];
    [self setBackgroundImage:stretchedFollowPressed forState:UIControlStateHighlighted];
    [self setTitle:@"继续阅读" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(didTapped) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)didTapped
{
    if([self.delegate respondsToSelector:@selector(continueBtnPressedForCellAtIndexPath:)]) {
        [self.delegate continueBtnPressedForCellAtIndexPath:self.btnIndexPath];
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
