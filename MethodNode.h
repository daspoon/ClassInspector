/*

  Created by David Spooner; see License.txt

*/

#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSUInteger, GxMethodKind) {
    GxMethodKindInstance,
    GxMethodKindClass,
  };


@interface GxMethodNode : NSTreeNode

- (instancetype) initWithMethod:(Method)aMethod kind:(GxMethodKind)aKind;

@end
