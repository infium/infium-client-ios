#import "AppDelegate.h"
#import "CellField.h"
#import "CellImageUpload.h"
#import "CellLabelWithLink.h"
#import "CellSearchSelection.h"
#import "CellTableRowFooter.h"
#import "CellTableRowHeader.h"
#import "UI.h"
#import "UISearchSelection.h"
#import "SBJson.h"

@interface UI ()

@end

@implementation UI

-(void)updateSearchSelectionName:(NSString *)searchSelectionName forSearchSelection:(UISearchSelection *)searchSelection withValue:(NSString *)value andDescription:(NSString *)description atIndexPath:(NSIndexPath *)indexPath forTable:(NSString *)table atIndex:(NSNumber *)index{
    
    if (table == nil){
        [self.visibleData setObject:value forKey:searchSelectionName];
        [self.visibleDataDescription setObject:description forKey:searchSelectionName];
    }else{
        [[[self.visibleData objectForKey:table] objectAtIndex:[index intValue]] setObject:value forKey:searchSelectionName];
        [[[self.visibleDataDescription objectForKey:table] objectAtIndex:[index intValue]] setObject:description forKey:searchSelectionName];
        
        int lastIndexInTable = (int)[(NSArray *)[self.visibleData objectForKey:table] count] - 1;
        
        int i = 0;
        if ([index intValue] == lastIndexInTable){
            for (NSDictionary *layoutObject in self.layout){
                if ([[layoutObject objectForKey:@"CellType"] isEqualToString:@"TableRowFooter"]&&[[layoutObject objectForKey:@"TableName"] isEqualToString:table]){
                    [self addEmptyRowToTable:table indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                i++;
            }
        }
    }
    
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.table beginUpdates];
    [self.table reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.table endUpdates];
    
    [searchSelection.navigationController popViewControllerAnimated:YES];
    
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    UIImage *newImage = [self imageWithImage:image scaledToMaxWidth:[self.currentMaxImageWidth floatValue] maxHeight:[self.currentMaxImageHeight floatValue]];
    
    NSData *imageData = UIImageJPEGRepresentation(newImage, [self.currentImageQuality floatValue]);
    
    NSString *encodedString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [self.visibleData setObject:encodedString forKey:self.currentImageName];
    
    [self.table reloadData];
}

-(void)updateImage:(NSString *)text fieldName:(NSString *)fieldName sourceType:(UIImagePickerControllerSourceType)source maxImageWidth:(NSNumber *)maxImageWidth maxImageHeight:(NSNumber *)maxImageHeight ImageQuality:(NSNumber *)ImageQuality{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = source;
    
    imagePicker.delegate = self;
    
    self.currentImageName = [NSString stringWithString:fieldName];
    
    self.currentMaxImageWidth = maxImageWidth;
    self.currentMaxImageHeight = maxImageHeight;
    self.currentImageQuality = ImageQuality;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)pop:(UI *)flow{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refresh:(NSTimer*) t{
    [self resetView];
    self.startTime = [NSDate date];
    [self sendQueryFirstMethod:self.queryMethod url:self.queryUrl body:self.queryBody];
}

-(void)runLocalActions:(NSMutableArray *)actions{
    if ([actions count] > 0){
        if ([[[actions objectAtIndex:0] objectForKey:@"Action"] isEqualToString:@"Pop"]){
            [self.delegate pop:self];
            [actions removeObjectAtIndex:0];
            usleep(50000);
            [self.delegate runLocalActions:actions];
            return;
        }
    }
    
    if ([actions count] > 0){
        if ([[[actions objectAtIndex:0] objectForKey:@"Action"] isEqualToString:@"Logout"]){
            [self.navigationController popToRootViewControllerAnimated:YES];
            [actions removeObjectAtIndex:0];
            usleep(50000);
            [self.delegate runLocalActions:actions];
            return;
        }
    }
    
    if ([actions count] > 0){
        if ([[[actions objectAtIndex:0] objectForKey:@"Action"] isEqualToString:@"Reload"]){
            [self resetView];
            self.startTime = [NSDate date];
            [self sendQueryFirstMethod:self.queryMethod url:self.queryUrl body:self.queryBody];
            [actions removeObjectAtIndex:0];
            usleep(50000);
            [self runLocalActions:actions];
            return;
        }
    }
    
    if ([actions count] > 0){
        if ([[[actions objectAtIndex:0] objectForKey:@"Action"] isEqualToString:@"MessageFlash"]){
            
            [self showAlertMessage:nil withTitle:[[actions objectAtIndex:0] objectForKey:@"Message"]];
            
            [actions removeObjectAtIndex:0];
            [self runLocalActions:actions];
            return;
        }
    }
}

-(void)resetView{
    self.layout = nil;
    self.structure = nil;
    self.visibleData = nil;
    self.debug = nil;
    [self.table reloadData];
    [self.timeButton setTitle:@"" forState:UIControlStateNormal];
}

-(void)addEmptyRowToTable:(NSString *) tableName indexPath:(NSIndexPath *)indexPath{
    
    for (NSDictionary *hierarchy in self.structure){
        if (([[hierarchy objectForKey:@"Type"] isEqualToString:@"Table"])&&([[hierarchy objectForKey:@"Name"] isEqualToString:tableName])){
            NSMutableDictionary *visibleDataRow = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *visibleDataDescriptionRow = [[NSMutableDictionary alloc] init];
            
            NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
            
            [arrayOfIndexPaths addObject:indexPath];
            
            int i = 0;
            
            for (NSDictionary *column in [hierarchy objectForKey:@"Column"]){
                
                NSString *column_type = [[NSString alloc] initWithString:[column objectForKey:@"Type"]];
                NSString *column_name = [[NSString alloc] initWithString:[column objectForKey:@"Name"]];
                
                if ([column_type isEqualToString:@"Field"]){
                    [visibleDataRow setObject:@"" forKey:column_name];
                }
                
                if ([column_type isEqualToString:@"SearchSelection"]){
                    [visibleDataRow setObject:@"" forKey:column_name];
                    [visibleDataDescriptionRow setObject:@"" forKey:column_name];
                }
                
                i++;
                NSIndexPath *indexPathforNewRow = [NSIndexPath indexPathForRow:[indexPath row] + i inSection:0];
                [arrayOfIndexPaths addObject:indexPathforNewRow];
            }
            
            [[self.visibleData objectForKey:tableName] addObject:visibleDataRow];
            [[self.visibleDataDescription objectForKey:tableName] addObject:visibleDataDescriptionRow];
            [self reBuildLayout];
            
            [self.table insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        }
    }
}

-(void)updateText:(NSString *)text fieldName:(NSString *)fieldName fieldTableParent:(NSString *)fieldTableParent fieldTableRowIndex:(NSNumber *)fieldTableRowIndex{
    if (fieldTableParent == nil){
        [self.visibleData setObject:text forKey:fieldName];
    }else{
        [[[self.visibleData objectForKey:fieldTableParent] objectAtIndex:[fieldTableRowIndex intValue]] setObject:text forKey:fieldName];
        
        int lastIndexInTable = (int)[(NSArray *)[self.visibleData objectForKey:fieldTableParent] count] - 1;
        
        int i = 0;
        if ([fieldTableRowIndex intValue] == lastIndexInTable){
            for (NSDictionary *layoutObject in self.layout){
                if ([[layoutObject objectForKey:@"CellType"] isEqualToString:@"TableRowFooter"]&&[[layoutObject objectForKey:@"TableName"] isEqualToString:fieldTableParent]){
                    [self addEmptyRowToTable:fieldTableParent indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                i++;
            }
        }
        
    }
    
    
}

-(void)printButtonPressed{
    UIPrintInfo *pi = [UIPrintInfo printInfo];
    pi.outputType = UIPrintInfoOutputGeneral;
    pi.jobName = self.title;
    pi.orientation = UIPrintInfoOrientationPortrait;
    pi.duplex = UIPrintInfoDuplexLongEdge;
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.printInfo = pi;
    pic.showsPageRange = NO;
    pic.printFormatter = self.web.viewPrintFormatter;
    pic.showsNumberOfCopies = NO;
    [pic presentAnimated:YES completionHandler:^(UIPrintInteractionController *pic2, BOOL completed, NSError *error) {
        // indicate done or error
    }];
}

-(void)buttonPressed{
    if ([self.processWindow isEqualToString:@"Same"]){
        NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
        
        if (self.visibleData != nil) [body setObject:self.visibleData forKey:@"VisibleData"];
        if (self.hiddenData != nil) [body setObject:self.hiddenData forKey:@"HiddenData"];
        
        [self sendQuerySecond:[[[SBJsonWriter alloc] init] stringWithObject:body]];
    }
    
    if ([self.processWindow isEqualToString:@"New"]){
        UI *newUI = [[UI alloc] initWithNibName:@"UI" bundle:nil];
        newUI.startTime = [NSDate date];
        newUI.delegate = self;
        newUI.titleBarColor = self.processTitleBarColorNewWindow;
        
        NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
        
        if (self.visibleData != nil) [body setObject:self.visibleData forKey:@"VisibleData"];
        if (self.hiddenData != nil) [body setObject:self.hiddenData forKey:@"HiddenData"];
        
        [newUI sendQueryFirstMethod:self.processMethod url:self.processUrl body:[[[SBJsonWriter alloc] init] stringWithObject:body]];
        [self.navigationController pushViewController:newUI animated:YES];
        [self.view endEditing:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelValueLink"]){
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Url"] != nil){
            UI *NewWindow = [[UI alloc] initWithNibName:@"UI" bundle:nil];
            NewWindow.startTime = [NSDate date];
            NewWindow.delegate = self;
            
            if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TitleBarColorNewWindow"] != nil){
                NewWindow.titleBarColor = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TitleBarColorNewWindow"];
            }
            
            if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Refresh"] != nil){
                NSNumber *refresh = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Refresh"];
                NewWindow.refreshSeconds = refresh;
            }
            
            [NewWindow sendQueryFirstMethod:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Method"] url:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Url"] body:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Body"]];
            [self.navigationController pushViewController:NewWindow animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelWithLink"]){
        if (![[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"LabelWithLinkUrl"] isEqualToString:@""]){
            UI *NewWindow = [[UI alloc] initWithNibName:@"UI" bundle:nil];
            NewWindow.startTime = [NSDate date];
            NewWindow.delegate = self;
            
            if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Refresh"] != nil){
                NSNumber *refresh = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Refresh"];
                NewWindow.refreshSeconds = refresh;
            }
            
            [NewWindow sendQueryFirstMethod:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"LabelWithLinkMethod"] url:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"LabelWithLinkUrl"] body:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"LabelWithLinkBody"]];
            [self.navigationController pushViewController:NewWindow animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelTrueFalse"]){
        CellLabelWithLink *cell = (CellLabelWithLink *)[tableView cellForRowAtIndexPath:indexPath];
        
        NSString *name = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Name"];
        
        if ([[self.visibleData objectForKey:name] boolValue] == YES){
            [self.visibleData setObject:[NSNumber numberWithBool:NO] forKey:name];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            [self.visibleData setObject:[NSNumber numberWithBool:YES] forKey:name];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"SearchSelection"]){
        UISearchSelection *NewWindow = [[UISearchSelection alloc] initWithNibName:@"UISearchSelection" bundle:nil];
        
        NSString *tableParentName = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableParentName"];
        NSNumber *tableParentRowIndex = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableParentRowIndex"];
        NSString *objectName = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Name"];
        
        if (tableParentName == nil){
            NewWindow.selectedValue = [self.visibleData objectForKey:objectName];
        }else{
            NewWindow.selectedValue = [[[self.visibleData objectForKey:tableParentName] objectAtIndex:[tableParentRowIndex intValue]] objectForKey:objectName];
        }
        
        NewWindow.searchUrl = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"SearchUrl"];
        [NewWindow setTitle:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"]];
        NewWindow.SearchSerialNumber = [[NSNumber alloc] initWithInt:0];
        NewWindow.delegate = self;
        NewWindow.searchSelectionName = objectName;
        NewWindow.indexPathInUI = indexPath;
        
        NewWindow.tableParentName = tableParentName;
        NewWindow.tableParentRowIndex = tableParentRowIndex;
        
        [NewWindow performSearch:@""];
        [self.navigationController pushViewController:NewWindow animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.view endEditing:YES];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.layout count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"TableRowHeader"])&&([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"RowCanBeDeleted"] isEqualToString:@"True"])){
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *table = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableRowHeaderName"];
        
        NSNumber *tableRow = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableRowHeaderRowNumber"];
        
        int tableRowIndex = [tableRow intValue] -1;
        
        NSMutableDictionary *newVisibleData = [[NSMutableDictionary alloc] initWithDictionary:(NSMutableDictionary *)self.visibleData];
        NSMutableDictionary *newVisibleDataDescription = [[NSMutableDictionary alloc] initWithDictionary:(NSMutableDictionary *)self.visibleDataDescription];
        
        NSMutableArray *newTableVisibleData = [[NSMutableArray alloc] initWithArray:(NSMutableArray *)[self.visibleData objectForKey:table]];
        NSMutableArray *newTableVisibleDataDescription = [[NSMutableArray alloc] initWithArray:(NSMutableArray *)[self.visibleDataDescription objectForKey:table]];
        
        int numberOfFields = (int)[[[self.visibleData objectForKey:table] objectAtIndex:tableRowIndex] count];
        
        NSMutableArray *cellIndexesToBeDeleted = [[NSMutableArray alloc] init];
        [cellIndexesToBeDeleted addObject:[NSIndexPath indexPathForRow:[indexPath row] inSection:0]];
        
        for (int i = 1; i < numberOfFields + 1; i++) {
            [cellIndexesToBeDeleted addObject:[NSIndexPath indexPathForRow:[indexPath row]+i inSection:0]];
        }
        
        [newTableVisibleData removeObjectAtIndex:tableRowIndex];
        [newTableVisibleDataDescription removeObjectAtIndex:tableRowIndex];
        
        if ([newTableVisibleData count] >0){
            
            [newVisibleData setObject:newTableVisibleData forKey:table];
            [newVisibleDataDescription setObject:newTableVisibleDataDescription forKey:table];
            
            [self.table beginUpdates];
            self.visibleData = newVisibleData;
            self.visibleDataDescription = newVisibleDataDescription;
            [self reBuildLayout];
            
            [self.table deleteRowsAtIndexPaths:cellIndexesToBeDeleted withRowAnimation:UITableViewRowAnimationRight];
            [self.table endUpdates];
            
            [self.table reloadData];
            
        }
        
        
    }
    [self.table setEditing:NO animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelHeader"]){
        if (self.heightTableRowHeader == nil){
            CellTableRowHeader *cell = (CellTableRowHeader *)[tableView dequeueReusableCellWithIdentifier: @"CellTableRowHeaderIdentifier"];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableRowHeader" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellTableRowHeader class]])
                    cell = (CellTableRowHeader *)oneObject;
            self.heightTableRowHeader = [NSNumber numberWithInt:cell.bounds.size.height];
        }
        return [self.heightTableRowHeader intValue];
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelValueLink"]){
        
        CellLabelWithLink *cell = (CellLabelWithLink *)[tableView dequeueReusableCellWithIdentifier: @"CellLabelWithLinkIdentifier"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellLabelWithLink" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellLabelWithLink class]])
                    cell = (CellLabelWithLink *)oneObject;
        }
        
        int cellHeightWithLabel = cell.bounds.size.height;
        int cellHeightWithoutLabel = cellHeightWithLabel - cell.label.frame.size.height;
        
        NSString *label = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"];
        NSString *value = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Value"];
        
        if (value == nil){
            cell.value.text = @"";
        }else{
            cell.value.text = value;
        }
        
        cell.label.text = label;
        
        float MARGIN_LEFT = 20.0;
        float MARGIN_ICON = 0.0;
        float MARGIN_BETWEEN = 10.0;
        float MARGIN_RIGHT = 0.0;
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Url"] == nil){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            MARGIN_RIGHT = 35.0; //Used to be 20.0 to save space, but it does not align good when other rows are links..
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            MARGIN_RIGHT = 35.0;
        }
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Indent"] != nil){
            NSNumber *indent = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Indent"];
            MARGIN_LEFT = MARGIN_LEFT + [indent intValue]*5;
        }
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"IconUnicode"] != nil){
            MARGIN_ICON = 32.0;
        }else{
            MARGIN_ICON = 0.0;
        }
        
        NSAttributedString *attributedTextValue =
        [[NSAttributedString alloc] initWithString:cell.value.text attributes:@{NSFontAttributeName: cell.value.font}];
        CGRect rectValue = [attributedTextValue boundingRectWithSize:(CGSize){(self.table.frame.size.width * 0.5 - MARGIN_RIGHT), CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        NSAttributedString *attributedTextLabel =
        [[NSAttributedString alloc] initWithString:cell.label.text attributes:@{NSFontAttributeName: cell.label.font}];
        CGRect rectLabel = [attributedTextLabel boundingRectWithSize:(CGSize){self.table.frame.size.width - MARGIN_LEFT - MARGIN_ICON - ceil(rectValue.size.width) - MARGIN_BETWEEN - MARGIN_RIGHT, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (rectLabel.size.height > rectValue.size.height){
            return rectLabel.size.height + cellHeightWithoutLabel;
        }else{
            return rectValue.size.height + cellHeightWithoutLabel;
        }
        
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelTrueFalse"]){
        
        CellLabelWithLink *cell = (CellLabelWithLink *)[tableView dequeueReusableCellWithIdentifier: @"CellLabelWithLinkIdentifier"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellLabelWithLink" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellLabelWithLink class]])
                    cell = (CellLabelWithLink *)oneObject;
        }
        
        int cellHeightWithLabel = cell.bounds.size.height;
        int cellHeightWithoutLabel = cellHeightWithLabel - cell.label.bounds.size.height;
        
        cell.label.text = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"];
        
        float MARGIN_LEFT = 20.0;
        float MARGIN_RIGHT = 35.0;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:cell.label.text attributes:@{NSFontAttributeName: cell.label.font}];
        CGRect rectLabel = [attributedText boundingRectWithSize:(CGSize){self.table.frame.size.width - MARGIN_LEFT - MARGIN_RIGHT, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        return rectLabel.size.height + cellHeightWithoutLabel;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"Field"]){
        if (self.heightField == nil){
            CellField *cell = (CellField *)[tableView dequeueReusableCellWithIdentifier: @"CellFieldIdentifier"];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellField" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellField class]])
                    cell = (CellField *)oneObject;
            self.heightField = [NSNumber numberWithInt:cell.bounds.size.height];
        }
        return [self.heightField intValue];
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"SearchSelection"]){
        if (self.heightSearchSelection == nil){
            CellSearchSelection *cell = (CellSearchSelection *)[tableView dequeueReusableCellWithIdentifier: @"CellSearchSelectionIdentifier"];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellSearchSelection" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellSearchSelection class]])
                    cell = (CellSearchSelection *)oneObject;
            self.heightSearchSelection = [NSNumber numberWithInt:cell.bounds.size.height];
        }
        return [self.heightSearchSelection intValue];
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"ImageUpload"]){
        if (self.heightImageUpload == nil){
            CellImageUpload *cell = (CellImageUpload *)[tableView dequeueReusableCellWithIdentifier: @"CellImageUploadIdentifier"];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellImageUpload" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellImageUpload class]])
                    cell = (CellImageUpload *)oneObject;
            self.heightImageUpload = [NSNumber numberWithInt:cell.bounds.size.height];
        }
        return [self.heightImageUpload intValue];
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"TableRowHeader"]){
        if (self.heightTableRowHeader == nil){
            CellTableRowHeader *cell = (CellTableRowHeader *)[tableView dequeueReusableCellWithIdentifier: @"CellTableRowHeaderIdentifier"];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableRowHeader" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellTableRowHeader class]])
                    cell = (CellTableRowHeader *)oneObject;
            self.heightTableRowHeader = [NSNumber numberWithInt:cell.bounds.size.height];
        }
        return [self.heightTableRowHeader intValue];
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"TableRowFooter"]){
        if (self.heightTableRowFooter == nil){
            CellTableRowFooter *cell = (CellTableRowFooter *)[tableView dequeueReusableCellWithIdentifier: @"CellTableRowFooterIdentifier"];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableRowFooter" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellTableRowFooter class]])
                    cell = (CellTableRowFooter *)oneObject;
            self.heightTableRowFooter = [NSNumber numberWithInt:cell.bounds.size.height];
        }
        return [self.heightTableRowFooter intValue];
    }
    
    return 0;
}


