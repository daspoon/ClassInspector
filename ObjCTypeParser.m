/*

  Created by David Spooner; see License.txt

*/

#import "ObjCTypeParser.h"
#import "utilities.h"


static void error()
  { [NSException raise:NSInvalidArgumentException format:@"Unexpected type code"]; }


GxObjCTypeParser::GxObjCTypeParser()
  {
    parse_numeric          = NULL; //(void (*)(const char *, void *, void *))error;
    parse_void             = NULL; //(void (*)(void *, void *))error;
    parse_selector         = NULL; //(void (*)(SEL *, void *))error;
    parse_class            = NULL; //(void (*)(Class *, void *))error;
    parse_object           = NULL; //(void (*)(const char *, id *, void *))error;
    parse_string           = NULL; //(void (*)(char **, void *))error;
    parse_pointer_begin    = NULL; //(void (*)(void **, void *))error;
    parse_pointer_end      = NULL;
    parse_bitfield         = NULL; //(void (*)(unsigned char *, void *))error;
    parse_struct_begin     = NULL; //(void (*)(const char *, const char *, void *))error;
    parse_struct_delimiter = NULL;
    parse_struct_end       = NULL;
    parse_array_begin      = NULL; //(BOOL (*)(NSUInteger, void *))error;
    parse_array_delimiter  = NULL;
    parse_array_end        = NULL;
    parse_union_begin      = NULL; //(void (*)(void *))error;
    parse_union_delimiter  = NULL;
    parse_union_end        = NULL;
    parse_element_name     = NULL;
    parse_const            = NULL;
    parse_unknown          = NULL; //(void (*)(void *, void *))error;
  }


GxObjCTypeParser::~GxObjCTypeParser()
  {
  }


const char *GxObjCTypeParser::parseType(const char *ctype, void **address, id info)
  {
    NSUInteger alignment;
    void *zero = 0;
    if (address == NULL)
      address = &zero;

    return parseType(ctype, address, &alignment, (__bridge void *)info);
  }


