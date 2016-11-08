/*

  Created by David Spooner; see License.txt

*/

#import "ClassInspector.h"
#import "NSMutableAttributedString-ClassInspector.h"


enum {
    FilterModeContains,
    FilterModeBeginsWith,
    FilterModeEndsWith
  };


@implementation GxClassInspector
  {
    GxAdaptor *_outlineViewAdaptor;
    GxAdaptor *_tableViewAdaptor;
    GxAdaptor *_detailViewAdaptor;
    BOOL _detailExpanded[3];
  }


- (id) initWithWindow:(NSWindow *)aWindow
  {
    if ((self = [super initWithWindow:aWindow]) == nil)
      return nil;

    _classTree = [[GxClassTree alloc] init];

    _filterMode = FilterModeContains;

    _outlineViewAdaptor = [[GxAdaptor alloc] initWithTarget:self prefix:@"outline_" protocols:@protocol(NSOutlineViewDelegate), nil];
    _tableViewAdaptor   = [[GxAdaptor alloc] initWithTarget:self prefix:@"table_"   protocols:@protocol(NSTableViewDelegate), nil];
    _detailViewAdaptor  = [[GxAdaptor alloc] initWithTarget:self prefix:@"detail_"  protocols:@protocol(NSOutlineViewDelegate), nil];

    return self;
  }


- (id) init
  { return [self initWithWindowNibName:@"ClassInspector" owner:self]; }


- (void) dealloc
  {
    self.filterString = nil;
    self.selectedNodePath = nil;
  }


- (void) setSelectedNodePath:(NSArray *)aPath
  {
    _selectedNodePath = [aPath copy];

    _selectedNodePathIndex = aPath ? [aPath count] - 1 : 0;

    if ([self isWindowLoaded])
      [self performSelector:@selector(autoExpand:) withObject:nil afterDelay:0];
  }


- (void) setSelectedNodePathIndex:(NSUInteger)anIndex
  {
    _selectedNodePathIndex = anIndex;

    if ([self isWindowLoaded])
      [self performSelector:@selector(autoExpand:) withObject:nil afterDelay:0];
  }


+ (NSSet *) keyPathsForValuesAffectingSelectedNode
  { return [NSSet setWithObjects:@"selectedNodePath", @"selectedNodePathIndex", nil]; }

- (GxClassTree *) selectedNode
  { return [_selectedNodePath objectAtIndex:_selectedNodePathIndex]; }


+ (NSSet *) keyPathsForValuesAffectingFilterPredicate
  { return [NSSet setWithObjects:@"filterString", @"filterMode", nil]; }

- (NSPredicate *) filterPredicate
  {
    NSPredicate *predicate = nil;

    if ([_filterString length] > 0) {
      switch (_filterMode) {
        case FilterModeContains   : predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"name", _filterString]; break;
        case FilterModeBeginsWith : predicate = [NSPredicate predicateWithFormat:@"%K beginswith[cd] %@", @"name", _filterString]; break;
        case FilterModeEndsWith   : predicate = [NSPredicate predicateWithFormat:@"%K endswith[cd] %@", @"name", _filterString]; break;
        default :
          NSAssert1(0, @"unhanded case: %ld", _filterMode);
      }
    }
    
    return predicate;
  }


+ (NSSet *) keyPathsForValuesAffectingFilterModeMenu
  { return [NSSet setWithObjects:@"filterMode", nil]; }

- (NSMenu *) filterModeMenu
  {
    NSMenu *menu = [[NSMenu alloc] init];

    struct { NSInteger tag; NSString *title; } v[] = {
        { FilterModeContains,   NSLocalizedString(@"CONTAINS",@"") },
        { FilterModeBeginsWith, NSLocalizedString(@"BEGINSWITH",@"") },
        { FilterModeEndsWith,   NSLocalizedString(@"ENDSWITH",@"") },
      };
    for (NSUInteger i = 0, n = sizeof(v)/sizeof(*v); i < n; ++i) {
      NSMenuItem *item = [menu addItemWithTitle:v[i].title action:@selector(selectFilterMode:) keyEquivalent:@""];
      item.target = self;
      item.tag = v[i].tag;
    }

    [[menu itemAtIndex:_filterMode] setState:NSOnState];

    return menu;
  }


+ (NSSet *) keyPathsForValuesAffectingSelectedNodeDescription
  { return [NSSet setWithObjects:@"selectedNodePath", @"selectedNodePathIndex", nil]; }

- (NSAttributedString *) selectedNodeDescription
  {
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithString:@""];

    if ([_selectedNodePath count] > 0) {
      [_selectedNodePath enumerateObjectsUsingBlock:
          ^(GxClassTree *node, NSUInteger index, BOOL *stop) {
              NSDictionary *attributes = index == _selectedNodePathIndex
                ? [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blueColor], NSForegroundColorAttributeName, nil]
                : [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:index], NSLinkAttributeName, nil];
              if (index > 0)
                [description appendString:@" : "];
              [description appendString:node.name withAttributes:attributes];
          }];
    }
    else
      [description appendString:@"No selection" withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NSForegroundColorAttributeName, [NSColor lightGrayColor], nil]];

    return description;
  }


+ (NSSet *) keyPathsForValuesAffectingCurrentTabIndex
  { return [NSSet setWithObjects:@"filterString", nil]; }

