/*

  Created by David Spooner; see License.txt

  An Adaptor is a simple form of proxy which translates a specified set of messages into alternate messages for a specified target object. This is useful when a single object acts as delegate to multiple objects using the same protocol (e.g. NSTableViewDelegate).

*/

#import <Foundation/Foundation.h>


@interface GxAdaptor : NSProxy

- (id) initWithTarget:(NSObject *)aTarget selectorMapping:(SEL)original, /*replacement,*/ ... NS_REQUIRES_NIL_TERMINATION;
    // Initialize the receiver to translate the sets of original and replacement selectors (specified in the nil-terminated list) for the given target object. It is expected that the each pair of corresponding methods has the same signature.

- (id) initWithTarget:(NSObject *)aTarget prefix:(NSString *)aPrefix protocols:(Protocol *)aProtocol, ... NS_REQUIRES_NIL_TERMINATION;
    // Initialize the receiver to translate all instance selectors of the specified list of protocols into equivalent.


@property (nonatomic) BOOL allowPassthrough;
    // Specifies whether or not methods not included in the original/replacement mapping supplied on initialization pass through to the underlying target object. The default value is YES.

@end
