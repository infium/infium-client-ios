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

@class UISearchSelection;

@protocol SearchSelectionDelegate
-(void)updateSearchSelectionName:(NSString *)searchSelectionName forSearchSelection:(UISearchSelection *)searchSelection withValue:(NSString *)value andDescription:(NSString *)description atIndexPath:(NSIndexPath *)indexPath forTable:(NSString *)table atIndex:(NSNumber *)index;
@end

@interface UISearchSelection : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property NSNumber *SearchSerialNumber;
@property UISearchBar IBOutlet *searchBar;
@property UITableView IBOutlet *searchTable;
@property NSString *searchUrl;
@property NSString *selectedValue;
@property NSString *searchSelectionName;
@property NSMutableArray *searchResults;
@property NSIndexPath *indexPathInUI;

@property NSString *tableParentName;
@property NSNumber *tableParentRowIndex;

@property NSMutableData *receivedDataServerFirst;
@property NSURLConnection *connectionServerFirst;

@property (assign) id <SearchSelectionDelegate> delegate;

-(void)performSearch:(NSString *)query;

@end
