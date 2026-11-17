module fortink_web
    use, intrinsic :: iso_c_binding, only: c_float, c_int, c_ptr, c_loc, c_double
    use fortink, only: ink_state_t, ink_reset, ink_batch
    implicit none
    private
    public :: fi_input, fi_output, fi_reset, fi_process
    real(c_float), target, save :: samples(4,2048), modeled(3,2048)
    type(ink_state_t), save :: state
contains
    type(c_ptr) function fi_input() bind(C)
        fi_input = c_loc(samples)
    end function
    type(c_ptr) function fi_output() bind(C)
        fi_output = c_loc(modeled)
    end function
    subroutine fi_reset() bind(C)
        call ink_reset(state)
    end subroutine
    subroutine fi_process(n,width) bind(C)
        integer(c_int), value :: n
        real(c_float), value :: width
        if (n<1 .or. n>2048) return
        call ink_batch(state,samples(:,1:n),real(width,c_double),modeled(:,1:n))
    end subroutine
end module
