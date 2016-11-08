/*

  Created by David Spooner; see License.txt

  An Adaptor is a proxy which re-routes a specified set of messages into alternately-named messages to a given target object. This is useful when a single object acts as delegate to multiple objects using the same protocol; for example, when a window or view controller acts as delegate for multiple table views.

*/

#import <Foundation/Foundation.h>


@interface GxAdaptor : NSProxy

- (id) initWithTarget:(NSObject *)aTarget selectorMapping:(SEL)original, /*replacement,*/ ... NS_REQUIRES_NIL_TERMINATION;
    // Initialize the receiver to route each of the given original selectors to the corresponding replacement selector on the target object. The original and replacement selectors are specified as a nil-terminated alternating argument list. It is expected that the each method pair has the same signature.

- (id) initWithTarget:(NSObject *)aTarget prefix:(NSString *)aPrefix protocols:(Protocol *)aProtocol, ... NS_REQUIRES_NIL_TERMINATION;
    // Initialize the receiver to route each selector of the given list of protocols to a corresponding selector whose name is obtained by prepending the given prefix.


@property (nonatomic) BOOL allowPassthrough;
    // Specifies whether or not methods not included in the original/replacement mapping supplied on initialization pass through to the underlying target object. The default value is YES.

@end
