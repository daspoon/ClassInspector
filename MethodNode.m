/*

  Created by David Spooner; see License.txt

*/

#import "MethodNode.h"
#import "ObjCTypeFormatter.h"
#import "NSMutableAttributedString-ClassInspector.h"


@implementation GxMethodNode
  {
    Method method;
    GxMethodKind kind;
  }

static GxObjCTypeFormatter *typeFormatter = nil;
static NSDictionary *typeAttributes = nil;
static NSDictionary *nameAttributes = nil;


+ (void) initialize
  {
    typeFormatter  = [[GxObjCTypeFormatter alloc] init];
    typeAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor lightGrayColor], NSForegroundColorAttributeName, nil];
    nameAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, nil];
  }

  
- (instancetype) initWithMethod:(Method)aMethod kind:(GxMethodKind)aKind
  {
    if ((self = [super initWithRepresentedObject:nil]) == nil)
      return nil;
    method = aMethod;
    kind = aKind;
    return self;
  }


- (id) initWithRepresentedObject:(id)object
  {
    NSAssert(0, @"not permitted");
    return nil;
  }


- (NSAttributedString *) attributedDescription
  {
    // Get the method name and signature encoding string.  Note that the signature encoding consists
    // of a sequence pairs of type encoding and alignment info corresponding to the return value and
    // each of the arguments...
    const char *name = sel_getName(method_getName(method));
    const char *signature = method_getTypeEncoding(method);

    // Create the initially empty description...
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];

    // Append the method kind indicator
    [string appendString:(kind == GxMethodKindInstance ? @"-" : @"+") withAttributes:typeAttributes];

    // Append the description of the method return type...
    [string appendString:[NSString stringWithFormat:@" (%@)", [typeFormatter stringForObjCTypeRef:&signature]] withAttributes:typeAttributes];

    // Advance the pointer into the signature encoding past the return value alignment and then past 
    // the type and alignment for the 'self' and '_cmd' arguments...
    for (; isdigit(*signature); ++signature);
    for (++signature; isdigit(*signature); ++signature); // note: type is '@'
    for (++signature; isdigit(*signature); ++signature); // note: type is ':'

    // If the method has arguments then append a pairing of each ':'-separated portion of the method name
    // with the description of corresponding argument type description...
    const char *colon = strchr(name, ':');
    if (colon)
      for (; colon != NULL; name = colon + 1, colon = strchr(name, ':')) {
        // Append the portion of the method name and the corresponding argument type description
        NSUInteger length = colon - name + 1;
        [string appendString:[NSString stringWithFormat:@" %*.*s", (int)length, (int)length, name] withAttributes:nameAttributes];
        [string appendString:[NSString stringWithFormat:@"(%@)", [typeFormatter stringForObjCTypeRef:&signature]] withAttributes:typeAttributes];
        // Advance the signature encoding pointer
        for (++signature; isdigit(*signature); ++signature);
      }
    // Otherwise append the whole method name.
    else
      [string appendString:[NSString stringWithFormat:@" %s", name] withAttributes:nameAttributes];

    return string;
  }


@end
