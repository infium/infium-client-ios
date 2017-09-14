#import <UIKit/UIKit.h>

@interface CellLabelWithLink : UITableViewCell

@property IBOutlet UILabel *icon;
@property IBOutlet UILabel *label;
@property IBOutlet UILabel *value;

@property CGRect iconFrame;
@property CGRect labelFrame;
@property CGRect valueFrame;

@end
