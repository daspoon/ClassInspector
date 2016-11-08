/*

  Created by David Spooner; see License.txt

*/

#import "NSArray-extras.h"


@implementation NSArray(extras)

- (id) onlyObject
  { return [self count] == 1 ? [self lastObject] : nil; }

@end
