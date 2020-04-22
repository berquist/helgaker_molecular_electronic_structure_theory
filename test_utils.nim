## Stolen from pytest's ApproxScalar.
proc approx*(actual, expected: SomeNumber, allowed_rel_diff: SomeNumber = 1e-6, allowed_abs_diff: SomeNumber = 1e-12): bool =
  # Short-circuit exact equality.
  if actual == expected:
    return true
  if abs(expected) == Inf:
    return false
  # abs(expected - actual) <= tolerance
  let abs_diff = abs(expected - actual)
  result = abs_diff <= allowed_abs_diff
  if not result:
    echo "expected: ", expected
    echo "actual: ", actual
    echo "(allowed) absolute difference: ", allowed_abs_diff
    echo "(actual) absolute difference: ", abs_diff
