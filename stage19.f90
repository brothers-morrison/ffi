SUBROUTINE Blep ( foo, bar )
  USE iso_c_binding
  IMPLICIT NONE
  CHARACTER*(*), INTENT(IN) :: foo
  CHARACTER(:), ALLOCATABLE, INTENT(OUT) :: bar

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

  WRITE(0, 1705) foo
1705 FORMAT ('Stage 19: ', A)

  ALLOCATE(CHARACTER(len=LEN(foo)+128) :: cmd)
  WRITE(cmd, 2342) foo, fname
2342 FORMAT ('/home/jaseg/ffi/stage20.sh "', A, '" > ', A)
  CALL EXECUTE_COMMAND_LINE(cmd)

  CALL STAT(fname, stval, stout)
  flen = stval(8)

  ALLOCATE(CHARACTER(len=flen) :: bar)
  OPEN(unit=23, file=fname, action='read', status='old')
  READ(unit=23, fmt="(A)") bar
END SUBROUTINE Blep
