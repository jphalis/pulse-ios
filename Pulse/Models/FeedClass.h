//
//  FeedClass.h
//

#import <Foundation/Foundation.h>


@interface FeedClass : NSObject

@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSString *ownerUrl;
@property (nonatomic, retain) NSString *ownerProfilePicture;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *feedText;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *targetUrl;

@end
