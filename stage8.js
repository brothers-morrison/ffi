var ffi = require('ffi');
var ref = require('ref');

var helper = LibraryFixed('./libstage8.5.so', {
    'stage8h_blep': ['string', ['string']]
});

module.exports = {
    blep: function (foo) {
        console.log('Stage 8: '+foo);
        var bar = helper.stage8h_blep(foo);
        console.log('Return value[8]: '+bar);
        return bar;
    }
};


function LibraryFixed (libfile, funcs, lib) {
  if (!lib) {
    lib = {}
  }
  var dl = new ffi.DynamicLibrary(libfile || null, ffi.DynamicLibrary.FLAGS.RTLD_GLOBAL | ffi.DynamicLibrary.FLAGS.RTLD_NOW)

  Object.keys(funcs || {}).forEach(function (func) {
    var fptr = dl.get(func)
      , info = funcs[func]

    if (fptr.isNull()) {
      throw new Error('Library: "' + libfile
        + '" returned NULL function pointer for "' + func + '"')
    }

    var resultType = info[0]
      , paramTypes = info[1]
      , fopts = info[2]
      , abi = fopts && fopts.abi
      , async = fopts && fopts.async
      , varargs = fopts && fopts.varargs

    if (varargs) {
      lib[func] = ffi.VariadicForeignFunction(fptr, resultType, paramTypes, abi)
    } else {
      var ff = ffi.ForeignFunction(fptr, resultType, paramTypes, abi)
      lib[func] = async ? ff.async : ff
    }
  })

  return lib
}


if (require.main === module) {
    module.exports.blep("test");
}
