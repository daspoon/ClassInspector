/*

  Created by David Spooner; see License.txt

  The TreeEnumerator class enables depth-first traversal of a tree as an NSEnumerator.

*/

#import <Foundation/Foundation.h>


// The protocol required of tree/node objects.

@protocol GxTree

- (NSUInteger) countOfSubNodes;

- (id<GxTree>) objectInSubNodesAtIndex:(NSUInteger)index;

@end


// The following enum specifies the actions which can be taken at each node to affect the remaining traversal.

typedef NS_OPTIONS(NSUInteger, GxTreeStep) {
    GxTreeStep_Continue,
        // Process the node normally.
    GxTreeStep_Skip,
        // Skip the node and its descendants.
    GxTreeStep_Exit
        // Abort the traversal.
  };


@interface GxTreeEnumerator : NSEnumerator

- (instancetype) initWithTree:(id<GxTree>)aTree enterBlock:(GxTreeStep(^)(id))enterBlock exitBlock:(void(^)(id))exitBlock;
    // Initialize a new instance to traverse the given tree. The enter block, if non-nil, is called at each node to determine how each node affects the traversal. The exit block (if non-nil) is called on each node immediately after the node and all of its children have been visited. This method is the designated initializer.

- (instancetype) initWithTree:(id<GxTree>)aTree enterBlock:(GxTreeStep(^)(id))enterBlock;
    // Invoke the designated initializer with nil exit block.

- (instancetype) initWithTree:(id<GxTree>)aTree predicate:(NSPredicate *)aPredicate;
    // Convenience method which only traverses nodes satisfying the given predicate.

- (instancetype) initWithTree:(id<GxTree>)aTree;
    // Invokes the designated initializer with nil enter and exit blocks.


- (void) reset;
    // Restart the enumeration at the root of the tree.


- (void) perform;
    // Invoke -nextObject repeatedly until it returns nil.

@end
