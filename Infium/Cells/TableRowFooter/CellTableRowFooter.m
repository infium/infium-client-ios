#import "CellTableRowFooter.h"

@implementation CellTableRowFooter

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib]; // ADDED
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(IBAction)addRowButtonTapped{
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO){
        view = [view superview];
    }
    
    UITableView *tableView = (UITableView *)view;
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    
    [self.delegate addEmptyRowToTable:self.tableName indexPath:indexPath];
    
}

@end
