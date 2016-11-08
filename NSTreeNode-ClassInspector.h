/*

  Created by David Spooner; see License.txt

  Convenience methods added to NSTreeNode.

*/

#import <Cocoa/Cocoa.h>


@interface NSTreeNode(ClassInspector)

- (NSAttributedString *) attributedDescription;
    // Returns the description of the representedObject as an attributed string.

@end
