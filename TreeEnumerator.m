/*

  Created by David Spooner; see License.txt

*/

#import "TreeEnumerator.h"


typedef struct {
        id __unsafe_unretained node;
        NSInteger  index;
  } GxTreeEnumeratorStack;


@implementation GxTreeEnumerator
  {
    id                     _tree;
    GxTreeStep           (^_enter)(id);
    void                 (^_exit)(id);
    GxTreeEnumeratorStack *_stack;
    NSUInteger             _capacity;
    NSInteger              _sp;
  }


- (instancetype) initWithTree:(id<GxTree>)aTree enterBlock:(GxTreeStep(^)(id))enterBlock exitBlock:(void(^)(id))exitBlock
  {
    NSAssert(aTree, @"invalid argument");

    _tree     = aTree;
    _enter    = [enterBlock copy];
    _exit     = [exitBlock copy];
    _capacity = 12;
    _stack    = (GxTreeEnumeratorStack *)malloc(_capacity * sizeof(GxTreeEnumeratorStack));

    [self reset];

    return self;
  }


- (instancetype) initWithTree:(id<GxTree>)tree enterBlock:(GxTreeStep(^)(id))enterBlock
  {
    return [self initWithTree:tree enterBlock:enterBlock exitBlock:nil];
  }


- (instancetype) initWithTree:(id<GxTree>)aTree predicate:(NSPredicate *)predicate
  {
    GxTreeStep (^block)(id) = nil;
    if (predicate)
      block = ^GxTreeStep(id node) {
          return [predicate evaluateWithObject:node] ? GxTreeStep_Continue : GxTreeStep_Skip;
        };

    return [self initWithTree:aTree enterBlock:block exitBlock:nil];
  }


- (instancetype) initWithTree:(id<GxTree>)aTree
  {
    return [self initWithTree:aTree enterBlock:nil exitBlock:nil];
  }


- (instancetype) init
  {
    NSAssert(0, @"not permitted");

    return nil;
  }


- (void) dealloc
  {
    if (_stack != NULL)
      free(_stack);
  }


- (void) reset
  {
    _stack[0].node  = _tree;
    _stack[0].index = -1;
    _sp = 0;
  }


- (void) perform
  {
    while ([self nextObject]);
  }


#pragma mark NSEnumerator

- (id) nextObject
  {
    while (_sp >= 0) {
      GxTreeEnumeratorStack *top = &_stack[_sp];

      // If the top node has not been visited then invoke the enter method; return that node if the enter method does not say otherwise.
      if (top->index < 0) {
        top->index = 0;
        if (_enter) {
          switch (_enter(top->node)) {
            case GxTreeStep_Continue :
              break;
            case GxTreeStep_Skip :
              // Skip this node and its descendants
              _sp --;
              continue;
            case GxTreeStep_Exit :
              // Abort the traversal
              _sp = -1;
              continue;
          }
        }
        return top->node;
      }

      // If the top node has unprocessed children then push the next in line; otherwise invoke the exit method and pop the stack.
      if (top->index < [top->node countOfSubNodes]) {
        id child = [top->node objectInSubNodesAtIndex:top->index++];
        if (_capacity <= _sp + 1)
          _stack = (GxTreeEnumeratorStack *)realloc(_stack, _capacity *= 2);
        _stack[++_sp] = (GxTreeEnumeratorStack){child, -1};
      }
      else {
        if (_exit)
          _exit(top->node);
        _sp --;
      }
    }

    return nil;
  }

@end
