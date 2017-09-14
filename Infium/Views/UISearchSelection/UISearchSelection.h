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
