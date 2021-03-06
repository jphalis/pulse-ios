//
//  PartyClass.h
//  

#import <Foundation/Foundation.h>


@interface PartyClass : NSObject

@property (retain, nonatomic) NSString *partyId;
@property (retain, nonatomic) NSString *partyUrl;
@property (retain, nonatomic) NSString *partyCreator;
@property (retain, nonatomic) NSString *partyInvite;
@property (retain, nonatomic) NSString *partyType;
@property (retain, nonatomic) NSString *partyName;
@property (retain, nonatomic) NSString *partyAddress;
@property (retain, nonatomic) NSString *partyLatitude;
@property (retain, nonatomic) NSString *partyLongitude;
@property (retain, nonatomic) NSString *partySize;
@property (retain, nonatomic) NSString *partyMonth;
@property (retain, nonatomic) NSString *partyDay;
@property (retain, nonatomic) NSString *partyYear;
@property (retain, nonatomic) NSString *partyStartTime;
@property (retain, nonatomic) NSString *partyEndTime;
@property (retain, nonatomic) NSString *partyDescription;
@property (retain, nonatomic) NSString *partyImage;
@property (retain, nonatomic) NSString *partyUserProfilePicture;
@property (retain, nonatomic) NSString *partyAttendingCount;
@property (retain, nonatomic) NSString *partyRequestCount;
@property (nonatomic, retain) NSMutableArray *arrAttending;
@property (nonatomic, retain) NSMutableArray *arrRequested;
@property (nonatomic, retain) NSMutableArray *arrInvited;
@property (nonatomic, retain) NSMutableArray *arrLiked;

@end
