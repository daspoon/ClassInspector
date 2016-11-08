/*

  Created by David Spooner; see License.txt

*/

#import "AppDelegate.h"
#import "ClassInspector.h"


@implementation ClassInspectorAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)notification
  {
    GxClassInspector *inspector = [[GxClassInspector alloc] init];
    [inspector showWindow:nil];
  }

@end
