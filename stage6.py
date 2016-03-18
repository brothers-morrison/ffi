#!/usr/bin/env python3

from ctypes import *

php = CDLL('./libphp7.so',  mode=RTLD_GLOBAL)
cli = CDLL('./phpcli.so',  mode=RTLD_GLOBAL)

def blep(foo):
	return php_run('stage7.php', foo)

def php_run(fn, foo):
	with open(fn, 'rb') as f:
		lines = f.read()
	amod = POINTER(c_void_p).in_dll(cli, 'cli_sapi_module')[0]
	php.sapi_startup(amod);
	cli.php_cli_startup(amod);
	php.php_request_startup()
	glo = POINTER(zend_executor_globals).in_dll(php, 'executor_globals')
	php.zend_hash_str_update(byref(glo.symbol_table), 'foo', len(foo), foo);
	retval = zval()
	php.zend_eval_string_ex(lines, byref(retval), b'evil things', 0);
	pret = cast(zval.value, zstr).val.decode()
	php.php_request_shutdown(None);
	return pret

class zstr(Structure):
	_fields_ = [('stuff', c_int*4), ('length', c_size_t), ('val', c_char_p)]

class zval(Structure):
	_fields_ = [('value', c_void_p), ('stuff', c_int*2)]

class zend_executor_globals(Structure):
	_fields_ = [('foo', zval), ('bar', zval), ('stuff', c_void_p*3), ('symbol_table', c_void_p)]


if __name__ == '__main__':
	print(blep('test'))
