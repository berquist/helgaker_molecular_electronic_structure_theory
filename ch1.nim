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

type
  ## Was the result of applying an operator successful (producing a new
  ## operator number vector), or did it fail (produce zero)?
  OperatorKind = enum
    opkindSuccess,
    opkindFailure
  OperatorResult = object
    case kind: OperatorKind
    of opkindSuccess:
      res: ONVector
    of opkindFailure:
      discard

## Apply the creation operator at the given index.
proc create(v: ONVector, index: int): OperatorResult =
  case v[index]:
    of 0:
      # TODO needs copy?
      var r = v
      r[index] = 1
      return OperatorResult(kind: opkindSuccess, res: r)
    of 1:
      return OperatorResult(kind: opkindFailure)

## Apply the annihilation operator at the given index.
proc annihilate(v: ONVector, index: int): OperatorResult =
  case v[index]:
    of 0:
      return OperatorResult(kind: opkindFailure)
    of 1:
      # TODO needs copy?
      var r = v
      r[index] = 0
      return OperatorResult(kind: opkindSuccess, res: r)

when isMainModule:
  let
    vac = @[0, 0, 0, 0].toONVector()
    in1 = @[0, 1, 0, 0].toONVector()
    in2 = @[0, 0, 1, 0].toONVector()
    in12 = @[0, 1, 1, 0].toONVector()
  echo vac.create(0)
  echo vac.annihilate(0)
  echo in12.create(1)
  echo in12.annihilate(1)

  suite "ch1":
    test "numToON":
      check: numToON(0) == 0
      check: numToON(1) == 1
    test "innerProduct":
      check: vac * vac == 1
      check: in1 * in1 == 1
      check: in1 * in2 == 0
      check: in1 * in12 == 0
    # test "create":
    #   check: vac.create(0) == OperatorResult(kind: opkindSuccess, res: @[1, 0, 0, 0].toONVector())
    #   check: vac.create(3) == OperatorResult(kind: opkindSuccess, res: @[0, 0, 0, 1].toONVector())
