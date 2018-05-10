//
//  Copyright 2012-2017 Marcus Hammar
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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