const char *GxObjCTypeParser::parseType(const char *ctype, void **address, NSUInteger *alignment, void *info, bool vocal)
  {
    // parse struct/union element name...
    char name[256];
    ctype = scan_string(ctype, name);

    // parse element...
    switch (*ctype++) {
      case 'v' : // void
        if (vocal && parse_void)
          (*parse_void)(*address, info);
        break;

      case 'c' : case 'C' : case 's' : case 'S' : case 'i' : case 'I' : case 'l' : case 'L' : case 'q' : case 'Q' : case 'f' : case 'd' : case 'B' :
        {
          const char *code = ctype - 1;
          align(address, *alignment = GxAlignmentOfNumericTypeCode(*code));
          if (vocal && parse_numeric)
            (*parse_numeric)(code, *address, info);
          *address = (char *)*address + GxSizeOfNumericTypeCode(*code);
        }
        break;

      case ':' : // SEL
        align(address, *alignment = sizeof(SEL));
        if (vocal && parse_selector)
          (*parse_selector)((SEL *)*address, info);
        *address = (char *)*address + sizeof(SEL);
        break;

      case '#' : // Class
        align(address, *alignment = sizeof(Class));
        if (vocal && parse_class)
          (*parse_class)((Class *)*address, info);
        *address = (char *)*address + sizeof(Class);
        break;

      case '@' : // id
        {
          char classname[256];
          ctype = scan_string(ctype, classname);
          align(address, *alignment = sizeof(id));
          if (vocal && parse_object)
            (*parse_object)(*classname ? classname : 0, (id __unsafe_unretained *)*address, info);
          *address = (char *)*address + sizeof(id);
        }
        break;

      case '*' : // char ** (is the buffer expected to exist on decoding?)
        align(address, *alignment = sizeof(char *));
        if (vocal && parse_string)
          (*parse_string)((char **)*address, info);
        *address = (char *)*address + sizeof(char *);
        break;

      case '^' : // pointer --> '^' <type>
        {
          void *tmp_address = 0;
          NSUInteger tmp_alignment;
          align(address, *alignment = sizeof(void *));
          if (vocal && parse_pointer_begin)
            (*parse_pointer_begin)((void **)*address, info);
          ctype = parseType(ctype, &tmp_address, &tmp_alignment, info);
          if (vocal && parse_pointer_end)
            (*parse_pointer_end)((void **)*address, info);
          *address = (char *)*address + sizeof(void *);
        }
        break;

      case '[' : // array --> '[' <n> <type> ']'
        {
          NSUInteger i, n;
          const char *tmp;
          BOOL iterate = NO;

          *alignment = 1; // initialized in case of zero elements

          if ((tmp = scan_count(ctype, &n)) == 0)
            [NSException raise:NSInvalidArgumentException format:@"invalid objCType \"%s\", expecting number", ctype];

          if (parse_array_begin)
            iterate = (*parse_array_begin)(n, info);

          if (iterate) {
            for (i = 0, ctype = tmp; i < n; ++i) {
              if (i > 0 && vocal && parse_array_delimiter)
                (*parse_array_delimiter)(info);
              ctype = parseType(tmp, address, alignment, info);
            }
          }
          else {
            void *tmp_address = 0;
            ctype = parseType(tmp, &tmp_address, alignment, info, false);
            align(address, *alignment);
            align(&tmp_address, *alignment);
            *address = (char *)*address + n * (NSUInteger)tmp_address;
          }

          if (*ctype++ != ']')
            [NSException raise:NSInvalidArgumentException format:@"invalid objCType \"%s\", expecting ']'", ctype-1];

          if (vocal && parse_array_end)
            (*parse_array_end)(info);
        }
        break;

      case '{' : // struct --> '{' <name> '=' <type> ... '}'
        {
          const char *lbrace = ctype - 1;

          char tag[256];
          ctype = scan_tag(ctype, tag);

          if (vocal && parse_struct_begin)
            (*parse_struct_begin)(lbrace, tag, info);

          *alignment = 1; // initialize in case of empty struct
          for (NSUInteger i = 0; *ctype && *ctype != '}'; ++i) {
            NSUInteger tmp_alignment;
            if (i > 0 && vocal && parse_struct_delimiter)
              (*parse_struct_delimiter)(info);
            ctype = parseType(ctype, address, (i == 0 ? alignment : &tmp_alignment), info);
          }

          const char *rbrace = ctype;
          if (*ctype++ != '}')
            [NSException raise:NSInvalidArgumentException format:@"invalid objCType \"%s\", expecting '}'", rbrace];

          if (vocal && parse_struct_end)
            (*parse_struct_end)(rbrace, info);
        }
        break;

      case '(' : // union --> '(' <name> '=' <type> ... ')'
        {
          void *max_address = *address;
          NSUInteger max_alignment = 1;

// NOTE: the 'tag' should be made an argument to 'parse_union_begin'...
          char tag[256];
          ctype = scan_tag(ctype, tag);

          if (vocal && parse_union_begin)
            (*parse_union_begin)(info);

          for (NSUInteger i = 0; *ctype && *ctype != ')'; ++i) {
            void *tmp_address = *address;
            NSUInteger tmp_alignment = 1;
            if (i > 0 && vocal && parse_union_delimiter)
              (*parse_union_delimiter)(info);
            ctype = parseType(ctype, &tmp_address, &tmp_alignment, info);
            if (tmp_address > max_address)
              max_address = tmp_address;
            if (tmp_alignment > max_alignment)
              max_alignment = tmp_alignment;
          }

          *address = max_address;
          *alignment = max_alignment;

          if (*ctype++ != ')')
            [NSException raise:NSInvalidArgumentException format:@"invalid objCType \"%s\", expecting ')'", ctype-1];

          if (vocal && parse_union_end)
            (*parse_union_end)(info);
        }
        break;

      case 'b' : // bitfield --> 'b' <num>
        {
        // HACK: not sure what to do here since we don't know the size of the item;
        // furthermore, what happens with adjacent bitfields ???
          const char *tmp;
          NSUInteger n;

          if ((tmp = scan_count(ctype, &n)) == 0)
            [NSException raise:NSInvalidArgumentException format:@"invalid objCType \"%s\", expecting number", ctype];

          ctype = tmp;
          if (vocal && parse_bitfield)
            (*parse_bitfield)((unsigned char *)*address, info);
          *address = (char *)*address + (n + 7) / 8;
        }
        break;

      case 'r' : // const --> 'r' <type>
        if (vocal && parse_const)
          (*parse_const)(info);
        parseType(ctype, address, alignment, info);
        break;

      case 'n' : case 'N' : case 'o' : case 'O' : case 'R' : case 'V' :
        // These codes occur within the types of some method signatures.  A 'parse_qualifier' callback
        // should be added ...
        break;

      case '?' :
        {
          if (vocal && parse_unknown)
            (*parse_unknown)(*address, info);
        }
        break;

      default :
        [NSException raise:@"" format:@"unrecognized type code: '%c'", *(ctype-1)];
    }

    // perform name callback...
    if (vocal && parse_element_name && name[0] != 0)
      (*parse_element_name)(name, info);

    return ctype;
  }


void GxObjCTypeParser::align(void **address_ptr, NSUInteger alignment)
  {
    if ((NSUInteger)*address_ptr & (alignment-1))
      *address_ptr = (char *)((NSUInteger)*address_ptr & ~(alignment-1)) + alignment;
  }


const char *GxObjCTypeParser::scan_string(const char *ctype, char *name)
  {
    if (*ctype && *ctype == '\"') {
      NSUInteger i;
      for (i = 0, ++ctype; *ctype && *ctype != '\"'; ++ctype, ++i)
        name[i] = *ctype;
      if (*ctype)
        ++ctype;
      name[i] = 0;
    }
    else
      name[0] = 0;
    return ctype;
  }


const char *GxObjCTypeParser::scan_tag(const char *ctype, char *tag)
  {
    NSUInteger i;
    for (i = 0; *ctype && *ctype != '}' && *ctype != '='; ++ctype, ++i)
      tag[i] = *ctype;
    tag[i] = 0;

    if (*ctype && *ctype == '=')
      ++ctype;

    return ctype;
  }


const char *GxObjCTypeParser::scan_count(const char *s, NSUInteger *n)
  {
    NSUInteger v = 0;
    if (!('0' <= *s && *s <= '9'))
      return NULL;
    for (; '0' <= *s && *s <= '9'; ++s)
      v = v * 10 + (*s - '0');
    *n = v;
    return s;
  }
