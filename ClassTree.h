/*

  Created by David Spooner; see License.txt

  Instances of this class represent Objective-C class objects with children related by direct inheritance.

*/

#import <Cocoa/Cocoa.h>


@interface GxClassTree : NSTreeNode

- (instancetype) init;
    // Initialize a tree with descendant nodes corresponding to each class registered in the runtime system.

- (NSString *) name;
    // Return the name of the associated class.

- (NSTreeNode *) detailTree;
    // Each class has an associated tree with three children representing instance variables, instance methods and class methods, each with zero or more leaf nodes.

@end
