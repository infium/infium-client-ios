//
//  Copyright 2012-2017 Infium AB
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