- (void)updateContentsOfCell:(id)oneCell forIndexPath:(NSIndexPath *)indexPath{
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"SearchSelection"]){
        NSString *name = (NSString *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Name"];
        NSString *label = [NSString stringWithString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"]];
        
        CellSearchSelection *cell = (CellSearchSelection *)oneCell;
        
        cell.searchLabel.text = label;
        
        NSString *tableParent = (NSString *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableParentName"];
        NSString *tableRowIndex = (NSString *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableParentRowIndex"];
        
        if (tableParent == nil){
            if ([[self.visibleDataDescription objectForKey:name] isEqualToString:@""]){
                cell.searchDescription.text = @"<not set>";
            }else{
                cell.searchDescription.text = [self.visibleDataDescription objectForKey:name];
            }
        }else{
            NSString *description = [[[self.visibleDataDescription objectForKey:tableParent] objectAtIndex:[tableRowIndex intValue]] objectForKey:name];
            
            if ([description isEqualToString:@""]){
                cell.searchDescription.text = @"<not set>";
            }else{
                cell.searchDescription.text = description;
            }
        }
        
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelValueLink"]){
        CellLabelWithLink *cell = (CellLabelWithLink *)oneCell;
        
        NSString *label = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"];
        NSString *value = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Value"];
        
        if (value == nil){
            cell.value.text = @"";
            cell.value.hidden = YES;
        }else{
            cell.value.text = value;
            cell.value.hidden = NO;
        }
        
        cell.label.text = label;
        
        float MARGIN_LEFT = 20.0;
        float MARGIN_ICON = 0.0;
        
        float MARGIN_BETWEEN = 10.0;
        float MARGIN_RIGHT = 0.0;
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Url"] == nil){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            MARGIN_RIGHT = 35.0; //Used to be 20.0 to save space, but it does not align good when some items are linked..
            
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            MARGIN_RIGHT = 35.0;
        }
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Indent"] != nil){
            NSNumber *indent = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Indent"];
            MARGIN_LEFT = MARGIN_LEFT + [indent intValue]*5;
        }
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"IconUnicode"] != nil){
            cell.icon.text = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"IconUnicode"];
            [cell.icon setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
            
            cell.icon.textColor = [self colorFromHexString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"IconColor"]];
            cell.icon.hidden = NO;
            MARGIN_ICON = 32.0;
        }else{
            MARGIN_ICON = 0.0;
            cell.icon.hidden = YES;
        }
        
        
        NSAttributedString *attributedTextValue =
        [[NSAttributedString alloc] initWithString:cell.value.text attributes:@{NSFontAttributeName: cell.value.font}];
        CGRect rectValue = [attributedTextValue boundingRectWithSize:(CGSize){(self.table.frame.size.width * 0.5 - MARGIN_RIGHT), CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        cell.valueFrame = CGRectMake(self.table.frame.size.width - ceil(rectValue.size.width) - MARGIN_RIGHT, 11.0, ceil(rectValue.size.width), ceil(rectValue.size.height));
        
        NSAttributedString *attributedTextLabel =
        [[NSAttributedString alloc] initWithString:cell.label.text attributes:@{NSFontAttributeName: cell.label.font}];
        CGRect rectLabel = [attributedTextLabel boundingRectWithSize:(CGSize){self.table.frame.size.width - MARGIN_LEFT -MARGIN_ICON - ceil(rectValue.size.width) - MARGIN_BETWEEN - MARGIN_RIGHT, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        cell.labelFrame = CGRectMake(MARGIN_LEFT + MARGIN_ICON, 11.0, ceil(rectLabel.size.width), ceil(rectLabel.size.height));
        
        if (rectLabel.size.height > rectValue.size.height){
            cell.iconFrame = CGRectMake(MARGIN_LEFT, 11.0, 27.0, ceil(rectLabel.size.height));
        }else{
            cell.iconFrame = CGRectMake(MARGIN_LEFT, 11.0, 27.0, ceil(rectValue.size.height));
        }
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelTrueFalse"]){
        CellLabelWithLink *cell = (CellLabelWithLink *)oneCell;
        
        NSString *label = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"];
        
        cell.value.text = @"";
        cell.value.hidden = YES;
        
        cell.label.text = label;
        
        float MARGIN_LEFT = 20.0;
        float MARGIN_RIGHT = 35.0;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:cell.label.text attributes:@{NSFontAttributeName: cell.label.font}];
        CGRect rectLabel = [attributedText boundingRectWithSize:(CGSize){self.table.frame.size.width - MARGIN_LEFT - MARGIN_RIGHT, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        cell.labelFrame = CGRectMake(MARGIN_LEFT, 11.0, ceil(rectLabel.size.width), ceil(rectLabel.size.height));
        
        NSString *fieldName = [NSString stringWithString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Name"]];
        
        if ([[self.visibleData objectForKey:fieldName] boolValue] == YES){
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"SearchSelection"]){
        CellSearchSelection *cell = (CellSearchSelection *)[tableView dequeueReusableCellWithIdentifier: @"CellSearchSelectionIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellSearchSelection" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellSearchSelection class]])
                    cell = (CellSearchSelection *)oneObject;
        }
        
        [self updateContentsOfCell:cell forIndexPath:indexPath];
        
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelHeader"]){
        CellTableRowHeader *cell = (CellTableRowHeader *)[tableView dequeueReusableCellWithIdentifier: @"CellTableViewHeaderIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableRowHeader" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellTableRowHeader class]])
                    cell = (CellTableRowHeader *)oneObject;
        }
        
        cell.label.text = [NSString stringWithString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"]];
        
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelValueLink"]){
        CellLabelWithLink *cell = (CellLabelWithLink *)[tableView dequeueReusableCellWithIdentifier: @"CellLabelWithLinkIdentifier"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellLabelWithLink" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellLabelWithLink class]])
                    cell = (CellLabelWithLink *)oneObject;
        }
        
        [self updateContentsOfCell:cell forIndexPath:indexPath];
        
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"LabelTrueFalse"]){
        
        CellLabelWithLink *cell = (CellLabelWithLink *)[tableView dequeueReusableCellWithIdentifier: @"CellLabelWithLinkIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellLabelWithLink" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellLabelWithLink class]])
                    cell = (CellLabelWithLink *)oneObject;
        }
        
        [self updateContentsOfCell:cell forIndexPath:indexPath];
        
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"Field"]){
        CellField *cell = (CellField *)[tableView dequeueReusableCellWithIdentifier: @"CellFieldIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellField" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellField class]])
                    cell = (CellField *)oneObject;
        }
        
        NSString *fieldName = [NSString stringWithString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"FieldName"]];
        NSString *fieldTableParent = (NSString *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"FieldTableParent"];
        NSNumber *fieldTableRowIndex = (NSNumber *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"FieldTableRowIndex"];
        NSString *fieldLabel = [NSString stringWithString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"FieldLabel"]];
        
        cell.fieldName = fieldName;
        cell.fieldTableParent = fieldTableParent;
        cell.fieldTableRowIndex = fieldTableRowIndex;
        
        cell.labelFieldName.text = fieldLabel;
        cell.delegate = self;
        
        if (fieldTableParent == nil){
            cell.fieldValue.text = [self.visibleData objectForKey:fieldName];
        }else{
            cell.fieldValue.text = [[[self.visibleData objectForKey:fieldTableParent] objectAtIndex:[fieldTableRowIndex intValue]] objectForKey:fieldName];
        }
        
        if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"KeyboardType"] isEqualToString:@"Decimal"]){
            cell.fieldValue.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
        
        if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"KeyboardType"] isEqualToString:@"Normal"]){
            cell.fieldValue.keyboardType = UIKeyboardTypeDefault;
        }
        
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"TableRowHeader"]){
        CellTableRowHeader *cell = (CellTableRowHeader *)[tableView dequeueReusableCellWithIdentifier: @"CellTableViewHeaderIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableRowHeader" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellTableRowHeader class]])
                    cell = (CellTableRowHeader *)oneObject;
        }
        
        if ([[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"] != nil){
            cell.label.text = [[NSString alloc] initWithFormat:@"%@ %i",[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"Label"],[(NSNumber *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableRowHeaderRowNumber"] intValue]];
        }else{
            cell.label.text = [[NSString alloc] initWithFormat:@"%@ %i",[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableRowHeaderName"],[(NSNumber *)[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableRowHeaderRowNumber"] intValue]];
            
        }
        
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"TableRowFooter"]){
        CellTableRowFooter *cell = (CellTableRowFooter *)[tableView dequeueReusableCellWithIdentifier: @"CellTableViewFooterIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableRowFooter" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellTableRowFooter class]])
                    cell = (CellTableRowFooter *)oneObject;
        }
        
        cell.tableName = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"TableName"];
        cell.delegate = self;
        return cell;
    }
    
    if ([[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"CellType"] isEqualToString:@"ImageUpload"]){
        CellImageUpload *cell = (CellImageUpload *)[tableView dequeueReusableCellWithIdentifier: @"CellImageUploadIdentifier"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellImageUpload" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[CellImageUpload class]])
                    cell = (CellImageUpload *)oneObject;
        }
        
        NSString *imageName = [NSString stringWithString:[[self.layout objectAtIndex:[indexPath row]] objectForKey:@"ImageName"]];
        
        cell.imageUploadName = imageName;
        cell.labelImageUploadName.text = imageName;
        cell.maxImageWidth = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"MaxImageWidth"];
        cell.maxImageHeight = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"MaxImageHeight"];
        cell.imageQuality = [[self.layout objectAtIndex:[indexPath row]] objectForKey:@"ImageQuality"];
        
        cell.delegate = self;
        
        if (![[self.visibleData objectForKey:imageName] isEqualToString:@""]){
            NSData *da = [[NSData alloc] initWithBase64EncodedString:[self.visibleData objectForKey:imageName] options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image = [UIImage imageWithData:da];
            cell.theImageView.image = image;
        }else{
            cell.theImageView.image = nil;
        }
        
        cell.theImageView.layer.borderWidth = 0.5;
        
        return cell;
    }
    return nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.table reloadData];
}

