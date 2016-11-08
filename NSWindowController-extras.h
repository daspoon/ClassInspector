/*

  Created by David Spooner; see License.txt

  Convenience methods added to NSWindowController.

*/

#import <Cocoa/Cocoa.h>


@interface NSWindowController(extras)

// The following methods enable a subclass of NSWindowController to act as a NSToolbarDelegate by implementing key-specific methods for item creation, addition and removal.

- (NSToolbarItem *) toolbar:(NSToolbar *)sender itemForItemIdentifier:(NSString *)key willBeInsertedIntoToolbar:(BOOL)flag;
    // If the receiver responds to a method named -create<Key>ItemForToolbar: then return the result of that method; otherwise return nil.

- (void) toolbarWillAddItem:(NSNotification *)notification;
    // Invokes the receiver's method -toolbar:willAdd<Key>Item: if possible; otherwise do nothing. The toolbar and item arguments are taken from the notification.

- (void) toolbarDidRemoveItem:(NSNotification *)notification;
    // Invokes the receiver's method -toolbar:didRemove<Key>Item: if possible; otherwise do nothing. The toolbar and item arguments are taken from the notification.

@end
