#import "MainView.h"
#import "SBJson.h"

@interface MainView ()

@end

@implementation MainView

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.connectionServerFirst){
        [self.receivedDataServerFirst setLength:0];
    }
    
    if (connection == self.connectionServerSecond){
        [self.receivedDataServerSecond setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.connectionServerFirst){
        [self.receivedDataServerFirst appendData:data];
    }
    
    if (connection == self.connectionServerSecond){
        [self.receivedDataServerSecond appendData:data];
    }
}

-(IBAction)goToMenu{
    UI *Menu = [[UI alloc] initWithNibName:@"UI" bundle:nil];
    
    Menu.startTime = [NSDate date];
    [self.navigationController pushViewController:Menu animated:YES];
    [Menu sendQueryFirstMethod:@"POST" url:ClientLoginUrl body:@""];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.connectionServerFirst){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSDictionary *theData = [[[SBJsonParser alloc] init] objectWithData:self.receivedDataServerFirst];
        
        if (theData == nil){
            [self showAlertMessage:@"Cannot log in" withTitle:nil];
        }
        
        if ([[theData objectForKey:@"Response"] isEqualToString:@"LoginToken"]){
            if ([[theData objectForKey:@"Data"] objectForKey:@"Token"] != nil){
                NSString *newToken = [NSString stringWithString:[[theData objectForKey:@"Data"] objectForKey:@"Token"]];
                
                ClientLoginToken = newToken;
                
                [[NSUserDefaults standardUserDefaults] setObject:ClientLoginCompany forKey:@"company"];
                [[NSUserDefaults standardUserDefaults] setObject:ClientLoginUrl forKey:@"url"];
                [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                self.username.text = nil;
                self.password.text = nil;
                [self.url resignFirstResponder];
                //[self.company resignFirstResponder];
                [self.username resignFirstResponder];
                [self.password resignFirstResponder];
                
                [self goToMenu];
                
                [self redrawButtons];
            }else{
                [self showAlertMessage:@"Wrong username and/or password" withTitle:nil];
            }
            
        }
        self.connectionServerFirst = nil;
        self.receivedDataServerFirst = nil;
        
    }
    
    if (connection == self.connectionServerSecond){
        
        ClientLoginToken = nil;
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self redrawButtons];
        
        self.connectionServerSecond = nil;
        self.receivedDataServerSecond = nil;
        
        [self.username becomeFirstResponder];
    }
    
}

-(void)redrawButtons{
    if (ClientLoginToken == nil){
        [self.url setEnabled:YES];
        //[self.company setEnabled:YES];
        [self.username setEnabled:YES];
        [self.password setEnabled:YES];
        
        [self.url setHidden:NO];
        //[self.company setHidden:NO];
        [self.username setHidden:NO];
        [self.password setHidden:NO];
        
        [self.loginButton setEnabled:YES];
        [self.logoutButton setEnabled:NO];
        [self.menuButton setEnabled:NO];
        
        [self.loginButton setHidden:NO];
        [self.logoutButton setHidden:YES];
        [self.menuButton setHidden:YES];
        
        [self.alreadyLogggedInLabel setHidden:YES];
        [self.version setHidden:NO];
    }else{
        [self.url setEnabled:NO];
        //[self.company setEnabled:NO];
        [self.username setEnabled:NO];
        [self.password setEnabled:NO];
        
        [self.url setHidden:YES];
        //[self.company setHidden:YES];
        [self.username setHidden:YES];
        [self.password setHidden:YES];
        
        [self.loginButton setEnabled:NO];
        [self.logoutButton setEnabled:YES];
        [self.menuButton setEnabled:YES];
        
        [self.loginButton setHidden:YES];
        [self.logoutButton setHidden:NO];
        [self.menuButton setHidden:NO];
        
        [self.alreadyLogggedInLabel setHidden:NO];
        [self.version setHidden:YES];
        
    }
}

-(IBAction)logout{
    NSString *url = [NSString stringWithFormat:@"%@logout/",ClientLoginUrl];
    
    NSURL *urlObj = [NSURL URLWithString:url];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlObj];
    [req setHTTPMethod:@"POST"];
    
    [req setValue:ClientPlatform forHTTPHeaderField:@"X-Client-Platform"];
    [req setValue:ClientPlatformVersion forHTTPHeaderField:@"X-Client-Platform-Version"];
    [req setValue:ClientPlatformDevice forHTTPHeaderField:@"X-Client-Platform-Device"];
    [req setValue:ClientPlatformLanguage forHTTPHeaderField:@"X-Client-Platform-Language"];
    [req setValue:ClientAppVersion forHTTPHeaderField:@"X-Client-App-Version"];
    [req setValue:ClientLoginToken forHTTPHeaderField:@"X-Client-Login-Token"];
    [req setValue:ClientLoginCompany forHTTPHeaderField:@"X-Client-Login-Company"];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    self.connectionServerSecond = theConnection;
    
    if (self.connectionServerSecond) {
        self.connectionServerSecond = theConnection;
        NSMutableData *data = [[NSMutableData alloc] init];
        self.receivedDataServerSecond = data;
    } else {
        [self showAlertMessage:@"Failed to initiate the connection to the server" withTitle:nil];
    }
    
}

