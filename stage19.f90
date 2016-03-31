INTERFACE
  USE iso_c_binding
  TYPE(c_ptr) FUNCTION mmap(addr,len,prot,flags,fildes,off)
  BIND(c,name='mmap')
  INTEGER(c_int), VALUE :: addr
  INTEGER(c_size_t), VALUE :: len
  INTEGER(c_int), VALUE :: prot
  INTEGER(c_int), VALUE :: flags
  INTEGER(c_int), VALUE :: fildes
  INTEGER(c_size_t), VALUE :: off
  END FUNCTION mmap
END INTERFACE 

TYPE(c_ptr) :: cptr
INTEGER(c_size_t) :: len, off
INTEGER,PARAMETER :: PROT_READ=1
INTEGER,PARAMETER :: MAP_PRIVATE=2
INTEGER :: fd
REAL*4, POINTER :: x(:) 

SUBROUTINE Blep ( foo, bar )
  USE iso_c_binding
  IMPLICIT NONE
  CHARACTER*(*), INTENT(IN)  :: foo
  CHARACTER(:), INTENT(OUT) :: bar

  INTEGER, DIMENSION(13) :: stval
  INTEGER :: stout

  CHARACTER(64) :: fname
  WRITE(fname, 1717) GETPID()
1717 FORMAT ('/tmp/shellout.', I6)

  CALL STAT(fname, stval, stout)
  flen = stval(8)

  OPEN(unit=23, file=fname, status='old')
  cptr = mmap(0, flen, PROT_READ, MAP_PRIVATE, FNUM(unit=23), 0)
  CALL c_f_pointer(cptr, bar, [flen])

  ALLOCATE(CHARACTER(len=LEN(foo)+32) :: bar)
END SUBROUTINE Blep
