import options
import sequtils
import strformat
import unittest
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

## Apply the creation operator at the given index.
proc create(v: ONVector, index: int): Option[ONVector] =
  case v[index]:
    of 0:
      # TODO needs copy?
      var r = v
      r[index] = 1
      some(r)
    of 1:
      none(ONVector)

## Apply the annihilation operator at the given index.
proc annihilate(v: ONVector, index: int): Option[ONVector] =
  case v[index]:
    of 0:
      none(ONVector)
    of 1:
      # TODO needs copy?
      var r = v
      r[index] = 0
      some(r)

when isMainModule:
  let
    vac = @[0, 0, 0, 0].toONVector()
    in1 = @[0, 1, 0, 0].toONVector()
    in2 = @[0, 0, 1, 0].toONVector()
    in12 = @[0, 1, 1, 0].toONVector()

  suite "ch1":
    test "numToON":
      check: numToON(0) == 0
      check: numToON(1) == 1
    test "innerProduct":
      check: vac * vac == 1
      check: in1 * in1 == 1
      check: in1 * in2 == 0
      check: in1 * in12 == 0
    test "create":
      check: vac.create(0).get() == @[1, 0, 0, 0].toONVector()
      check: vac.create(3).get() == @[0, 0, 0, 1].toONVector()
      check: vac.create(0).get().create(1) == some(@[1, 1, 0, 0].toONVector())
      check: vac.create(0).get().create(0) == none(ONVector)
    test "annihilate":
      check: in1.annihilate(1).get() == vac
      check: in1.annihilate(0) == none(ONVector)
