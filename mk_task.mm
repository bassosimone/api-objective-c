// Part of Measurement Kit <https://measurement-kit.github.io/>.
// Measurement Kit is free software under the BSD license. See AUTHORS
// and LICENSE for more information on the copying conditions.

#import "mk_task.h"

#include <assert.h>
#include <memory>
#include <string.h>

#import <Foundation/Foundation.h>

#include <measurement_kit/ffi.h>

class TaskDeleter {
public:
  void operator()(mk_task_t *task) {
    mk_task_destroy(task);
  }
};
// Using define because the using syntax is not allowed in ObjectiveC++
#define UTaskP std::unique_ptr<mk_task_t, TaskDeleter>

class EventDeleter {
public:
  void operator()(mk_event_t *event) {
    mk_event_destroy(event);
  }
};
// Ditto
#define UEventP std::unique_ptr<mk_event_t, EventDeleter>

@implementation MKTask{
  UTaskP taskp;
}

+ (MKTask *)start:(NSDictionary *)settings {
  MKTask *task = [[super alloc] init];
  if (task == nil) {
    return nil;
  }
  if (![NSJSONSerialization isValidJSONObject:settings]) {
    NSLog(@"[MKTask init]: passed an invalid object");
    return nil;
  }
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:settings
                  options:0 error:&error];
  if (error != nil) {
    NSLog(@"[MKTask init]: internal error serializing to JSON");
    return nil;
  }
  // Note: manual inspection strongly suggests that the NSData returned by
  // NSJSONSerialization is _not_ terminated by '\0'. That's why here I'm
  // using initWithData rather than just stringWithUTF8String.
  NSString *string = [[NSString alloc] initWithData:data
                      encoding:NSUTF8StringEncoding];
  if (string == nil) {
    NSLog(@"[MKTask init]: cannot obtain C string from serialized JSON");
    return nil;
  }
  task->taskp.reset(mk_task_start([string UTF8String]));
  if (!task->taskp) {
    NSLog(@"[MKTask init]: cannot start task (passed invalid JSON?)");
    return nil;
  }
  return task;
}

- (BOOL)isDone {
  return mk_task_is_done(taskp.get());
}

- (NSDictionary *)waitForNextEvent {
  UEventP eventp(mk_task_wait_for_next_event(taskp.get()));
  if (!eventp) {
    NSLog(@"[MKTask waitForNextEvent]: MK returned a nullptr event");
    return nil;
  }
  const char *str = mk_event_serialize(eventp.get());
  if (str == nullptr) {
    NSLog(@"[MKTask waitForNextEvent]: cannot serialize event");
    return nil;
  }
  NSData *data = [NSData dataWithBytes:(char *)str length:strlen(str)];
  if (data == nullptr) {
    NSLog(@"[MKTask waitForNextEvent]: cannot make NSData from C string");
    return nil;
  }
  NSError *error = nil;
  id object = [NSJSONSerialization JSONObjectWithData:data
               options:0 error:&error];
  if (error != nil) {
    NSLog(@"[MKTask waitForNextEvent]: cannot parse JSON from NSData");
    return nil;
  }
  if([object isKindOfClass:[NSDictionary class]] == NO) {
    NSLog(@"[MKTask waitForNextEvent]: parsed invalid kind of class");
    return nil;
  }
  return (NSDictionary *)object;
}

- (void)interrupt {
  mk_task_interrupt(taskp.get());
}

@end
