// Part of Measurement Kit <https://measurement-kit.github.io/>.
// Measurement Kit is free software under the BSD license. See AUTHORS
// and LICENSE for more information on the copying conditions.

#import "mk_task.h"

#include <assert.h>
#include <string.h>

#import <Foundation/Foundation.h>

#include <measurement_kit/ffi.h>

@implementation MKTask{
  mk_task_t *task;
}

- (BOOL)startInternal:(NSDictionary *)settings {
  if (![NSJSONSerialization isValidJSONObject:settings]) {
    NSLog(@"[MKTask init]: passed an invalid object");
    return NO;
  }
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:settings
                  options:0 error:&error];
  if (error != nil) {
    NSLog(@"[MKTask init]: internal error serializing to JSON");
    return NO;
  }
  // Note: manual inspection strongly suggests that the NSData returned by
  // NSJSONSerialization is _not_ terminated by '\0'. That's why here I'm
  // using initWithData rather than just stringWithUTF8String.
  NSString *string = [[NSString alloc] initWithData:data
                      encoding:NSUTF8StringEncoding];
  if (string == nil) {
    NSLog(@"[MKTask init]: cannot obtain C string from serialized JSON");
    return NO;
  }
  task = mk_task_start([string UTF8String]);
  if (task == nullptr) {
    NSLog(@"[MKTask init]: cannot start task (passed invalid JSON?)");
    return NO;
  }
  return YES;
}

+ (MKTask *)start:(NSDictionary *)settings {
  if ((self = [[super alloc] init]) == nil) {
    return nil;
  }
  // Cast needed because `self` here is not of the correct type
  if ([((MKTask *)self) startInternal:settings] == NO) {
    return nil;
  }
  return self;
}

- (BOOL)isDone {
  return mk_task_is_done(task);
}

- (NSDictionary *)waitForNextEvent {
  NSDictionary *results = nil;
  mk_event_t *evp = nullptr;
  do {
    evp = mk_task_wait_for_next_event(task);
    if (evp == nullptr) {
      NSLog(@"[MKTask waitForNextEvent]: MK returned a nullptr event");
      break;
    }
    const char *str = mk_event_serialize(evp);
    if (str == nullptr) {
      NSLog(@"[MKTask waitForNextEvent]: cannot serialize event");
      break;
    }
    NSData *data = [NSData dataWithBytesNoCopy:(char *)str length:strlen(str)];
    if (data == nullptr) {
      NSLog(@"[MKTask waitForNextEvent]: cannot make NSData from C string");
      break;
    }
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                 options:0 error:&error];
    if (error != nil) {
      NSLog(@"[MKTask waitForNextEvent]: cannot parse JSON from NSData");
      break;
    }
    if([object isKindOfClass:[NSDictionary class]] == NO) {
      NSLog(@"[MKTask waitForNextEvent]: parsed invalid kind of class");
      break;
    }
    results = (NSDictionary *)object;
  } while (0);
  mk_event_destroy(evp); // handles nullptr gracefully
  return results;
}

- (void)interrupt {
  mk_task_interrupt(task);
}

- (void)dealloc {
  mk_task_destroy(task);
  [super dealloc];
}

@end
