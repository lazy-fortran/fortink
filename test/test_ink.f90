program test_ink
    use, intrinsic :: iso_c_binding, only: c_double
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use fortink, only: ink_state_t, ink_reset, ink_sample
    implicit none
    type(ink_state_t) :: state
    real(c_double) :: result(3), previous(3)
    integer :: i

    call ink_reset(state)
    call ink_sample(state, 10d0, 20d0, 0d0, 0.5d0, 1d0, result)
    if (maxval(abs(result(1:2)-[10d0,20d0])) > 1d-12) error stop 'first point'
    do i = 1, 500
        call ink_sample(state, 10d0, 20d0, i/240d0, 0.5d0, 1d0, result)
    end do
    if (abs(result(3)-0.295d0) > 1d-12) error stop 'stationary pressure'
    if (maxval(abs(result(1:2)-[10d0,20d0])) > 1d-12) error stop 'stationary drift'
    previous = result
    call ink_sample(state, 99d0, 99d0, -1d0, 1d0, 1d0, result)
    if (state%x /= previous(1)) error stop 'out of order sample'
    call ink_sample(state, 30d0, 40d0, 3d0, 1d0, 1d0, result, .true.)
    if (any(result(1:2) /= [30d0,40d0])) error stop 'endpoint'
    if (.not. all(ieee_is_finite(result))) error stop 'finite output'
    call ink_reset(state)
    do i = 0, 240
        call ink_sample(state, real(i,c_double), 0d0, i/240d0, 1d0, 1d0, result)
        if (result(1) > i) error stop 'overshoot'
        if (i-result(1) > 1d0) error stop 'excessive lag'
        if (result(3) <= 0 .or. result(3) > 0.5d0) error stop 'radius bounds'
    end do
end program
