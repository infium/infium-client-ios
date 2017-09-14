#import "CellLabelWithLink.h"

@implementation CellLabelWithLink

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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.icon.frame = self.iconFrame;
    self.label.frame = self.labelFrame;
    self.value.frame = self.valueFrame;
}

@end
