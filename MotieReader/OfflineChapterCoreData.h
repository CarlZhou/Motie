//
//  OfflineChapterCoreData.h
//  MotieReader
//
//  Created by Zian Zhou on 2013-02-21.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OfflineChapterCoreData : NSManagedObject

@property (nonatomic, retain) NSString * chapterInfo;
@property (nonatomic, retain) NSString * chapterContent;
@property (nonatomic, retain) NSString * currentURL;
@property (nonatomic, retain) NSString * previousURL;
@property (nonatomic, retain) NSString * nextURL;

@end
