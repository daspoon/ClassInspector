/*

  Created by David Spooner; see License.txt

*/

#import "NSTreeNode-ClassInspector.h"


@implementation NSTreeNode(ClassInspector)

- (NSAttributedString *) attributedDescription
  { return [[NSAttributedString alloc] initWithString:[self.representedObject description]]; }

@end
