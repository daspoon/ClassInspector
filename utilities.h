/*

  Created by David Spooner; see License.txt

  Utility functions.

*/

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT BOOL GxIsDescendantClass(Class B, Class A);
  // Return YES iff class B is a descendant of class A.  Note: this function is intended to behave like NSObject's +isSubclassOfClass: in cases where argument classes are not derived from NSObject.


FOUNDATION_EXPORT NSUInteger GxSizeOfNumericTypeCode(char code);
    // Return the size in bytes of values of the given numeric type code.

FOUNDATION_EXPORT NSUInteger GxAlignmentOfNumericTypeCode(char code);
    // Return the byte alignment required for structure fields of the given numeric type code.

FOUNDATION_EXPORT NSString *GxStringFromNumericTypeCode(char code);
    // Return the C type name for the given numeric type code.
