#!/usr/bin/env python3

from ctypes import *

def blep_11(foo):
	print('Calling stage 11:', foo)
	stage11 = CDLL('./libstage11.so')
	stage11.blep.restype = c_char_p
	return stage11.blep(b'test').decode()

def blep_12(foo):
	print('Calling stage 12:', foo)
	stage12 = CDLL('./libstage12.so')
	stage12.stage12_blep.restype = c_char_p
	return stage12.stage12_blep(b'test').decode()

def blep_13(foo):
	print('Calling stage 13:', foo)
	stage13 = CDLL('./libstage13.so')
	stage13.stage13_blep.restype = c_char_p
	return stage13.stage13_blep(b'test').decode()

if __name__ == '__main__':
	print('Overall return value:', blep_13('test'))
