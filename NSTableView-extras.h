/*

  Created by David Spooner; see License.txt

  Convenience methods added to NSTableView.

*/

#import <AppKit/AppKit.h>


@interface NSTableView(extras)

- (NSArrayController *) contentArrayController;
    // Return the array controller associated to the receiver's 'content' property, or nil if the content is not an NSArrayController.

@end
