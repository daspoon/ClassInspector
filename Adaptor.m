/*

  Created by David Spooner; see License.txt

*/

#import "Adaptor.h"
#import <objc/runtime.h>


static unsigned int cstring_count_char(const char *s, char c)
  {
    assert(s != NULL);
    unsigned int k = 0;
    for (; *s != 0; ++s)
      if (*s == c) ++k;
    return k;
  }


static Boolean cstring_equal(const void *s1, const void *s2)
  {
    assert(s1 != NULL && s2 != NULL);
    return strcmp((const char *)s1, (const char *)s2) == 0 ? true : false;
  }


@implementation GxAdaptor
  {
    NSObject *target;
    CFMutableDictionaryRef mapping;
  }


- (id) initWithTarget:(NSObject *)aTarget originalSelectors:(const SEL *)originals replacementSelectors:(const SEL *)replacements count:(NSUInteger)count
  {
    NSAssert(aTarget != nil && originals != NULL && replacements != NULL, @"invalid arguments");

    target = aTarget;

    CFDictionaryKeyCallBacks keyCallBacks = {0, NULL, NULL, NULL, cstring_equal, NULL};
    CFDictionaryValueCallBacks valueCallBacks = {0, NULL, NULL, NULL, cstring_equal};
    mapping = CFDictionaryCreateMutable(NULL, count, &keyCallBacks, &valueCallBacks);

    _allowPassthrough = YES;

    // Add each of the selector pairs to the mapping
    for (NSUInteger i = 0; i < count; ++i) {
      NSAssert(cstring_count_char(sel_getName(originals[i]), ':') == cstring_count_char(sel_getName(replacements[i]), ':'), @"argument count mismatch");
      NSAssert([target respondsToSelector:replacements[i]], @"unrecognized selector");
      CFDictionaryAddValue(mapping, originals[i], replacements[i]);
    }

    return self;
  }


- (id) initWithTarget:(NSObject *)aTarget selectorMapping:(SEL)original, /*replacement,*/ ...
  {
    NSMutableData *originals = [NSMutableData data], *replacements = [NSMutableData data];
    NSUInteger count = 0;

    va_list ap;
    va_start(ap, original);
    for (; original != nil; original = va_arg(ap, SEL), ++count) {
      SEL replacement = va_arg(ap, SEL);
      NSAssert(replacement != NULL, @"missing argument");
      [originals appendBytes:&original length:sizeof(SEL)];
      [replacements appendBytes:&replacement length:sizeof(SEL)];
    }
    va_end(ap);

    return [self initWithTarget:aTarget originalSelectors:(SEL *)[originals bytes] replacementSelectors:(SEL *)[replacements bytes] count:count];
  }


- (id) initWithTarget:(NSObject *)aTarget prefix:(NSString *)aPrefix protocols:(Protocol *)protocol, ...
  {
    NSAssert(aPrefix != nil, @"invalid arguments");

    NSMutableData *originals = [NSMutableData data], *replacements = [NSMutableData data];
    NSUInteger count = 0;

    // Allocate space for the selector name used repeatedly before, and copy in the bytes of the given prefix string.
    char replacement_name[1024];
    [aPrefix getCString:replacement_name maxLength:sizeof(replacement_name) encoding:NSUTF8StringEncoding];

    // Maintain a pointer to the end of the prefix within the name buffer.
    char *ptr = replacement_name + strlen(replacement_name);

    // Iterate through the instance selectors of the protocol (both required and optional) making note
    // of each selector and its calculated replacement.
    // NOTE: this should be extended to also traverse the base protocols recursively...
    va_list ap;
    va_start(ap, protocol);
    for (; protocol != nil; protocol = va_arg(ap, Protocol*))
      for (unsigned int required = 0; required <= 1; ++required) {
        unsigned int n_methods;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, required?YES:NO, YES, &n_methods);
        if (methods != NULL) {
          for (unsigned int i = 0; i < n_methods; ++i) {
            strcpy(ptr, sel_getName(methods[i].name));
            SEL replacement = sel_getUid(replacement_name);
            if (required || [aTarget respondsToSelector:replacement]) {
              [originals appendBytes:&methods[i].name length:sizeof(SEL)];
              [replacements appendBytes:&replacement length:sizeof(SEL)];
              ++count;
            }
          }
          free(methods);
        }
      }
    va_end(ap);

    return [self initWithTarget:aTarget originalSelectors:(SEL *)[originals bytes] replacementSelectors:(SEL *)[replacements bytes] count:count];
  }


- (id) init
  {
    NSAssert(0, @"not permitted");
    return nil;
  }


- (void) dealloc
  {
    if (mapping != NULL)
      CFRelease(mapping);
  }


#pragma mark NSProxy

- (BOOL) respondsToSelector:(SEL)original
  {
    SEL replacement = (SEL)CFDictionaryGetValue(mapping, original);

    if (replacement != NULL)
      return YES;

    if (_allowPassthrough)
      return [target respondsToSelector:original];

    return NO;
  }


- (NSMethodSignature *) methodSignatureForSelector:(SEL)original
  {
    SEL replacement = (SEL)CFDictionaryGetValue(mapping, original);

    if (replacement != NULL)
      return [target methodSignatureForSelector:replacement];

    if (_allowPassthrough)
      return [target methodSignatureForSelector:original];

    return [super methodSignatureForSelector:original];
  }


- (void) forwardInvocation:(NSInvocation *)invocation
  {
    SEL replacement = (SEL)CFDictionaryGetValue(mapping, invocation.selector);

    if (replacement != NULL || _allowPassthrough) {
      if (replacement != NULL)
        [invocation setSelector:replacement];
      [invocation invokeWithTarget:target];
    }
    else
      [super forwardInvocation:invocation];
  }

@end
