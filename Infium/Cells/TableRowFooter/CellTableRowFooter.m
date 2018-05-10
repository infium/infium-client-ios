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
