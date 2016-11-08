/*

  Created by David Spooner; see License.txt

*/

#import "NSOutlineView-extras.h"


@implementation NSOutlineView(extras)

- (NSTreeController *) contentTreeController
  {
    NSTreeController *controller = [[self infoForBinding:NSContentBinding] objectForKey:NSObservedObjectKey];
    return [controller isKindOfClass:[NSTreeController class]] ? controller : nil;
  }

@end