-(IBAction)timeTapped:(id)sender{
    [self showAlertMessage:self.debug withTitle:@"Server time analysis"];
}


-(void)sendQueryFirstMethod:(NSString *)method url:(NSString *)url body:(NSString *)body{
    self.queryMethod = method;
    self.queryUrl = url;
    self.queryBody = body;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *urlObj = [NSURL URLWithString:url];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:urlObj];
    [req setHTTPMethod:method];
    
    [req setValue:ClientPlatform forHTTPHeaderField:@"X-Client-Platform"];
    [req setValue:ClientPlatformVersion forHTTPHeaderField:@"X-Client-Platform-Version"];
    [req setValue:ClientPlatformDevice forHTTPHeaderField:@"X-Client-Platform-Device"];
    [req setValue:ClientPlatformLanguage forHTTPHeaderField:@"X-Client-Platform-Language"];
    [req setValue:ClientAppVersion forHTTPHeaderField:@"X-Client-App-Version"];
    [req setValue:ClientLoginToken forHTTPHeaderField:@"X-Client-Login-Token"];
    [req setValue:ClientLoginCompany forHTTPHeaderField:@"X-Client-Login-Company"];
    
    if (![body isEqualToString:@""]){
        NSMutableData *postBody = [NSMutableData dataWithCapacity:2048];
        [postBody appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [req setHTTPBody:postBody];
    }
    
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

-(void)sendQuerySecond: (NSString *)query{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:self.processUrl];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:self.processMethod];
    
    [req setValue:ClientPlatform forHTTPHeaderField:@"X-Client-Platform"];
    [req setValue:ClientPlatformVersion forHTTPHeaderField:@"X-Client-Platform-Version"];
    [req setValue:ClientPlatformDevice forHTTPHeaderField:@"X-Client-Platform-Device"];
    [req setValue:ClientPlatformLanguage forHTTPHeaderField:@"X-Client-Platform-Language"];
    [req setValue:ClientAppVersion forHTTPHeaderField:@"X-Client-App-Version"];
    [req setValue:ClientLoginToken forHTTPHeaderField:@"X-Client-Login-Token"];
    [req setValue:ClientLoginCompany forHTTPHeaderField:@"X-Client-Login-Company"];
    
    [req setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSMutableData *postBody = [NSMutableData dataWithCapacity:2048];
    [postBody appendData:[query dataUsingEncoding:NSUTF8StringEncoding]];
    [req setHTTPBody:postBody];
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == self.connectionServerFirst){
        [self.receivedDataServerFirst setLength:0];
        self.mimeTypeServerFirst = [response MIMEType];
        
        self.showPrintIcon = NO;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            NSString *printIcon = [[httpResponse allHeaderFields] objectForKey:@"Show-Print-Icon"];
            if ([printIcon isEqualToString:@"true"]){
                self.showPrintIcon = YES;
            }
        }
    }
    
    if (connection == self.connectionServerSecond){
        [self.receivedDataServerSecond setLength:0];
        self.mimeTypeServerSecond = [response MIMEType];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.connectionServerFirst){
        [self.receivedDataServerFirst appendData:data];
    }
    if (connection == self.connectionServerSecond){
        [self.receivedDataServerSecond appendData:data];
    }
}

