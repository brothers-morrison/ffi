SUBROUTINE Blep ( foo, bar )
  USE iso_c_binding
  IMPLICIT NONE
  CHARACTER*(*), INTENT(IN)  :: foo
  CHARACTER(:), ALLOCATABLE, INTENT(OUT) :: bar
  ALLOCATE(CHARACTER(len=LEN(foo)+32) :: bar)
  WRITE(bar,2342) foo
2342 FORMAT ('[Stage 19: ', A, ']')
END SUBROUTINE Blep
