#import "CellImageUpload.h"
#import "UI.h"

@implementation CellImageUpload

-(IBAction)presentImagePickerCamera{
    [self.delegate updateImage:nil fieldName:self.imageUploadName sourceType:UIImagePickerControllerSourceTypeCamera maxImageWidth:self.maxImageWidth maxImageHeight:self.maxImageHeight ImageQuality:self.imageQuality];
}

-(IBAction)presentImagePickerPhotoLibrary{
    [self.delegate updateImage:nil fieldName:self.imageUploadName sourceType:UIImagePickerControllerSourceTypePhotoLibrary maxImageWidth:self.maxImageWidth maxImageHeight:self.maxImageWidth ImageQuality:self.imageQuality];
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib]; // Added
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
