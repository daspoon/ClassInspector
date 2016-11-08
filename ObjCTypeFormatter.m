/*

  Created by David Spooner; see License.txt

*/

#import "ObjCTypeFormatter.h"
#import "utilities.h"


// This structure serves as the context parameter to the type parser callbacks...

@interface GxObjCTypeFormatterCallbackInfo : NSObject
  {
  @public
    __weak GxObjCTypeFormatter *formatter;    // The formatter object
    NSMutableString *buffer;  // The string into which the type description is being written
    NSUInteger level;   // The nesting level for structures, unions and/or arrays...
  }

- (id) initWithObjCTypeFormatter:(GxObjCTypeFormatter *)formatter;
@end
@implementation GxObjCTypeFormatterCallbackInfo
- (id) initWithObjCTypeFormatter:(GxObjCTypeFormatter *)aFormatter
  {
    formatter = aFormatter;
    buffer = [NSMutableString string];
    return self;
  }
@end


@implementation GxObjCTypeFormatter

@synthesize levelOfDetail;


// The following local functions are callbacks for the type parser...

static void format_numeric(const char *ctype, void *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:GxStringFromNumericTypeCode(*ctype)]; }

static void format_void(void *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"void"]; }

static void format_selector(SEL *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"SEL"]; }

static void format_class(Class *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"Class"]; }

static void format_object(const char *name, id __unsafe_unretained *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) { if (name) [info->buffer appendFormat:@"%s *", name]; else [info->buffer appendString:@"id"]; } }

static void format_pointer(void **address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@" *"]; }

static void format_string(char **address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"char *"]; }

static void format_struct_begin(const char *ctype, const char *tag, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendFormat:@"struct %s {", tag]; ++info->level; }

static void format_struct_delimeter(GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"; "]; }

static void format_struct_end(const char *ctype, GxObjCTypeFormatterCallbackInfo *info)
  { --info->level; if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"}"]; }

static BOOL format_array_begin(NSUInteger count, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendFormat:@"[%ld", count]; return NO; }

static void format_array_end(GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"]"]; }

static void format_union_begin(GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendFormat:@"union {"]; ++info->level; }

static void format_union_delimeter(GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"; "]; }

static void format_union_end(GxObjCTypeFormatterCallbackInfo *info)
  { --info->level; if (info->level < info->formatter->levelOfDetail) [info->buffer appendFormat:@"}"]; }

static void format_name(const char *name, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendFormat:@" %s", name]; }

static void format_bitfield(unsigned char *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"<bitfield>"]; }

static void format_const(GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"const "]; }

static void format_unknown(void *address, GxObjCTypeFormatterCallbackInfo *info)
  { if (info->level < info->formatter->levelOfDetail) [info->buffer appendString:@"?"]; }

- (id) init
  {
    if ((self = [super init]) == nil)
      return nil;

    parser.parse_numeric          = (void (*)(const char *, void *, void *))       format_numeric;
    parser.parse_void             = (void (*)(void *, void *))                     format_void;
    parser.parse_selector         = (void (*)(SEL *, void *))                      format_selector;
    parser.parse_class            = (void (*)(Class *, void *))                    format_class;
    parser.parse_object           = (void (*)(const char *, id __unsafe_unretained *, void *))format_object;
    parser.parse_string           = (void (*)(char **, void *))                    format_string;
    parser.parse_pointer_begin    = (void (*)(void **, void *))                    NULL;
    parser.parse_pointer_end      = (void (*)(void **, void *))                    format_pointer;
    parser.parse_bitfield         = (void (*)(unsigned char *, void *))            format_bitfield;
    parser.parse_struct_begin     = (void (*)(const char *, const char *, void *)) format_struct_begin;
    parser.parse_struct_delimiter = (void (*)(void *))                             format_struct_delimeter;
    parser.parse_struct_end       = (void (*)(const char *, void *))               format_struct_end;
    parser.parse_array_begin      = (BOOL (*)(NSUInteger, void *))                 format_array_begin;
    parser.parse_array_delimiter  = (void (*)(void *))                             NULL;
    parser.parse_array_end        = (void (*)(void *))                             format_array_end;
    parser.parse_union_begin      = (void (*)(void *))                             format_union_begin;
    parser.parse_union_delimiter  = (void (*)(void *))                             format_union_delimeter;
    parser.parse_union_end        = (void (*)(void *))                             format_union_end;
    parser.parse_element_name     = (void (*)(const char *, void *))               format_name;
    parser.parse_const            = (void (*)(void *))                             format_const;
    parser.parse_unknown          = (void (*)(void *, void *))                     format_unknown;

    levelOfDetail = 1;

    return self;
  }


- (NSString *) stringForObjCTypeRef:(const char **)type_p
  {
    GxObjCTypeFormatterCallbackInfo *info = [[GxObjCTypeFormatterCallbackInfo alloc] initWithObjCTypeFormatter:self];

    *type_p = parser.parseType(*type_p, NULL, info);

    return info->buffer;
  }


- (NSString *) stringForObjCType:(const char *)type
  { return [self stringForObjCTypeRef:&type]; }


#pragma mark NSFormatter

- (NSString *) stringForObjectValue:(id)object
  {
    NSAssert([object isKindOfClass:[NSString class]], @"invalid argument");

    return [self stringForObjCType:[(NSString *)object UTF8String]];
  }

@end
