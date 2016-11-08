/*

  Created by David Spooner; see License.txt

  This class manages the main application window which presents a master-detail interface where the obj-c class hierarchy appears in an outline on the left and details of the selected class appear on the right.

*/

#import <Cocoa/Cocoa.h>
#import "ClassTree.h"


@interface GxClassInspector : NSWindowController <NSToolbarDelegate, NSTextViewDelegate>

@property (nonatomic, retain) GxClassTree *classTree;

@property (nonatomic, copy) NSString *filterString;

@property (nonatomic) NSUInteger filterMode;

@property (nonatomic, readonly) NSPredicate *filterPredicate;

@property (nonatomic, copy) NSArray *selectedNodePath;

@property (nonatomic) NSUInteger selectedNodePathIndex;

@property (nonatomic, readonly) GxClassTree *selectedNode;

@property (nonatomic, readonly) NSAttributedString *selectedNodeDescription;

@property (nonatomic, readonly) NSUInteger currentTabIndex;

@property (nonatomic, readonly) NSArray *sortDescriptors;


// IB

@property (nonatomic, assign) IBOutlet NSOutlineView *outlineView;
    // The outline view presenting the entire class hierarchy.

@property (nonatomic, assign) IBOutlet NSTableView *tableView;
    // The table view presenting the filtered list of classes.

@property (nonatomic, assign) IBOutlet NSOutlineView *detailView;
    // The outline view presenting the ivar/method details of the selected class.

@property (nonatomic, assign) IBOutlet NSTextView *pathView;
    // The text view which presents the class inheritance path of the current selection.

@end
