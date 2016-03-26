#import "Stage14Wrapper.h"
#import "RInside.h"

struct Stage14WrapperImpl {
    RInside wrapped;
};

@implementation Stage14Wrapper

- (id)init {
    self = [super init];
    if (self) {
        impl = new Stage14WrapperImpl;
    }
    return self;
}

- (void)dealloc {
    delete impl;
    [super dealloc];
}

- (NSString*)blep:(NSString*)foo {
    std::string rfoo([foo UTF8String], [foo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    std::ostringstream stm;
    stm << "[Stage 13: ";
    stm << rfoo;
    stm << "]";
//    Rcpp::Function rblep = impl->wrapped["blep"];
//    SEXP rrv = rblep(rfoo);
//    return [NSString stringWithUTF8String:Rcpp::as<std::string>(rrv).c_str()];
    return [NSString stringWithUTF8String:stm.str().c_str()];
}

@end
