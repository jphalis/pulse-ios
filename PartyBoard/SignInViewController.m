//
//  SignInViewController.m
//  Partyboard
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Main Screen Account Buttons


- (IBAction)loginWithFacebook:(id)sender {
    
    [self loginWithFacebook];
    
}





// Account Button Handlers





// Facebook
- (void)loginWithFacebook {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"user_friends", @"user_birthday"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             NSLog(@"Result: %@", result);
             
             // Facbeook Graph API Request Call
             NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
             [parameters setValue:@"id, name, email, gender, birthday" forKey:@"fields"];
             FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
             [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (error != nil) {
                     NSLog(@"FBSDKGraphRequest error: %@", [error localizedDescription]);
                 }
                 else {
                     // result is a dictionary with the user's Facebook data
                     NSDictionary *usersData = (NSDictionary *)result;
                     // Facebook ID
                     NSString *facebookID = userData[@"id"];
                     NSLog(@"UserID: %@", facebookID);
                     // Facbeook Username
                     NSString *facebookUserNames = userData[@"name"];
                     NSLog(@"Facebook Name: %@", facebookUserName);
                     // Facebook Gender
                     NSString *gender = usersData[@"gender"];
                     NSInteger userGender;
                     if ([gender isEqualToString:@"male"]) userGender = 1;
                     else userGender = 0;
                     // Facebook Birthday
                     NSString *birthday = userData[@"birthday"];
                     NSDateFormatter *FBDFormat = [[NSDateFormatter alloc] init];
                     [FBDFormat setDateFormat:@"MM/dd/yyyy"];
                     NSDate *birthdayDate = [FBDFormat dateFromString:birthday];
                     NSLog(@"Birthday: %@", birthdayDate);
                     
                     
                     
                     // Facebook Profile Picture
                     NSURL *FBPicsURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200", facebookID]];
                     
                     NSURLRequest *FBPURLRequest = [NSURLRequest requestWithURL:FBPicURL];
                     
                     
                     
                     // Check for active iCloud account
                     
                     [self didAlwaysAuthenticateWithiCloudWithData:userData];
                     
                 }
             }];    // @END facebook data request
             
         }
     }];
}

- (void)didAuthenticateWithiCloudWithData:(NSDictionary *)userData {
    
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus == CKAccountStatusNoAccount) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in to iCloud"
                                                                           message:@"Sign in to your iCloud account to write records. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            // We good.
            
   
            
            [publicDatabase saveRecord:newUser completionHandler:^(CKRecord *record, NSError *error){
                if (!error) {
                    // Insert successfully saved record code
                    NSLog(@"Welcome!");
                }
                else {
                    // Insert error handling
                    NSLog(@"Something went wrong%@", [error localizedDescription]);
                    
                }
                
                // Proceed to create user with CloudKit
                NSLog(@"User Data: %@", userData);
                CKRecordID *newUserID = [[CKRecordID alloc] initWithRecordName:userData[@"id"]];
                CKRecord *newUser = [[CKRecord alloc] initWithRecordType:@"Accounts" recordID:newUserID];
                
                // Save the record
                CKContainer *myContainer = [CKContainer defaultContainer];
                CKDatabase *publicDatabase = [myContainer publicCloudDatabase];
                
            }];
            
            
        }
    }];
    
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
