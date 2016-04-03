
use std::ffi::CString;
use std::ffi::CStr;
use std::os::raw::c_char;
use std::io::Write;

#[link(name="stage24")]
extern {
    fn stage24_blep(foo: *mut c_char) -> *const c_char;
}

#[no_mangle]
pub extern "C" fn blep(ifoo: *mut c_char) -> *const c_char {
    unsafe {
        let foo = CStr::from_ptr(ifoo).to_str().unwrap();
        writeln!(&mut std::io::stderr(), "Stage 23: {}", foo).expect("fred");

        let bar = CStr::from_ptr(stage24_blep(CString::new(foo).unwrap().into_raw())).to_str().unwrap();
        
        writeln!(&mut std::io::stderr(), "Return value [23]: {}", bar).expect("fred");
        return CString::new(bar).unwrap().into_raw();
    }
}

