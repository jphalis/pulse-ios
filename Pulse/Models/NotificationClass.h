//
//  NotificationClass.h
//

#import <Foundation/Foundation.h>


@interface NotificationClass : NSObject

@property (nonatomic, strong) NSString *notificationCount;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSString *senderUrl;
@property (nonatomic, retain) NSString *senderProfilePicture;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *notificationText;
@property (nonatomic, retain) NSString *targetUrl;

@end
