/*

  Created by David Spooner; see License.txt

  An ObjCTypeFormatter converts Objective-C type encodings (viz. @encode) into approximations
  of C type strings to a specified level of detail.

*/

#import <Foundation/Foundation.h>
#import "ObjCTypeParser.h"


@interface GxObjCTypeFormatter : NSFormatter
  {
    GxObjCTypeParser parser;
    NSUInteger levelOfDetail;
  }

@property (nonatomic) NSUInteger levelOfDetail;
    // The level to which the components of structures and unions are revealed.  The default value is 1.


- (NSString *) stringForObjCTypeRef:(const char **)ctype;
    // Return the description of the type encoding at the given address and update the given pointer
    // to indicate the end of the formatted type encoding.

- (NSString *) stringForObjCType:(const char *)type;
    // Return the description of the given @encode string.

@end
