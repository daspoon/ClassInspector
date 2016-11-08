/*

*/

#import "NSMutableAttributedString-ClassInspector.h"


@implementation NSMutableAttributedString(ClassInspector)

- (void) appendString:(NSString *)string
  { [self appendAttributedString:[[NSAttributedString alloc] initWithString:string]]; }

- (void) appendString:(NSString *)string withAttributes:(NSDictionary *)attributes
  { [self appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attributes]]; }

@end
