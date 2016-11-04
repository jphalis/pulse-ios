//
//  ProfileClass.h
//

#import <Foundation/Foundation.h>


@interface ProfileClass : NSObject

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userProfilePicture;
@property (nonatomic, retain) NSMutableArray *arrfollowers;
@property (nonatomic, retain) NSMutableArray *arrfollowings;
@property (nonatomic, retain) NSString *event_count;
@property (nonatomic, retain) NSString *followers_count;
@property (nonatomic, retain) NSString *following_count;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, assign) BOOL isPrivate;

@end
