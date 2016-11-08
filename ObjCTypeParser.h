/*

  Created by David Spooner; see License.txt

  An ObjCTypeParser provides support for parsing and interpreting objective-c type encoding
  strings.  This is useful providing archiving or formatting support for NSValue.

  As an example of its use, the following function could be used to calculate the size in 
  bytes of a given type:

      NSUInteger sizeOfObjCType(const char *ctype)
        {
          GxObjCTypeParser parser;
          void *counter = 0;
          parser.parseType(ctype, &counter);
          return (NSUInteger)counter;
        }

*/

#import <Foundation/Foundation.h>


struct GxObjCTypeParser
  {
    private:
      
    public:
      void (*parse_numeric)(const char *type, void *address, void *info);           // default is error
      void (*parse_void)(void *address, void *info);                                // default is error
      void (*parse_selector)(SEL *address, void *info);                             // default is error
      void (*parse_class)(Class *address, void *info);                              // default is error
      void (*parse_object)(const char *name, id __unsafe_unretained *address, void *info);              // default is error
      void (*parse_string)(char **address, void *info);                             // default is error
      void (*parse_pointer_begin)(void **address, void *info);                      // default is error
      void (*parse_pointer_end)(void **address, void *info);                        // no default
      void (*parse_bitfield)(unsigned char *address, void *info);                   // default is error
      void (*parse_struct_begin)(const char *type, const char *tag, void *info);    // default is error
      void (*parse_struct_delimiter)(void *info);                                   // no default
      void (*parse_struct_end)(const char *type, void *info);                       // no default
      BOOL (*parse_array_begin)(NSUInteger count, void *info);                      // default is error
      void (*parse_array_delimiter)(void *info);                                    // no default
      void (*parse_array_end)(void *info);                                          // no default
      void (*parse_union_begin)(void *info);                                        // default is error
      void (*parse_union_delimiter)(void *info);                                    // no default
      void (*parse_union_end)(void *info);                                          // no default
      void (*parse_element_name)(const char *name, void *info);                     // no default
      void (*parse_const)(void *info);                                              // no default
      void (*parse_unknown)(void *address, void *info);                             // default is error


    private:

      void align(void **address_ptr, NSUInteger alignment);

      const char *scan_string(const char *ctype, char *name);

      const char *scan_tag(const char *ctype, char *tag);

      const char *scan_count(const char *s, NSUInteger *n);

      const char *parseType(const char *ctype, void **address, NSUInteger *alignment, void *info, bool vocal = true);


    public:

      GxObjCTypeParser();

     ~GxObjCTypeParser();


      const char *parseType(const char *ctype, void **address=NULL, id info=nil);
  };
