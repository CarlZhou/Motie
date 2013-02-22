//
//  LibraryViewCellBtn.h
//  MotieReader
//
//  Created by Zian Zhou on 2013-02-21.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryBook.h"

@protocol LibraryViewCellBtnDelegate <NSObject>

- (void)continueBtnPressedForCellAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface LibraryViewCellBtn : UIButton

@property NSIndexPath *btnIndexPath;
@property (nonatomic, strong) id <LibraryViewCellBtnDelegate> delegate;

@end
