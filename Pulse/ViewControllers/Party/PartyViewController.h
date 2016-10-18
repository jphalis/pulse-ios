//
//  PartyViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface PartyViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet SDIAsyncImageView *partyImageField;
@property (weak, nonatomic) IBOutlet UILabel *partyNameField;
@property (weak, nonatomic) IBOutlet UILabel *partyDateTimeField;
@property (weak, nonatomic) IBOutlet UILabel *partyAddressField;
@property (weak, nonatomic) IBOutlet UILabel *partyAttendingField;
@property (weak, nonatomic) IBOutlet UILabel *partyRequestsField;
@property (weak, nonatomic) IBOutlet UITextView *partyDescriptionField;
@property (weak, nonatomic) IBOutlet UIImageView *inviteIcon;
@property (weak, nonatomic) IBOutlet UIButton *attendBtn;
@property (retain, nonatomic) NSString *partyUrl;
@property (retain, nonatomic) NSString *partyId;
@property (retain, nonatomic) NSString *partyCreator;
@property (retain, nonatomic) NSString *partyInvite;
@property (retain, nonatomic) NSString *partyType;
@property (retain, nonatomic) NSString *partyName;
@property (retain, nonatomic) NSString *partyAddress;
@property (retain, nonatomic) NSString *partySize;
@property (retain, nonatomic) NSString *partyMonth;
@property (retain, nonatomic) NSString *partyDay;
@property (retain, nonatomic) NSString *partyYear;
@property (retain, nonatomic) NSString *partyStartTime;
@property (retain, nonatomic) NSString *partyEndTime;
@property (retain, nonatomic) NSString *partyImage;
@property (retain, nonatomic) NSString *partyDescription;
@property (retain, nonatomic) NSString *partyAttending;
@property (retain, nonatomic) NSString *partyRequests;
@property (retain, nonatomic) NSMutableArray *usersAttending;
@property (retain, nonatomic) NSMutableArray *usersRequested;
@property (retain, nonatomic) NSMutableArray *usersInvited;
@property (nonatomic, assign) BOOL popToRoot;

- (IBAction)onBack:(id)sender;
- (IBAction)onAttend:(id)sender;
- (IBAction)onMore:(id)sender;
- (IBAction)onAttendees:(id)sender;
- (IBAction)onRequests:(id)sender;

@end
