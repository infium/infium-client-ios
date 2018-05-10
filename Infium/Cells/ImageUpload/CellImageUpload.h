//
//  Copyright 2012-2017 Marcus Hammar
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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
