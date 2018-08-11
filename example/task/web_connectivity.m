// Part of Measurement Kit <https://measurement-kit.github.io/>.
// Measurement Kit is free software under the BSD license. See AUTHORS
// and LICENSE for more information on the copying conditions.

#import "mk_task.h"

int main() {
  @autoreleasepool {
    NSString *log_level = @"INFO";
    NSDictionary *settings = @{
      @"name" : @"WebConnectivity",
      @"log_level" : log_level,
      @"options" : @{
        @"save_real_probe_asn" : @TRUE,
        @"save_real_probe_cc" : @TRUE,
        @"no_file_report" : @TRUE,
      },
      @"inputs" : @[
        @"https://www.kernel.org/",
	@"https://www.x.org/",
	@"https://slashdot.org/"
      ]
    };
    MKTask *task = [MKTask start:settings];
    while ([task isDone] == NO) {
      NSDictionary *event = [task waitForNextEvent];
      NSLog(@"%@", event);
    }
  }
}
