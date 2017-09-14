#import <UIKit/UIKit.h>

@protocol CellImageUploadDelegate
-(void)updateImage:(NSString *)text fieldName:(NSString *)fieldName sourceType:(UIImagePickerControllerSourceType)source maxImageWidth:(NSNumber *)maxImageWidth maxImageHeight:(NSNumber *)maxImageHeight ImageQuality:(NSNumber *)ImageQuality;
@end

@interface CellImageUpload : UITableViewCell

@property NSNumber *maxImageWidth;
@property NSNumber *maxImageHeight;
@property NSNumber *imageQuality;
@property NSString *imageUploadName;
@property IBOutlet UILabel *labelImageUploadName;
@property IBOutlet UIImageView *theImageView;

@property (assign) id <CellImageUploadDelegate> delegate;

-(IBAction)presentImagePickerCamera;
-(IBAction)presentImagePickerPhotoLibrary;

@end
