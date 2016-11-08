/*

  Created by David Spooner; see License.txt

*/

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>


@interface GxIvarNode : NSTreeNode

- (id) initWithIvar:(Ivar)anIvar;

@end