-(IBAction)loginButtonTapped{
    bool acceptNoSsl = false;
    NSArray *strings = [self.username.text componentsSeparatedByString:@"@"];
    
    if (!([strings count] == 2 || [strings count] == 3)){
        [self showAlertMessage:@"The username must be in the format 'name@123456'" withTitle:nil];
        return;
    }
    
    if ([strings count] == 3){
        if ([[strings objectAtIndex:2] isEqualToString:@"NOSSL"]){
            acceptNoSsl = true;
        }else{
            [self showAlertMessage:@"The username must be in the format 'name@123456'" withTitle:nil];
            return;
        }
    }

    if (acceptNoSsl == false && ![[self.url.text substringToIndex:8] isEqualToString:@"https://"]){
         [self showAlertMessage:@"The server URL must start with 'https://'" withTitle:nil];
         return;
    }

    [self login];
}

-(void)login{
    NSArray *strings = [self.username.text componentsSeparatedByString:@"@"];
    
    ClientLoginCompany = [strings objectAtIndex:1];
    ClientLoginUrl = self.url.text;
    
    /*
    if ([strings count] > 2){
        ClientLoginUrl = [strings objectAtIndex:2];
    }else{
        ClientLoginUrl = @"https://infium-eu.appspot.com/api/";
    }
     */
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *url = [NSString stringWithFormat:@"%@login/",ClientLoginUrl];
    
    NSURL *urlObj = [NSURL URLWithString:url];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlObj];
    [req setHTTPMethod:@"POST"];
    
    [req setValue:ClientPlatform forHTTPHeaderField:@"X-Client-Platform"];
    [req setValue:ClientPlatformVersion forHTTPHeaderField:@"X-Client-Platform-Version"];
    [req setValue:ClientPlatformDevice forHTTPHeaderField:@"X-Client-Platform-Device"];
    [req setValue:ClientPlatformLanguage forHTTPHeaderField:@"X-Client-Platform-Language"];
    [req setValue:ClientAppVersion forHTTPHeaderField:@"X-Client-App-Version"];
    [req setValue:ClientLoginCompany forHTTPHeaderField:@"X-Client-Login-Company"];
    
    NSMutableData *postBody = [NSMutableData dataWithCapacity:2048];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[strings objectAtIndex:0] forKey:@"Username"];
    [dict setObject:self.password.text forKey:@"Password"];
    
    NSString *json = [[[SBJsonWriter alloc] init] stringWithObject:dict];
    
    [postBody appendData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req setHTTPBody:postBody];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    self.connectionServerFirst = theConnection;
    
    if (self.connectionServerFirst) {
        self.connectionServerFirst = theConnection;
        NSMutableData *data = [[NSMutableData alloc] init];
        self.receivedDataServerFirst = data;
    } else {
        [self showAlertMessage:@"Failed to initiate the connection to the server" withTitle:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.url.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    //self.company.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"company"];
    
    ClientLoginUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"url"];
    ClientLoginCompany = [[NSUserDefaults standardUserDefaults] objectForKey:@"company"];
    ClientLoginToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    if ([self.url.text isEqualToString:@""]){
        self.url.text = @"https://infium-eu.appspot.com/api/";
    }
    
    [self setTitle:@"Welcome"];
    
    [self.username becomeFirstResponder];
    NSString *verText = [NSString stringWithFormat:@"v %@", ClientAppVersion];
    [self.version setText:verText];
    
}


-(void)viewDidAppear:(BOOL)animated{
    /*
     if ([self.url.text isEqualToString:@""]){
     [self.url becomeFirstResponder];
     }else if ([self.company.text isEqualToString:@""]){
     [self.company becomeFirstResponder];
     }else if([self.username.text isEqualToString:@""]){
     [self.username becomeFirstResponder];
     }
     */
    
    [self.username becomeFirstResponder];
    
    [super viewDidAppear:(BOOL)animated];
}

-(void)showAlertMessage:(NSString *)message withTitle: (NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)viewWillAppear:(BOOL)animated{
    UIColor *c;
    
    c = [self colorFromHexString:@"#923E9E"];
    
    self.navigationController.navigationBar.barTintColor = c;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self redrawButtons];
    
    [super viewWillAppear:(BOOL)animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

