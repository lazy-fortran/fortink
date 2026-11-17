program generate
    use fortsym_arena, only: arena_t
    use fortsym_expr, only: expr_t
    use fortsym_parse, only: parse_expr
    use fortsym_string, only: str, chars
    use fortsym_kernel, only: kernel_spec_t, emit_kernel
    implicit none
    type(arena_t), target :: arena
    type(expr_t) :: roots(6)
    type(kernel_spec_t) :: spec
    character(:), allocatable :: message, dt, alpha, beta, px, py, pp
    logical :: ok
    integer :: i

    call arena%init()
    dt = 'max(0.001,t-oldt)'
    alpha = '('//dt//'/('//dt//'+0.003/(1+sqrt((x-oldx)**2+(y-oldy)**2)/('//dt//'*40))))'
    beta = '('//dt//'/('//dt//'+0.008))'
    px = '(oldx+'//alpha//'*(x-oldx))'
    py = '(oldy+'//alpha//'*(y-oldy))'
    pp = '(oldp+'//beta//'*(p-oldp))'
    roots(1) = parse_expr(arena, px, ok, message)
    if (.not. ok) error stop message
    roots(2) = parse_expr(arena, py, ok, message)
    if (.not. ok) error stop message
    roots(3) = parse_expr(arena, pp, ok, message)
    if (.not. ok) error stop message
    roots(4) = parse_expr(arena, 'width*(0.18+0.82*'//pp//')/2', ok, message)
    if (.not. ok) error stop message
    roots(5) = parse_expr(arena, '('//px//'-oldx)/'//dt, ok, message)
    if (.not. ok) error stop message
    roots(6) = parse_expr(arena, '('//py//'-oldy)/'//dt, ok, message)
    if (.not. ok) error stop message
    spec%name = str('ink_filter_leaf')
    spec%generator = str('FortInk gen/generate.f90 through FortSym and FortGen')
    spec%regenerate_command = str('tools/regenerate.sh')
    allocate(spec%args(9), spec%outputs(6))
    block
        character(len=5), parameter :: args(*) = &
            [character(len=5) :: 'x','y','t','p','oldx','oldy','oldt','oldp','width']
        character(len=6), parameter :: outputs(*) = &
            [character(len=6) :: 'outx','outy','outp','radius','vx','vy']
        do i = 1, 9
            spec%args(i) = str(trim(args(i)))
        end do
        do i = 1, 6
            spec%outputs(i) = str(trim(outputs(i)))
        end do
    end block
    write(*,'(a)',advance='no') chars(emit_kernel(roots, spec))
end program
