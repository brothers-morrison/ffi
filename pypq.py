#!/usr/bin/env python2

from ctypes import *
import threading

pg = CDLL('./libpostgres.so')
pq = CDLL('/usr/local/pgsql/lib/libpq.so')

def make_args(*args):                                                                                                                                     
	argt = c_char_p * len(args)                                                                                                                              
	return len(args), argt(*[c_char_p(arg) for arg in args])

t = threading.Thread(target=lambda: pg.main(*make_args('/usr/local/pgsql/bin/postgres', '-D', '/tmp/testdb')))
t.daemon = True
t.start()

pq.PQconnectdb.restype	= c_void_p
pq.PQexec.restype		= c_void_p
pq.PQfname.restype		= c_char_p
pq.PQgetvalue.restype	= c_char_p

class Connection(object):
	def __init__(self):
		self.conn = pq.PQconnectdb(b'dbname = jaseg')
		assert pq.PQstatus(self.conn) == 0 # CONNECTION_OK

	def exec_tuples(self, cmd):
		res = pq.PQexec(self.conn, cmd)
		assert pq.PQresultStatus(res) == 2 # PGRES_TUPLES_OK
		nf = pq.PQnfields(res)
		nt = pq.PQntuples(res)
		fields = tuple( pq.PQfname(res, i) for i in range(nf) )
		tuples = [ tuple( pq.PQgetvalue(res, tn, fn) for fn in range(nf) ) for tn in range(nt) ]
		pq.PQclear(res)
		return fields, tuples

