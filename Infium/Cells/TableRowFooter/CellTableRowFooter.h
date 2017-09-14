#import <UIKit/UIKit.h>

@protocol CellTableRowFooterDelegate
-(void)addEmptyRowToTable:(NSString *) tableName indexPath:(NSIndexPath *)indexPath;
@end

@interface CellTableRowFooter : UITableViewCell

@property NSString *tableName;

@property (assign) id <CellTableRowFooterDelegate> delegate;

@end
