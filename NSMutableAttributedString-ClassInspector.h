/*

  Created by David Spooner; see License.txt

  Convenience methods added to NSMutableAttributedString.

*/

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString(ClassInspector)

- (void) appendString:(NSString *)string;

- (void) appendString:(NSString *)string withAttributes:(NSDictionary *)attributes;

@end
