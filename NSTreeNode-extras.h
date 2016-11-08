/*

  Created by David Spooner; see License.txt

  Convenience methods added to NSTreeController.

*/

#import <Cocoa/Cocoa.h>


@interface NSTreeNode(extras)

- (NSArray *) ancestorNodesIncludingSelf:(BOOL)flag;

@end
