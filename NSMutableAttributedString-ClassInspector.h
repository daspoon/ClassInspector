/*

  Created by David Spooner; see License.txt

*/

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString(ClassInspector)

- (void) appendString:(NSString *)string;

- (void) appendString:(NSString *)string withAttributes:(NSDictionary *)attributes;

@end