- (NSUInteger) currentTabIndex
  { return [_filterString length] == 0 ? 0 : 1; }


- (NSArray *) sortDescriptors
  {
    return [NSArray arrayWithObjects:
              [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
              nil];
  }


- (void) autoExpand:(id)sender
  {
    NSTreeController *detailController = [_detailView contentTreeController];

    for (NSUInteger i = 0; i < 3; ++i) {
      if (_detailExpanded[i]) {
        NSIndexPath *path = [NSIndexPath indexPathWithIndex:i];
        NSTreeNode *node = [detailController.arrangedObjects descendantNodeAtIndexPath:path];
        [_detailView expandItem:node];
      }
    }
  }


- (void) selectFilterMode:(NSMenuItem *)sender
  {
    // This method is invoked by items of the search menu upon selection. Update our filter mode to match the tag assigned on creation.
    self.filterMode = (NSUInteger)sender.tag;
  }


#pragma mark NSWindowController

- (void) windowDidLoad
  {
    NSWindow *window = self.window;

    NSAssert(window && _outlineView && _tableView && _detailView && _pathView, @"unconnected outlets");

    _outlineView.delegate = (id)_outlineViewAdaptor;
    _tableView.delegate   = (id)_tableViewAdaptor;
    _detailView.delegate  = (id)_detailViewAdaptor;

    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"ClassInspector"];
    toolbar.delegate = self;
    toolbar.allowsUserCustomization = NO;
    window.toolbar = toolbar;

    [_pathView setLinkTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSFont labelFontOfSize:[NSFont labelFontSize]], NSFontAttributeName,
          [NSColor blackColor], NSForegroundColorAttributeName,
          @(NSUnderlineStyleNone), NSUnderlineStyleAttributeName,
          nil]];
    [_pathView setDelegate:self];

    [self performSelector:@selector(autoExpand:) withObject:nil afterDelay:0];
  }


#pragma mark NSOutlineViewDelegate

- (BOOL) detail_outlineView:(NSOutlineView *)sender isGroupItem:(NSTreeNode *)item
  {
    return item.indexPath.length == 1 ? YES : NO;;
  }

- (BOOL) detail_outlineView:(NSOutlineView *)sender shouldExpandItem:(NSTreeNode *)item
  {
    NSUInteger index = [[item indexPath] lastIndex]; NSAssert(index < 3, @"unexpected argument");
    _detailExpanded[index] = YES;
    return YES;
  }

- (BOOL) detail_outlineView:(NSOutlineView *)sender shouldCollapseItem:(NSTreeNode *)item
  {
    NSUInteger index = [[item indexPath] lastIndex]; NSAssert(index < 3, @"unexpected argument");
    _detailExpanded[index] = NO;
    return YES;
  }


- (void) outline_outlineViewSelectionDidChange:(NSNotification *)notification
  {
    NSArray *selection = [[_outlineView contentTreeController] selectedObjects];
    self.selectedNodePath = [selection.onlyObject ancestorNodesIncludingSelf:YES];
  }


#pragma mark NSTableViewDelegate

- (void) table_tableViewSelectionDidChange:(NSNotification *)notification
  {
    NSArray *selection = [[_tableView contentArrayController] selectedObjects];
    self.selectedNodePath = [selection.onlyObject ancestorNodesIncludingSelf:YES];
  }


#pragma mark NSTextViewDelegate

- (BOOL) textView:(NSTextView *)sender clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
  {
    self.selectedNodePathIndex = [(NSNumber *)link unsignedIntegerValue];
    return YES;
  }


#pragma mark NSToolbarDelegate

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *)sender
  {
    return [NSArray arrayWithObjects:
                @"SearchField",
                NSToolbarFlexibleSpaceItemIdentifier,
                nil];
  }


- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *)sender
  {
    return [self toolbarAllowedItemIdentifiers:sender];
  }


// Note that the category NSWindowController(extras) implements some of the NSToolbarDelegate protocol.

- (NSToolbarItem *) createSearchFieldItemForToolbar:(NSToolbar *)toolbar
  {
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:@"SearchField"];

    NSSearchField *searchField = [[NSSearchField alloc] init];
    [searchField setContinuous:YES];

    item.view = searchField;
    item.label = NSLocalizedString(@"SEARCH FIELD", @"");
    item.paletteLabel = NSLocalizedString(@"SEARCH FIELD", @"");
    item.toolTip = NSLocalizedString(@"DISPLAY ONLY ITEMS WITH NAMES MATCHING THE SEARCH FIELD CONTENTS.", @"");;
    item.minSize = NSMakeSize(100,26);
    item.maxSize = NSMakeSize(160,26);

    return item;
  }


- (void) toolbar:(NSToolbar *)toolbar willAddSearchFieldItem:(NSToolbarItem *)item
  {
    NSSearchField *searchField = (NSSearchField *)item.view;
    [searchField bind:@"value" toObject:self withKeyPath:@"filterString" options:nil];
    [searchField.cell bind:@"searchMenuTemplate" toObject:self withKeyPath:@"filterModeMenu" options:nil];
  }


- (void) toolbar:(NSToolbar *)toolbar didRemoveSearchFieldItem:(NSToolbarItem *)item
  {
    NSSearchField *searchField = (NSSearchField *)item.view;
    [searchField unbind:@"value"];
    [searchField.cell unbind:@"searchMenuTemplate"];
  }

@end
