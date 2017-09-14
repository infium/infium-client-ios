#import "CellField.h"

@implementation CellField

-(IBAction)fieldWasUpdated:(id)sender{
    [self.delegate updateText:(NSString *)[self.fieldValue text] fieldName:(NSString *)self.fieldName fieldTableParent:(NSString *)self.fieldTableParent fieldTableRowIndex:(NSNumber *)self.fieldTableRowIndex];
    //[[[UIAlertView alloc] initWithTitle:@"Value" message:[NSString stringWithFormat:@"%@",[self.fieldValue text]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
