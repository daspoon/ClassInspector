/*

  Created by David Spooner; see License.txt

*/

#import "IvarNode.h"
#import "ObjCTypeFormatter.h"
#import "NSMutableAttributedString-ClassInspector.h"


@implementation GxIvarNode
  {
    Ivar ivar;
  }


static GxObjCTypeFormatter *typeFormatter = nil;
static NSDictionary *typeAttributes = nil;
static NSDictionary *nameAttributes = nil;


+ (void) initialize
  {
    [super initialize];

    typeFormatter  = [[GxObjCTypeFormatter alloc] init];
    typeAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor lightGrayColor], NSForegroundColorAttributeName, nil];
    nameAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, nil];
  }

  
- (id) initWithIvar:(Ivar)anIvar
  {
    if ((self = [super initWithRepresentedObject:nil]) == nil)
      return nil;
    ivar = anIvar;
    return self;
  }


- (id) initWithRepresentedObject:(id)object
  {
    NSAssert(0, @"not permitted");
    return nil;
  }


- (NSAttributedString *) attributedDescription
  {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    [string appendString:[typeFormatter stringForObjCType:ivar_getTypeEncoding(ivar)] withAttributes:typeAttributes];
    [string appendString:[NSString stringWithFormat:@" %s", ivar_getName(ivar)] withAttributes:nameAttributes];
    return string;
  }

@end
