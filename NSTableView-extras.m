/*

  Created by David Spooner; see License.txt

*/

#import "NSTableView-extras.h"


@implementation NSTableView(extras)

- (NSArrayController *) contentArrayController
  {
    NSArrayController *controller = [[self infoForBinding:NSContentBinding] objectForKey:NSObservedObjectKey];
    return [controller isKindOfClass:[NSArrayController class]] ? controller : nil;
  }

@end
