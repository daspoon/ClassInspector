/*

  Created by David Spooner; see License.txt

*/

#import "NSIndexPath-extras.h"


@implementation NSIndexPath(extras)

- (NSUInteger) lastIndex
  { return [self indexAtPosition:([self length] - 1)]; }

@end
