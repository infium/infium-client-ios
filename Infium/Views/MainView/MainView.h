#import <UIKit/UIKit.h>
#import "UI.h"

#import "AppDelegate.h"

@interface MainView : UIViewController

@property IBOutlet UIButton *loginButton;
@property IBOutlet UIButton *logoutButton;
@property IBOutlet UIButton *menuButton;

@property IBOutlet UILabel *alreadyLogggedInLabel;
@property IBOutlet UILabel *version;

@property IBOutlet UITextField *url;
@property IBOutlet UITextField *company;
@property IBOutlet UITextField *username;
@property IBOutlet UITextField *password;

@property NSURLConnection *connectionServerFirst;
@property NSURLConnection *connectionServerSecond;
@property NSMutableData *receivedDataServerFirst;
@property NSMutableData *receivedDataServerSecond;

@end
