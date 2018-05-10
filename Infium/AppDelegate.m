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

#import "AppDelegate.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation AppDelegate

- (NSString *)clientPlatform{
    return @"iOS";
}

- (NSString *)clientPlatformVersion{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)clientPlatformDevice{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString *)clientPlatformLanguage{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *)clientAppVersion{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //ClientLoginUrl = @"https://infium-eu.appspot.com/api/";
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navController=[[UINavigationController alloc] init];
    MainView *firstController=[[MainView alloc] init];
    [firstController setTitle:@"Infium"];
    [navController pushViewController:firstController animated:NO];
    [self.window setRootViewController:navController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
}

- (void)applicationWillTerminate:(UIApplication *)application{
}

@end
