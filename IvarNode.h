/*

  Created by David Spooner; see License.txt

  Instances of this class represent instance variables of an inspected obj-c class.

*/

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>


@interface GxIvarNode : NSTreeNode

- (id) initWithIvar:(Ivar)anIvar;

@end
