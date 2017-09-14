#import <UIKit/UIKit.h>
#import "CellField.h"
#import "CellImageUpload.h"
#import "CellTableRowFooter.h"
#import "UISearchSelection.h"

@class UI;

@protocol UIDelegate
-(void)pop:(UI *)flow;
-(void)runLocalActions:(NSMutableArray *)actions;
@end

@interface UI : UIViewController <UITableViewDelegate, UITableViewDataSource, CellFieldDelegate,UIDelegate,CellImageUploadDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CellTableRowFooterDelegate,SearchSelectionDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>

@property NSDate *startTime;
@property NSMutableArray *buttons;
@property NSMutableArray *layout;
@property NSMutableArray *structure;
@property NSMutableData *receivedDataServerFirst;
@property NSMutableData *receivedDataServerSecond;
@property NSMutableDictionary *hiddenData;
@property NSMutableDictionary *visibleData;
@property NSMutableDictionary *visibleDataDescription;
@property NSNumber *currentMaxImageWidth;
@property NSNumber *currentMaxImageHeight;
@property NSNumber *currentImageQuality;
@property NSNumber *heightField;
@property NSNumber *heightImageUpload;
@property NSNumber *heightLabelWithLink;
@property NSNumber *heightSearchSelection;
@property NSNumber *heightTableRowFooter;
@property NSNumber *heightTableRowHeader;
@property NSNumber *refreshSeconds;
@property NSString *currentImageName;
@property NSString *debug;
@property NSString *mimeTypeServerFirst;
@property NSString *mimeTypeServerSecond;
@property NSString *queryMethod;
@property NSString *queryUrl;
@property NSString *queryBody;
@property NSString *titleBarColor;
@property NSString *processMethod;
@property NSString *processTitleBarColorNewWindow;
@property NSString *processUrl;
@property NSString *processWindow;
@property BOOL showPrintIcon;

@property NSTimer *refreshTimer;
@property NSURLConnection *connectionServerFirst;
@property NSURLConnection *connectionServerSecond;
@property IBOutlet UIButton *timeButton;
@property IBOutlet UIBarButtonItem *barButtonItem;
@property IBOutlet UITableView *table;
@property IBOutlet UIWebView *web;

-(void)sendQueryFirstMethod:(NSString *)method url:(NSString *)url body:(NSString *)body;

@property (assign) id <UIDelegate> delegate;

@end
