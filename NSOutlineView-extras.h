/*

  Created by David Spooner; see License.txt

  Convenience methods added to NSOutlineView.

*/

#import <AppKit/AppKit.h>


@interface NSOutlineView(extras)

- (NSTreeController *) contentTreeController;
    // Return the NSTreeController bound to the receiver's 'content' property, or nil if the content is not an NSTreeController.

@end
