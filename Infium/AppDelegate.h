#import <UIKit/UIKit.h>
#import "MainView.h"

#define ClientPlatform [((AppDelegate *)[[UIApplication sharedApplication] delegate]) clientPlatform]
#define ClientPlatformVersion [((AppDelegate *)[[UIApplication sharedApplication] delegate]) clientPlatformVersion]
#define ClientPlatformDevice [((AppDelegate *)[[UIApplication sharedApplication] delegate]) clientPlatformDevice]
#define ClientPlatformLanguage [((AppDelegate *)[[UIApplication sharedApplication] delegate]) clientPlatformLanguage]
#define ClientAppVersion [((AppDelegate *)[[UIApplication sharedApplication] delegate]) clientAppVersion]
#define ClientLoginToken ((AppDelegate *)[[UIApplication sharedApplication] delegate]).token
#define ClientLoginCompany ((AppDelegate *)[[UIApplication sharedApplication] delegate]).company
#define ClientLoginUrl ((AppDelegate *)[[UIApplication sharedApplication] delegate]).url

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property NSMutableData *receivedDataPing;
@property NSURLConnection *connectionPing;
@property NSString *token;
@property NSString *company;
@property NSString *url;

- (NSString *)clientPlatform;
- (NSString *)clientPlatformVersion;
- (NSString *)clientPlatformDevice;
- (NSString *)clientPlatformLanguage;
- (NSString *)clientAppVersion;

@end
