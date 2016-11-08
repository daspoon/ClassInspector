/*

  Created by David Spooner; see License.txt

  Instances of this class represent methods (either instance or class) of an inspected obj-c class.

*/

#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSUInteger, GxMethodKind) {
    GxMethodKindInstance,
    GxMethodKindClass,
  };


@interface GxMethodNode : NSTreeNode

- (instancetype) initWithMethod:(Method)aMethod kind:(GxMethodKind)aKind;

@end
