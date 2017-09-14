#import <UIKit/UIKit.h>

@protocol CellFieldDelegate
-(void)updateText:(NSString *)text fieldName:(NSString *)fieldName fieldTableParent:(NSString *)fieldTableParent fieldTableRowIndex:(NSNumber *)fieldTableRowIndex;
@end

@interface CellField : UITableViewCell

@property NSString *fieldName;
@property NSString *fieldTableParent;
@property NSNumber *fieldTableRowIndex;
@property IBOutlet UILabel *labelFieldName;
@property IBOutlet UITextField *fieldValue;

@property (assign) id <CellFieldDelegate> delegate;

@end
