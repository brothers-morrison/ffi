#import "Stage14Wrapper.h"
#import "RInside.h"

#import <iostream>

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
    std::cout << "Stage 14: " << rfoo << std::endl;
    stm << "[Stage 14: " << rfoo << "]";
    impl->wrapped.parseEvalQ("source(\"stage15.r\")");
    Rcpp::Function rblep = impl->wrapped["blep"];
    SEXP rrv = rblep(rfoo);
    std::string rv = Rcpp::as<std::string>(rrv);
    std::cout << "Return value [14]: " << rv << std::endl;
    return [NSString stringWithUTF8String:rv.c_str()];
}

@end
