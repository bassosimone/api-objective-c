// Part of Measurement Kit <https://measurement-kit.github.io/>.
// Measurement Kit is free software under the BSD license. See AUTHORS
// and LICENSE for more information on the copying conditions.

#import "mk_task.h"

int main() {
  @autoreleasepool {
    NSString *log_level = @"INFO";
    NSDictionary *settings = @{
      @"name" : @"Ndt",
      @"log_level" : log_level,
      @"options" : @{
        @"save_real_probe_asn" : @TRUE,
        @"save_real_probe_cc" : @TRUE,
        @"no_file_report" : @TRUE,
      }
    };
    MKTask *task = [MKTask start:settings];
    while ([task isDone] == NO) {
      NSDictionary *event = [task waitForNextEvent];
      NSLog(@"%@", event);
    }
  }
}
