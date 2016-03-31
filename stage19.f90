SUBROUTINE Blep ( foo, bar )
  USE iso_c_binding
  IMPLICIT NONE
  CHARACTER*(*), INTENT(IN)  :: foo
  CHARACTER, POINTER, INTENT(OUT) :: bar(:)


  INTERFACE
    TYPE(c_ptr) FUNCTION cmmap(addr, len, prot, flags, fildes, off) BIND (c, name='mmap')
      USE iso_c_binding, ONLY: c_int, c_size_t
      IMPORT
      INTEGER(c_int), VALUE :: addr
      INTEGER(c_size_t), VALUE :: len
      INTEGER(c_int), VALUE :: prot
      INTEGER(c_int), VALUE :: flags
      INTEGER(c_int), VALUE :: fildes
      INTEGER(c_size_t), VALUE :: off
    END FUNCTION cmmap
  END INTERFACE 

  INTEGER,PARAMETER :: PROT_READ=1
  INTEGER,PARAMETER :: MAP_PRIVATE=2
  CHARACTER(:), ALLOCATABLE :: cmd

  INTEGER, DIMENSION(13) :: stval
  INTEGER :: stout, fd
  INTEGER(c_size_t) :: flen, offx
  TYPE(c_ptr) :: cptr

  CHARACTER(64) :: fname
  WRITE(fname, 1717) GETPID()
1717 FORMAT ('/tmp/shellout.', I6.6)

  ALLOCATE(CHARACTER(len=LEN(foo)+128) :: cmd)
  WRITE(cmd, 2342), foo, fname
2342 FORMAT ('./stage20.sh "', A, '" > ', A)
  CALL EXECUTE_COMMAND_LINE(cmd)

  CALL STAT(fname, stval, stout)
  flen = stval(8)

  OPEN(unit=23, file=fname, status='old')
  fd = FNUM(unit=23)
  offx = 0
  cptr = cmmap(0, flen, PROT_READ, MAP_PRIVATE, fd, offx)
  CALL c_f_pointer(cptr, bar, [flen])
END SUBROUTINE Blep
