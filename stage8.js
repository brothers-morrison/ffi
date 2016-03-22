var ffi = require('ffi');
var ref = require('ref');

var helper = ffi.Library('./libstage8.5', {
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


if (require.main === module) {
    module.exports.blep("test");
}
