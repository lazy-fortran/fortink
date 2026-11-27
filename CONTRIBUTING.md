# Contributions

Open a pull request on GitHub. It lands through the merge queue as one squashed
commit once its tests pass. Keep the native Fortran tests authoritative.
Numerical changes need an independent behavioural test and a comparison with the
JavaScript implementation. Regenerate the leaf from its symbolic source. Do not
edit generated expressions directly.

Generate test inputs at runtime. Keep binary fixtures and build outputs out of
Git. Use a resident `fo gremlin` development session for Fortran changes.
