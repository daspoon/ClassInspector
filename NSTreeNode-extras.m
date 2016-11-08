/*

  Created by David Spooner; see License.txt

*/

#import "NSTreeNode-extras.h"
#import "TreeEnumerator.h"


@implementation NSTreeNode(extras)

- (NSArray *) ancestorNodesIncludingSelf:(BOOL)includeSelf
  {
    NSMutableArray *array = [NSMutableArray array];
    for (NSTreeNode *node = includeSelf ? self : self.parentNode; node != nil; node = node.parentNode)
      [array insertObject:node atIndex:0];
    return array;
  }


- (NSArray *) allNodes
  { return [[[GxTreeEnumerator alloc] initWithTree:(id<GxTree>)self] allObjects]; }

@end
