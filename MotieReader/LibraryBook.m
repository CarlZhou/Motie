//
// Created by carlgwork on 2013-02-21.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LibraryBook.h"


@implementation LibraryBook
{

}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.bookTitle forKey:@"bookTitle"];
    [encoder encodeObject:self.bookURL forKey:@"bookURL"];
    [encoder encodeObject:self.latestTitle forKey:@"latestTitle"];
    [encoder encodeObject:self.latestURL forKey:@"latestURL"];
    [encoder encodeObject:self.curReadingURL forKey:@"curReadingURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.bookTitle = [decoder decodeObjectForKey:@"bookTitle"];
        self.bookURL = [decoder decodeObjectForKey:@"bookURL"];
        self.latestTitle = [decoder decodeObjectForKey:@"latestTitle"];
        self.latestURL = [decoder decodeObjectForKey:@"latestURL"];
        self.curReadingURL = [decoder decodeObjectForKey:@"curReadingURL"];
    }
    return self;
}

@end