
#import <Foundation/Foundation.h>
#import "Stage14Wrapper.h"

const char *stage13_blep(char * foo)
{
    @autoreleasepool {
        NSString *ofoo = [NSString stringWithUTF8String:foo];
        printf("Stage 13: %s\n", [ofoo UTF8String]);

        Stage14Wrapper *s14 = [[Stage14Wrapper alloc] init];
        NSString *bar = [NSString stringWithFormat:@"[Stage 13: %@]", ofoo];
        [s14 release];

        printf("Return value[13]: %s\n", [bar UTF8String]);
        return [bar UTF8String];
    }
}
