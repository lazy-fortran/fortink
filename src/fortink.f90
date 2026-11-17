module fortink
    use, intrinsic :: iso_c_binding, only: c_float, c_double, c_int
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    implicit none
    private
    public :: ink_state_t, ink_reset, ink_sample, ink_batch

    type :: ink_state_t
        logical :: started = .false.
        real(c_double) :: x = 0, y = 0, t = 0, pressure = 0.5
        real(c_double) :: vx = 0, vy = 0
    end type

    interface
        pure subroutine ink_filter_leaf(x, y, t, p, oldx, oldy, oldt, oldp, &
                width, outx, outy, outp, radius, vx, vy)
            import c_double
            real(c_double), intent(in) :: x, y, t, p, oldx, oldy, oldt, oldp, width
            real(c_double), intent(out) :: outx, outy, outp, radius, vx, vy
        end subroutine
    end interface
contains
    subroutine ink_reset(state)
        type(ink_state_t), intent(out) :: state
        state = ink_state_t()
    end subroutine

    subroutine ink_sample(state, x, y, t, pressure, width, result, endpoint)
        type(ink_state_t), intent(inout) :: state
        real(c_double), intent(in) :: x, y, t, pressure, width
        real(c_double), intent(out) :: result(3)
        logical, intent(in), optional :: endpoint
        real(c_double) :: p, px, py, dt, fp, radius, vx, vy

        result = [state%x, state%y, max(0.01d0, width*0.5d0)]
        if (.not. all(ieee_is_finite([x, y, t, pressure, width]))) return
        if (width <= 0) return
        p = max(0d0, min(1d0, pressure))
        if (.not. state%started) then
            state%started = .true.
            state%x = x
            state%y = y
            state%t = t - 1d0
            state%pressure = p
        end if
        if (t < state%t) return
        call ink_filter_leaf(x, y, t, p, state%x, state%y, state%t, &
            state%pressure, width, px, py, fp, radius, vx, vy)
        if (present(endpoint)) then
            if (endpoint) then
                px = x
                py = y
            end if
        end if
        dt = t - state%t
        if (dt > 0) then
            state%vx = vx
            state%vy = vy
        end if
        state%x = px
        state%y = py
        state%t = t
        state%pressure = fp
        result = [px, py, radius]
    end subroutine

    subroutine ink_batch(state, samples, width, output, endpoint)
        type(ink_state_t), intent(inout) :: state
        real(c_float), intent(in) :: samples(:, :)
        real(c_double), intent(in) :: width
        real(c_float), intent(out) :: output(:, :)
        logical, intent(in), optional :: endpoint
        real(c_double) :: point(3)
        integer :: i, n
        logical :: last
        n = min(size(samples, 2), size(output, 2))
        do i = 1, n
            last = .false.
            if (present(endpoint)) then
                if (i == n) last = endpoint
            end if
            call ink_sample(state, real(samples(1, i), c_double), &
                real(samples(2, i), c_double), real(samples(3, i), c_double), &
                real(samples(4, i), c_double), width, point, last)
            output(:, i) = real(point, c_float)
        end do
    end subroutine
end module