- (void)buildInitalData:(NSDictionary *)values andDescription:(NSDictionary *)description{
    self.visibleData = [[NSMutableDictionary alloc] init];
    self.visibleDataDescription = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *structureObject in self.structure){
        NSString *type = [[NSString alloc] initWithString:[structureObject objectForKey:@"Type"]];
        NSString *name = nil;
        
        if ([structureObject objectForKey:@"Name"] != nil){
            name = [[NSString alloc] initWithString:[structureObject objectForKey:@"Name"]];
        }
        
        if ([type isEqualToString:@"SearchSelection"]){
            if ([values objectForKey:name] != nil){
                [self.visibleData setObject:[values objectForKey:name] forKey:name];
            }else{
                [self.visibleData setObject:@"" forKey:name];
            }
            
            if ([description objectForKey:name] != nil){
                [self.visibleDataDescription setObject:[description objectForKey:name] forKey:name];
            }else{
                [self.visibleDataDescription setObject:@"" forKey:name];
            }
        }
        
        
        if ([type isEqualToString:@"Field"]){
            if ([values objectForKey:name] != nil){
                [self.visibleData setObject:[values objectForKey:name] forKey:name];
            }else{
                [self.visibleData setObject:@"" forKey:name];
            }
        }
        
        if ([type isEqualToString:@"LabelTrueFalse"]){
            if ([values objectForKey:name] != nil){
                [self.visibleData setObject:[values objectForKey:name] forKey:name];
            }else{
                [self.visibleData setObject:[NSNumber numberWithBool:NO] forKey:name];
            }
        }
        
        if ([type isEqualToString:@"ImageUpload"]){
            [self.visibleData setObject:@"" forKey:name];
        }
        
        if ([type isEqualToString:@"Table"]){
            int numberOfElementsInValue = (int)[[values objectForKey:name] count];
            
            NSMutableArray *visibleDataTable = [[NSMutableArray alloc] init];
            NSMutableArray *visibleDataDescriptionTable = [[NSMutableArray alloc] init];
            
            if (numberOfElementsInValue > 0 ){
                for (int z = 0; z < numberOfElementsInValue; z++){
                    NSMutableDictionary *visibleDataRow = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *visibleDataDescriptionRow = [[NSMutableDictionary alloc] init];
                    
                    for (NSDictionary *column in [structureObject objectForKey:@"Column"]){
                        
                        NSString *column_type = [[NSString alloc] initWithString:[column objectForKey:@"Type"]];
                        NSString *column_name = [[NSString alloc] initWithString:[column objectForKey:@"Name"]];
                        NSDictionary *column_values = [NSDictionary dictionaryWithDictionary:[[values objectForKey:name] objectAtIndex:z]];
                        
                        NSDictionary *column_description = [NSDictionary dictionaryWithDictionary:[[description objectForKey:name] objectAtIndex:z]];
                        
                        if ([column_type isEqualToString:@"Field"]){
                            if ([column_values objectForKey:column_name] != nil){
                                [visibleDataRow setObject:[column_values objectForKey:column_name] forKey:column_name];
                            }else{
                                [visibleDataRow setObject:@"" forKey:column_name];
                            }
                        }
                        
                        if ([column_type isEqualToString:@"SearchSelection"]){
                            if ([column_values objectForKey:column_name] != nil){
                                [visibleDataRow setObject:[column_values objectForKey:column_name] forKey:column_name];
                                [visibleDataDescriptionRow setObject:[column_description objectForKey:column_name] forKey:column_name];
                                
                            }else{
                                [visibleDataRow setObject:@"" forKey:column_name];
                                [visibleDataDescriptionRow setObject:@"" forKey:column_name];
                            }
                        }
                    }
                    [visibleDataTable addObject:visibleDataRow];
                    [visibleDataDescriptionTable addObject:visibleDataDescriptionRow];
                }
            }else{
                NSMutableDictionary *visibleDataRow = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *visibleDataDescriptionRow = [[NSMutableDictionary alloc] init];
                
                for (NSDictionary *column in [structureObject objectForKey:@"Column"]){
                    NSString *column_type = [[NSString alloc] initWithString:[column objectForKey:@"Type"]];
                    NSString *column_name = [[NSString alloc] initWithString:[column objectForKey:@"Name"]];
                    
                    if ([column_type isEqualToString:@"Field"]){
                        [visibleDataRow setObject:@"" forKey:column_name];
                    }
                    
                    if ([column_type isEqualToString:@"SearchSelection"]){
                        [visibleDataRow setObject:@"" forKey:column_name];
                        [visibleDataDescriptionRow setObject:@"" forKey:column_name];
                    }
                }
                
                [visibleDataTable addObject:visibleDataRow];
                [visibleDataDescriptionTable addObject:visibleDataDescriptionRow];
            }
            
            [self.visibleData setObject:visibleDataTable forKey:name];
            [self.visibleDataDescription setObject:visibleDataDescriptionTable forKey:name];
        }
    }
}

