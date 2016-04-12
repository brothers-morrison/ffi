/*
 * invoke like this: env LD_LIBRARY_PATH=.:(find /usr/lib/ghc-* -type d|sed ':a;N;s/\n/:/;ta') ./fromrusttohaskell test
 */
use std::ffi::CString;
use std::ffi::CStr;
use std::os::raw::c_char;
use std::io::Write;
use std::env;
use std::process;

#[link(name="fromrusttohaskell")]
extern {
    fn blep(foo: *mut c_char) -> *const c_char;
    fn hs_init(argc: u64, foo: u64);
    fn hs_exit();
}

fn main() {
    let args = env::args();
    if args.count() != 2 {
        process::exit(2);
    }
    let foo = env::args().nth(1).unwrap();
    unsafe {
        println!("From rust it looks like this: {}", foo);
        
        hs_init(0, 0);
        let bar = CStr::from_ptr(blep(CString::new(foo).unwrap().into_raw())).to_str().unwrap();
        hs_exit();
        
        println!("And back in rust: {}", bar);
    }
}

