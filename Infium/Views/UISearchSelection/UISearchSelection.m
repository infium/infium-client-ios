#import "AppDelegate.h"
#import "CellLabelWithLink.h"
#import "UISearchSelection.h"
#import "SBJson.h"

@interface UISearchSelection ()

@end

@implementation UISearchSelection

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.searchTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellLabelWithLink *cell = (CellLabelWithLink *)[tableView dequeueReusableCellWithIdentifier: @"CellLabelWithLinkIdentifier"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellLabelWithLink" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[CellLabelWithLink class]])
                cell = (CellLabelWithLink *)oneObject;
    }
    
    int cellHeightWithLabel = cell.bounds.size.height;
    int cellHeightWithoutLabel = cellHeightWithLabel - cell.label.bounds.size.height;
    
    cell.label.text = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"Description"];
    
    float MARGIN_LEFT = 20.0;
    float MARGIN_RIGHT = 35.0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc] initWithString:cell.label.text attributes:@{NSFontAttributeName: cell.label.font}];
    CGRect rectLabel = [attributedText boundingRectWithSize:(CGSize){self.searchTable.frame.size.width - MARGIN_LEFT - MARGIN_RIGHT, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return rectLabel.size.height + cellHeightWithoutLabel;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellLabelWithLink *cell = (CellLabelWithLink *)[tableView dequeueReusableCellWithIdentifier: @"CellLabelWithLinkIdentifier"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellLabelWithLink" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[CellLabelWithLink class]])
                cell = (CellLabelWithLink *)oneObject;
    }
    
    NSString *label = [[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"Description"];
    
    cell.value.text = @"";
    cell.value.hidden = YES;
    
    cell.label.text = label;
    
    float MARGIN_LEFT = 20.0;
    float MARGIN_RIGHT = 35.0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc] initWithString:cell.label.text attributes:@{NSFontAttributeName: cell.label.font}];
    CGRect rectLabel = [attributedText boundingRectWithSize:(CGSize){self.searchTable.frame.size.width - MARGIN_LEFT - MARGIN_RIGHT, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    cell.labelFrame = CGRectMake(MARGIN_LEFT, 11.0, ceil(rectLabel.size.width), ceil(rectLabel.size.height));
    
    if ([self.selectedValue isEqualToString:[[self.searchResults objectAtIndex:indexPath.row] objectForKey:@"Value"]]){
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate updateSearchSelectionName:(NSString *)self.searchSelectionName forSearchSelection:(UISearchSelection *)self withValue:[[self.searchResults objectAtIndex:[indexPath row]] objectForKey:@"Value"] andDescription:(NSString *)[[self.searchResults objectAtIndex:[indexPath row]] objectForKey:@"Description"] atIndexPath:self.indexPathInUI  forTable:self.tableParentName atIndex:self.tableParentRowIndex];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self performSearch:searchText];
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
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)performSearch:(NSString *)query{
    
    int previousSearchSerialNumber = [self.SearchSerialNumber intValue];
    int newSearchSerialNumber = previousSearchSerialNumber + 1;
    self.SearchSerialNumber = [[NSNumber alloc] initWithInt:newSearchSerialNumber];
    
    NSString *body = [[NSString alloc] initWithFormat:@"{\"SearchQuery\":\"%@\",\"SearchSerialNumber\":%i}",query,newSearchSerialNumber];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *urlObj = [NSURL URLWithString:self.searchUrl];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlObj];
    [req setHTTPMethod:@"POST"];
    
    [req setValue:ClientPlatform forHTTPHeaderField:@"X-Client-Platform"];
    [req setValue:ClientPlatformVersion forHTTPHeaderField:@"X-Client-Platform-Version"];
    [req setValue:ClientPlatformDevice forHTTPHeaderField:@"X-Client-Platform-Device"];
    [req setValue:ClientPlatformLanguage forHTTPHeaderField:@"X-Client-Platform-Language"];
    [req setValue:ClientAppVersion forHTTPHeaderField:@"X-Client-App-Version"];
    [req setValue:ClientLoginToken forHTTPHeaderField:@"X-Client-Login-Token"];
    [req setValue:ClientLoginCompany forHTTPHeaderField:@"X-Client-Login-Company"];
    
    NSMutableData *postBody = [NSMutableData dataWithCapacity:2048];
    
    [postBody appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == self.connectionServerFirst){
        [self.receivedDataServerFirst setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.connectionServerFirst){
        [self.receivedDataServerFirst appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.connectionServerFirst){
        NSDictionary *theData = [[[SBJsonParser alloc] init] objectWithData:self.receivedDataServerFirst];
        
        if ([[theData objectForKey:@"Response"] isEqualToString:@"SearchResult"]){
            self.searchResults = [[theData objectForKey:@"Data"] objectForKey:@"Result"];
            [self.searchTable reloadData];
        }
        
        self.connectionServerFirst = nil;
        self.receivedDataServerFirst = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.connectionServerFirst)
    {
        self.connectionServerFirst = nil;
        self.receivedDataServerFirst = nil;
        
        [self showAlertMessage:@"Failed to complete the connection to the server" withTitle:nil];
    }
}

-(void)showAlertMessage:(NSString *)message withTitle: (NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