- (void)reBuildLayout{
    self.layout = [[NSMutableArray alloc] init];
    
    for (NSDictionary *structureObject in self.structure){
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"LabelHeader"]){
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"LabelHeader" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"Label"];
            [self.layout addObject:newObj];
        }
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"LabelValueLink"]){
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            
            [newObj setObject:@"LabelValueLink" forKey:@"CellType"];
            
            if ([structureObject objectForKey:@"Label"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"Label"];
            }
            
            if ([structureObject objectForKey:@"Value"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Value"] forKey:@"Value"];
            }
            
            if ([structureObject objectForKey:@"Method"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Method"] forKey:@"Method"];
            }
            
            if ([structureObject objectForKey:@"Url"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Url"] forKey:@"Url"];
            }
            
            if ([structureObject objectForKey:@"Body"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Body"] forKey:@"Body"];
            }
            
            if ([structureObject objectForKey:@"Refresh"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Refresh"] forKey:@"Refresh"];
            }
            
            if ([structureObject objectForKey:@"TitleBarColorNewWindow"] != nil){
                [newObj setObject:[structureObject objectForKey:@"TitleBarColorNewWindow"] forKey:@"TitleBarColorNewWindow"];
            }
            
            if ([structureObject objectForKey:@"Indent"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Indent"] forKey:@"Indent"];
            }
            
            if ([structureObject objectForKey:@"IconUnicode"] != nil){
                [newObj setObject:[structureObject objectForKey:@"IconUnicode"] forKey:@"IconUnicode"];
            }
            
            if ([structureObject objectForKey:@"IconColor"] != nil){
                [newObj setObject:[structureObject objectForKey:@"IconColor"] forKey:@"IconColor"];
            }
            
            [self.layout addObject:newObj];
        }
        
        // To be depreciated
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"LabelWithLink"]){
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"LabelWithLink" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"LabelWithLinkLabel"];
            [newObj setObject:[structureObject objectForKey:@"Method"] forKey:@"LabelWithLinkMethod"];
            [newObj setObject:[structureObject objectForKey:@"Url"] forKey:@"LabelWithLinkUrl"];
            
            if ([structureObject objectForKey:@"Body"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Body"] forKey:@"LabelWithLinkBody"];
            }
            
            if ([structureObject objectForKey:@"Indent"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Indent"] forKey:@"LabelWithLinkIndent"];
            }
            
            if ([structureObject objectForKey:@"Refresh"] != nil){
                [newObj setObject:[structureObject objectForKey:@"Refresh"] forKey:@"Refresh"];
            }
            
            
            [self.layout addObject:newObj];
        }
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"Field"]){
            
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"Field" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"FieldName"];
            [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"FieldLabel"];
            [newObj setObject:[structureObject objectForKey:@"KeyboardType"] forKey:@"KeyboardType"];
            
            [self.layout addObject:newObj];
        }
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"LabelTrueFalse"]){
            
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"LabelTrueFalse" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"Name"];
            [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"Label"];
            
            [self.layout addObject:newObj];
        }
        
        // To be depreciated
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"LabelValue"]){
            
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"LabelValue" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"Label"];
            [newObj setObject:[structureObject objectForKey:@"Value"] forKey:@"Value"];
            
            [self.layout addObject:newObj];
        }
        
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"SearchSelection"]){
            
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"SearchSelection" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"Name"];
            [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"Label"];
            [newObj setObject:[structureObject objectForKey:@"SearchUrl"] forKey:@"SearchUrl"];
            
            [self.layout addObject:newObj];
        }
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"ImageUpload"]){
            
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"ImageUpload" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"ImageName"];
            [newObj setObject:[structureObject objectForKey:@"MaxImageWidth"] forKey:@"MaxImageWidth"];
            [newObj setObject:[structureObject objectForKey:@"MaxImageHeight"] forKey:@"MaxImageHeight"];
            [newObj setObject:[structureObject objectForKey:@"ImageQuality"] forKey:@"ImageQuality"];
            [self.layout addObject:newObj];
        }
        
        if ([[structureObject objectForKey:@"Type"] isEqualToString:@"Table"]){
            int numberOfElementsInValue = (int)[[self.visibleData objectForKey:[structureObject objectForKey:@"Name"]] count];
            
            for (int z = 0; z < numberOfElementsInValue; z++){
                
                NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
                [newObj setObject:@"TableRowHeader" forKey:@"CellType"];
                if (numberOfElementsInValue == 1){
                    [newObj setObject:@"False" forKey:@"RowCanBeDeleted"];
                }else{
                    [newObj setObject:@"True" forKey:@"RowCanBeDeleted"];
                }
                [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"TableRowHeaderName"];
                if ([structureObject objectForKey:@"Label"] != nil){
                    [newObj setObject:[structureObject objectForKey:@"Label"] forKey:@"Label"];
                }
                [newObj setObject:[NSNumber numberWithInt:(z+1)] forKey:@"TableRowHeaderRowNumber"];
                [self.layout addObject:newObj];
                
                
                for (NSDictionary *column in [structureObject objectForKey:@"Column"]){
                    
                    NSString *column_type = [[NSString alloc] initWithString:[column objectForKey:@"Type"]];
                    
                    if ([column_type isEqualToString:@"Field"]){
                        NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
                        [newObj setObject:@"Field" forKey:@"CellType"];
                        [newObj setObject:[column objectForKey:@"Name"] forKey:@"FieldName"];
                        [newObj setObject:[column objectForKey:@"Label"] forKey:@"FieldLabel"];
                        [newObj setObject:[column objectForKey:@"KeyboardType"] forKey:@"KeyboardType"];
                        [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"FieldTableParent"];
                        [newObj setObject:[NSNumber numberWithInt:z] forKey:@"FieldTableRowIndex"];
                        
                        [self.layout addObject:newObj];
                    }
                    
                    if ([column_type isEqualToString:@"SearchSelection"]){
                        NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
                        [newObj setObject:@"SearchSelection" forKey:@"CellType"];
                        [newObj setObject:[column objectForKey:@"Name"] forKey:@"Name"];
                        [newObj setObject:[column objectForKey:@"Label"] forKey:@"Label"];
                        [newObj setObject:[column objectForKey:@"SearchUrl"] forKey:@"SearchUrl"];
                        [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"TableParentName"];
                        [newObj setObject:[NSNumber numberWithInt:z] forKey:@"TableParentRowIndex"];
                        
                        [self.layout addObject:newObj];
                    }
                }
            }
            
            NSMutableDictionary *newObj = [[NSMutableDictionary alloc] init];
            [newObj setObject:@"TableRowFooter" forKey:@"CellType"];
            [newObj setObject:[structureObject objectForKey:@"Name"] forKey:@"TableName"];
            [self.layout addObject:newObj];
        }
    }
}

