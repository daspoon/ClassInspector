/*

  Created by David Spooner; see License.txt

*/

#import <Cocoa/Cocoa.h>


@interface GxClassTree : NSTreeNode

- (instancetype) init;
    // Initialize a tree with descendant nodes corresponding to each class registered in the runtime system.

- (NSString *) name;
    // Return the name of the associated class.

@end
