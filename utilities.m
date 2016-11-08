/*

  Created by David Spooner; see License.txt

*/

#import "utilities.h"
#import <objc/runtime.h>


BOOL GxIsDescendantClass(Class B, Class A)
  {
    NSCAssert(B != nil && A != nil, @"invalid arguments");
    for (; B != A && B != nil; B = class_getSuperclass(B));
    return B ? YES : NO;
  }


NSUInteger GxSizeOfNumericTypeCode(char code)
  {
    switch (code) {
      case 'c' : return sizeof(char);
      case 's' : return sizeof(short);
      case 'i' : return sizeof(int);
      case 'l' : return sizeof(long);
      case 'q' : return sizeof(long long);
      case 'C' : return sizeof(unsigned char);
      case 'S' : return sizeof(unsigned short);
      case 'I' : return sizeof(unsigned int);
      case 'L' : return sizeof(unsigned long);
      case 'Q' : return sizeof(unsigned long long);
      case 'f' : return sizeof(float);
      case 'd' : return sizeof(double);
      case 'B' : return sizeof(_Bool);
    }
    NSCAssert1(0, @"Invalid type code: %0d", code);
    return 0;
  }


NSUInteger GxAlignmentOfNumericTypeCode(char code)
  {
    switch (code) {
      #define ALIGNMENT(T) { struct { char c; T t; } v; return (char *)&v.t - &v.c; }
      case 'c' : ALIGNMENT(char);
      case 's' : ALIGNMENT(short);
      case 'i' : ALIGNMENT(int);
      case 'l' : ALIGNMENT(long);
      case 'q' : ALIGNMENT(long long);
      case 'C' : ALIGNMENT(unsigned char);
      case 'S' : ALIGNMENT(unsigned short);
      case 'I' : ALIGNMENT(unsigned int);
      case 'L' : ALIGNMENT(unsigned long);
      case 'Q' : ALIGNMENT(unsigned long long);
      case 'f' : ALIGNMENT(float);
      case 'd' : ALIGNMENT(double);
      case 'B' : ALIGNMENT(_Bool);
      #undef ALIGNMENT
    }
    NSCAssert1(0, @"Invalid type code: %0d", code);
    return 0;
  }


NSString *GxStringFromNumericTypeCode(char code)
  {
    switch (code) {
      case 'c' : return @"char";
      case 's' : return @"short";
      case 'i' : return @"int";
      case 'l' : return @"long";
      case 'q' : return @"long long";
      case 'C' : return @"unsigned char";
      case 'S' : return @"unsigned short";
      case 'I' : return @"unsigned int";
      case 'L' : return @"unsigned long";
      case 'Q' : return @"unsigned long long";
      case 'f' : return @"float";
      case 'd' : return @"double";
      case 'B' : return @"_Bool";
    }
    NSCAssert1(0, @"Invalid type code: %0d", code);
    return 0;
  }