- (void)buttonZeroClicked:(id)sender{
    [self extraButtonClicked:0];
}

- (void)buttonOneClicked:(id)sender{
    [self extraButtonClicked:1];
}

- (void)buttonTwoClicked:(id)sender{
    [self extraButtonClicked:2];
}

- (void)buttonThreeClicked:(id)sender{
    [self extraButtonClicked:3];
}

- (void)extraButtonClicked:(int)index{
    NSDictionary *dict = [self.buttons objectAtIndex:index];
    
    if ([[dict objectForKey:@"Window"] isEqualToString:@"Same"]){
    }
    
    if ([[dict objectForKey:@"Window"] isEqualToString:@"New"]){
        UI *newUI = [[UI alloc] initWithNibName:@"UI" bundle:nil];
        newUI.startTime = [NSDate date];
        newUI.delegate = self;
        newUI.titleBarColor = [dict objectForKey:@"TitleBarColorNewWindow"];
        
        [newUI sendQueryFirstMethod:[dict objectForKey:@"Method"] url:[dict objectForKey:@"Url"] body:[dict objectForKey:@"Body"]];
        [self.navigationController pushViewController:newUI animated:YES];
        [self.view endEditing:YES];
    }
}


- (void)drawButtons{
    if (self.buttons == nil){
        self.navigationController.toolbarHidden = YES;
    }else{
        self.navigationController.toolbarHidden = NO;
        
        UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [items addObject:flexiableItem];
        
        for (int i = 0; i < [self.buttons count]; i++){
            if (i == 0){
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fa-clone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonZeroClicked:)];
                [items addObject:item];
                [items addObject:flexiableItem];
            }
            
            if (i == 1){
                UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonOneClicked:)];
                [items addObject:item1];
                [items addObject:flexiableItem];
            }
            
            if (i == 2){
                UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonTwoClicked:)];
                [items addObject:item1];
                [items addObject:flexiableItem];
            }
            
            if (i == 3){
                UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonThreeClicked:)];
                [items addObject:item1];
                [items addObject:flexiableItem];
            }
        }
        self.toolbarItems = items;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.connectionServerFirst){
        double timepassed_ms = [self.startTime timeIntervalSinceNow] * -1000.0;
        [self.timeButton setTitle:[NSString stringWithFormat:@"%.f ms",timepassed_ms] forState:UIControlStateNormal];
        
        if ([self.mimeTypeServerFirst isEqualToString:@"application/json"]){
            
            self.table.hidden = NO;
            
            NSDictionary *theData = [[[SBJsonParser alloc] init] objectWithData:self.receivedDataServerFirst];
            self.debug = [theData objectForKey:@"Debug"];
            
            if ([[theData objectForKey:@"Response"] isEqualToString:@"LocalActions"]){
                NSMutableArray *response = [[NSMutableArray alloc] initWithArray:[theData objectForKey:@"Data"]];
                
                [self runLocalActions:response];
            }
            
            if ([[theData objectForKey:@"Response"] isEqualToString:@"UI"]){
                NSDictionary *values = [[NSDictionary alloc] initWithDictionary:[[theData objectForKey:@"Data"] objectForKey:@"VisibleData"]];
                
                NSDictionary *description = [[NSDictionary alloc] initWithDictionary:[[theData objectForKey:@"Data"] objectForKey:@"VisibleDataDescription"]];
                
                self.structure = [[theData objectForKey:@"Data"] objectForKey:@"Structure"];
                self.processMethod = [[theData objectForKey:@"Data"] objectForKey:@"Method"];
                self.processUrl = [[theData objectForKey:@"Data"] objectForKey:@"Url"];
                self.processWindow = [[theData objectForKey:@"Data"] objectForKey:@"Window"];
                self.hiddenData = [[theData objectForKey:@"Data"] objectForKey:@"HiddenData"];
                self.buttons = [[theData objectForKey:@"Data"] objectForKey:@"Buttons"];
                
                [self setTitle:[[theData objectForKey:@"Data"] objectForKey:@"Title"]];
                
                if (([[theData objectForKey:@"Data"] objectForKey:@"Url"] != nil)&&([[theData objectForKey:@"Data"] objectForKey:@"ButtonLabel"] != nil)){
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[theData objectForKey:@"Data"] objectForKey:@"ButtonLabel"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed)];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    self.barButtonItem = barButtonItem;
                }
                
                if ([[theData objectForKey:@"Data"] objectForKey:@"TitleBarColorNewWindow"] != nil){
                    self.processTitleBarColorNewWindow = [[theData objectForKey:@"Data"] objectForKey:@"TitleBarColorNewWindow"];
                }
                
                [self buildInitalData:values andDescription:description];
                [self reBuildLayout];
                [self.table reloadData];
                [self drawButtons];
            }
        }else{
            self.table.hidden = YES;
        }
        
        if ([self.mimeTypeServerFirst isEqualToString:@"text/html"]){
            self.navigationController.toolbarHidden = YES;
            
            [self.web loadData:self.receivedDataServerFirst MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:[[NSURL alloc] initWithString:@"https://www.infium.com/"]];
        }else{
            self.web.hidden = YES;
        }
        
        self.connectionServerFirst = nil;
        self.receivedDataServerFirst = nil;
        
    }
    
    if (connection == self.connectionServerSecond){
        if ([self.mimeTypeServerSecond isEqualToString:@"application/json"]){
            NSDictionary *theData = [[[SBJsonParser alloc] init] objectWithData:self.receivedDataServerSecond];
            if ([[theData objectForKey:@"Response"] isEqualToString:@"LocalActions"]){
                NSMutableArray *response = [[NSMutableArray alloc] initWithArray:[theData objectForKey:@"Data"]];
                [self runLocalActions:response];
            }
        }
        self.connectionServerSecond = nil;
        self.receivedDataServerSecond = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == self.connectionServerFirst)
    {
        self.connectionServerFirst = nil;
        self.receivedDataServerFirst = nil;
        
        [self showAlertMessage:[error localizedDescription] withTitle:@"Connection error"];
    }
    
    if (connection == self.connectionServerSecond)
    {
        self.connectionServerSecond = nil;
        self.receivedDataServerSecond = nil;
        
        [self showAlertMessage:[error localizedDescription] withTitle:@"Connection error"];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.table.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect newframe = self.view.bounds;
    
    self.table.frame = newframe;
    
    [UIView commitAnimations];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateTimer) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTimer) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.web.scrollView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.bounds.size.height,0.0,0.0,0.0);
    self.web.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.bounds.size.height,0.0,0.0,0.0);
    
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rowCell"];
    
}

-(void)startTimer{
    if (self.refreshSeconds != nil){
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: [self.refreshSeconds intValue] target:self selector: @selector(refresh:) userInfo: nil repeats: YES];
        self.refreshTimer = timer;
    }
}

-(void)invalidateTimer{
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)showAlertMessage:(NSString *)message withTitle: (NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    UIColor *c;
    
    if (self.titleBarColor != nil){
        c = [self colorFromHexString:self.titleBarColor];
    }else{
        c = [self colorFromHexString:@"#923E9E"];
    }
    
    self.navigationController.navigationBar.barTintColor = c;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self drawButtons];
    
    [super viewWillAppear:(BOOL)animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [self startTimer];
    [super viewDidAppear:(BOOL)animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self invalidateTimer];
    [super viewDidDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self setTitle:theTitle];
    self.web.hidden = NO;
    
    if (self.showPrintIcon == YES){
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(printButtonPressed)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
        self.barButtonItem = barButtonItem;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

