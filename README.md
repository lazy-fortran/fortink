# FortInk

Pressure-sensitive digital ink in Fortran, with a matching JavaScript model for
browser comparisons. [Source](https://github.com/lazy-fortran/fortink).

The model filters position and pressure, increases position response with speed,
keeps stationary dots stable, and snaps the released endpoint to measured input.
It accepts measured samples in millimetres, seconds since stroke start, and
pressure from zero to one. Predicted positions belong to a separate preview.

A Fortran compiler and [fpm](https://fpm.fortran-lang.org) or
[fo](https://github.com/lazy-fortran/fo) are required. Run `fpm test` or `fo test`.

`ink_sample` processes one sample. `ink_batch` processes a column-major array
with rows `[x, y, time, pressure]` and returns `[x, y, radius]`. State uses double
precision. Stored samples and the browser interface use single precision.
The C-compatible browser interface accepts at most 2048 samples per call.

The generated numerical leaf comes from symbolic expressions in
`gen/generate.f90`. Its generator depends on [FortSym](https://github.com/lazy-fortran/fortsym)
and its [FortGen](https://github.com/lazy-fortran/fortgen) code emitter.
The generator's fpm manifest fetches a pinned FortSym revision and its
dependencies. Alternatively, set `FORTSYM_PREFIX` to an existing installation
containing `include` and `lib` directories.

```sh
tools/regenerate.sh --check
```

The browser uses LFortran and Emscripten through
[FortShell](https://github.com/lazy-fortran/fortshell). That application compares
Fortran WebAssembly with the same JavaScript model and several renderers.
This filter is an initial implementation. Pencil-to-display latency and parity
with commercial notebook applications need physical-device measurements.
