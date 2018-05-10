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
