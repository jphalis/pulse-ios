//
//  FeedClass.h
//

#import <Foundation/Foundation.h>


@interface FeedClass : NSObject

@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *senderUrl;
@property (nonatomic, retain) NSString *senderProfilePicture;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *feedText;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *targetUrl;

@end
