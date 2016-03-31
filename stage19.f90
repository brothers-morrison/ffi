SUBROUTINE Blep ( foo, bar )
  USE iso_c_binding
  IMPLICIT NONE
  CHARACTER(len=64), INTENT(IN)  :: foo
  CHARACTER(len=96), INTENT(OUT) :: bar
  WRITE(bar,2342) foo
2342 FORMAT ('[Stage 19: ', A, ']')
END SUBROUTINE Blep
