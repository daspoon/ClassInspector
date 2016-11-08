/*

  Created by David Spooner; see License.txt

*/

#import "NSWindowController-extras.h"


@implementation NSWindowController(extras)

- (NSToolbarItem *) toolbar:(NSToolbar *)sender itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)flag
  {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"create%c%@ItemForToolbar:", toupper([identifier characterAtIndex:0]), [identifier substringFromIndex:1]]);
    NSToolbarItem *item = (*(id(*)(id,SEL,id))[self methodForSelector:selector])(self, selector, sender);
    NSAssert2(item == nil || [item.itemIdentifier isEqualToString:identifier], @"unexpected item identifier: %@ (expecting %@)", item.itemIdentifier, identifier);
    return item;
  }


- (void) toolbarWillAddItem:(NSNotification *)notification
  {
    NSToolbar   *toolbar = notification.object;
    NSToolbarItem  *item = [notification.userInfo objectForKey:@"item"];
    SEL         selector = NSSelectorFromString([NSString stringWithFormat:@"toolbar:willAdd%@Item:", item.itemIdentifier]);
    if ([self respondsToSelector:selector])
      (*(void(*)(id,SEL,id,id))[self methodForSelector:selector])(self, selector, toolbar, item);
  }


- (void) toolbarDidRemoveItem:(NSNotification *)notification
  {
    NSToolbar   *toolbar = notification.object;
    NSToolbarItem  *item = [notification.userInfo objectForKey:@"item"];
    SEL         selector = NSSelectorFromString([NSString stringWithFormat:@"toolbar:didRemove%@Item:", item.itemIdentifier]);
    if ([self respondsToSelector:selector])
      (*(void(*)(id,SEL,id,id))[self methodForSelector:selector])(self, selector, toolbar, item);
  }

@end
