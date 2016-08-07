//
//  ProfileClass.h
//

#import <Foundation/Foundation.h>


@interface ProfileClass : NSObject

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, strong) NSString *accountUrl;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userProfilePicture;
@property (nonatomic, retain) NSMutableArray *arrfollowers;
@property (nonatomic, retain) NSMutableArray *arrfollowings;
@property (nonatomic, retain) NSString *followers_count;
@property (nonatomic, retain) NSString *following_count;

@end
