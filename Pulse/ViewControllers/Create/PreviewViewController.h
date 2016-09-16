//
//  PreviewViewController.h
//  Pulse
//

#import <UIKit/UIKit.h>
#import "SDIAsyncImageView.h"


@interface PreviewViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet SDIAsyncImageView *partyImageField;
@property (weak, nonatomic) IBOutlet UILabel *partyNameField;
@property (weak, nonatomic) IBOutlet UILabel *partyDateTimeField;
@property (weak, nonatomic) IBOutlet UILabel *partyAddressField;
@property (weak, nonatomic) IBOutlet UIImageView *inviteIcon;
@property (weak, nonatomic) IBOutlet UITextView *partyDescriptionField;
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

- (IBAction)addImage:(id)sender;
- (IBAction)onPrevious:(id)sender;
- (IBAction)onProceed:(id)sender;

@end
