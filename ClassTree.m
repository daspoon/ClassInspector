/*

  Created by David Spooner; see License.txt

*/

#import "ClassTree.h"
#import "IvarNode.h"
#import "MethodNode.h"


@implementation GxClassTree
  {
    NSTreeNode *detailTree;
  }


- (instancetype) initWithRootClass:(Class)aClass
  {
    NSAssert(aClass, @"invalid argument");

    if ((self = [self initWithRepresentedObject:aClass]) == nil)
      return nil;

    // Get the list of registered classes from the runtime
    int n_classes = objc_getClassList(NULL, 0);
    Class *classes = (Class *)malloc(n_classes * sizeof(Class));
    for (int n; (n = objc_getClassList(classes, n_classes)) != n_classes; )
      classes = (Class *)realloc(classes, (n_classes=n) * sizeof(Class));

    // Build a dictionary mapping each class descended from the specified root to a newly create node...
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    mapping[aClass] = self;
    for (int i = 0; i < n_classes; ++i) {
      if (classes[i] != aClass && GxIsDescendantClass(classes[i], aClass))
        mapping[classes[i]] = [[GxClassTree alloc] initWithRepresentedObject:classes[i]];
    }

    // Add each node to the children of the node for the corresponding superclass, if any...
    [mapping enumerateKeysAndObjectsUsingBlock:
        ^(Class cls, GxClassTree *node, BOOL *stop) {
            GxClassTree *parent = mapping[class_getSuperclass(cls)];
            if (parent)
              [parent.mutableChildNodes insertObject:node atIndex:parent.childNodes.count];
        }];

    // Cleanup...
    free(classes);

    return self;
  }


- (instancetype) init
  { return [self initWithRootClass:[NSObject class]]; }


#pragma mark GxClassTree

- (NSString *) name
  { return NSStringFromClass((Class)self.representedObject); }


- (NSTreeNode *) detailTree
  {
    if (detailTree == nil) {
      detailTree = [[NSTreeNode alloc] initWithRepresentedObject:@"Content"];

      NSTreeNode *instanceVariableTree = [[NSTreeNode alloc] initWithRepresentedObject:@"Instance Variables"];
      unsigned int n_ivars;
      Ivar *ivars = class_copyIvarList((Class)self.representedObject, &n_ivars);
      for (unsigned int i = 0; i < n_ivars; ++i)
        [instanceVariableTree.mutableChildNodes insertObject:[[GxIvarNode alloc] initWithIvar:ivars[i]] atIndex:i];
      free(ivars);

      NSTreeNode *instanceMethodTree = [[NSTreeNode alloc] initWithRepresentedObject:@"Instance Methods"];
      unsigned int n_methods;
      Method *methods = class_copyMethodList((Class)self.representedObject, &n_methods);
      for (unsigned int i = 0; i < n_methods; ++i)
        [instanceMethodTree.mutableChildNodes insertObject:[[GxMethodNode alloc] initWithMethod:methods[i] kind:GxMethodKindInstance] atIndex:i];
      free(methods);

      NSTreeNode *classMethodTree = [[NSTreeNode alloc] initWithRepresentedObject:@"Class Methods"];
      methods = class_copyMethodList(object_getClass((Class)self.representedObject), &n_methods);
      for (unsigned int i = 0; i < n_methods; ++i)
        [classMethodTree.mutableChildNodes insertObject:[[GxMethodNode alloc] initWithMethod:methods[i] kind:GxMethodKindClass] atIndex:i];
      free(methods);

      [detailTree.mutableChildNodes addObjectsFromArray:@[
          instanceVariableTree,
          instanceMethodTree,
          classMethodTree,
        ]];
    }

    return detailTree;
  }

@end
