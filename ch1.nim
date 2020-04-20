import sequtils
import strformat
from sugar import `=>`

type ON = range[0..1]
type ONVector = seq[ON]

proc numToON(i: SomeInteger): ON {.raises: [ValueError].} =
  if not contains([0, 1], i):
    # TODO string representation of ON
    raise newException(ValueError, &"found value {i} not in range[0..1]")
  int(i)

proc toONVector(it: openArray[SomeInteger]): ONVector {.raises: [ValueError].} =
  it.map(i => i.numToON())

## inner product of two occupation number vectors
proc `*`(left, right: ONVector): ON =
  let delta = zip(left, right).map(proc (t: (ON, ON)): ON =
                                     int(t[0] == t[1]).numToON())
  foldl(delta, a * b, int(1))

when isMainModule:
  let
    vac = @[0, 0, 0, 0].toONVector()
    in1 = @[0, 1, 0, 0].toONVector()
    in2 = @[0, 0, 1, 0].toONVector()
    in12 = @[0, 1, 1, 0].toONVector()
  doAssert vac * vac == 1
  doAssert in1 * in1 == 1
  doAssert in1 * in2 == 0
  doAssert in1 * in12 == 0
