// Part of Measurement Kit <https://measurement-kit.github.io/>.
// Measurement Kit is free software under the BSD license. See AUTHORS
// and LICENSE for more information on the copying conditions.

/// \file mk_task.h
///
/// \brief Measurement Kit (MK) low-level Objective C API. Everything that MK
/// can do is a task. While a task is running it emit events. When starting
/// a task, you provide it with JSON settings. When running a task emits events
/// which are also JSONs. In this implementation, we serialize and unserialize
/// such JSONs using NSDictionary. Please see [MK's API documentation](
///   https://github.com/measurement-kit/measurement-kit/tree/master/include/measurement_kit
/// ) for further details concerning the expected format of such JSONs.

#import <Foundation/Foundation.h>

/// A task that you can run using Measurement Kit.
@interface MKTask : NSObject {}

/// Starts a task with specific @p settings. The task will run until completion
/// unless it's interrupted. Tasks run in FIFO order and only a single task is
/// allowed to run at any given time. @returns a valid pointer if the task has
/// been started successfully, nil in case of errors.
+ (MKTask *)start:(NSDictionary *)settings;

/// Returns YES if the task is done, NO otherwise.
- (BOOL)isDone;

/// Blocks until the task emits the next event. @return a valid pointer to
/// a dictionary containing the event that occurred, unless there is a failure
/// that causes `nil` to be returned instead.
- (NSDictionary *)waitForNextEvent;

/// Interrupts a running task. If a taks is not running, does nothing.
- (void)interrupt;

/// Deallocates a task.
- (void)dealloc;

@end
