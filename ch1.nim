import options
import sequtils
import strformat
import unittest
from sugar import `=>`

type
  ## An occupation number is 1 if the spin orbital at that position is present
  ## in a determinant and zero otherwise.
  ON = range[0..1]
  ONSeq = seq[ON]
  Phase = enum
    pos, neg
  ## An occupation number vector is how we represent a Slater determinant in
  ## Fock space.
  ONVector = object
    vec: ONSeq
    phase: Phase

proc `*`(p1, p2: Phase): Phase =
  if p1 == p2:
    return Phase.pos
  else:
    return Phase.neg

proc numToON(i: SomeInteger): ON {.raises: [ValueError].} =
  if not contains([0, 1], i):
    # TODO string representation of ON
    raise newException(ValueError, &"found value {i} not in range[0..1]")
  int(i)

proc toONSeq(it: openArray[SomeInteger]): ONSeq {.raises: [ValueError].} =
  it.map(i => i.numToON())

proc toONVector(it: openArray[SomeInteger]): ONVector {.raises: [ValueError].} =
  ONVector(vec: it.toONSeq())

## Inner product of two occupation number vectors, eq. (1.1.3)
proc `*`(left, right: ONVector): ON =
  let delta = zip(left.vec, right.vec).map(proc (t: (ON, ON)): ON =
                                             int(t[0] == t[1]).numToON())
  foldl(delta, a * b, int(1))

## eq. (1.2.3)
proc calcPhaseFactor(onv: ONVector, index: int): Phase =
  let
    leftOfIndex = onv.vec[low(onv.vec)..<index]
    cnt = leftOfIndex.count(1.numToON())
    remainder = cnt mod 2
  if remainder == 0:
    return Phase.pos
  else:
    return Phase.neg

## Apply the creation operator at the given index.
proc create(v: ONVector, index: int): Option[ONVector] =
  case v.vec[index]:
    # eq. (1.2.1)
    of 0:
      # TODO needs copy?
      var r = v
      r.vec[index] = 1
      r.phase = r.phase * r.calcPhaseFactor(index)
      some(r)
    # eq. (1.2.2)
    of 1:
      none(ONVector)

## Apply the annihilation operator at the given index.
proc annihilate(v: ONVector, index: int): Option[ONVector] =
  case v.vec[index]:
    of 0:
      none(ONVector)
    of 1:
      # TODO needs copy?
      var r = v
      r.vec[index] = 0
      r.phase = r.phase * r.calcPhaseFactor(index)
      some(r)

when isMainModule:
  let
    # The vacuum state, eq. (1.1.10)
    vac = @[0, 0, 0, 0].toONVector()
    in1 = @[0, 1, 0, 0].toONVector()
    in2 = @[0, 0, 1, 0].toONVector()
    in12 = @[0, 1, 1, 0].toONVector()
  echo vac
  echo in12

  suite "ch1":
    test "numToON":
      check: numToON(0) == 0
      check: numToON(1) == 1
    test "innerProduct":
      # eq. (1.1.11)
      check: vac * vac == 1
      check: in1 * in1 == 1
      check: in1 * in2 == 0
      check: in1 * in12 == 0
    test "create":
      check: vac.create(0).get() == ONVector(vec: @[1, 0, 0, 0].toONSeq(), phase: Phase.pos)
      check: vac.create(3).get() == ONVector(vec: @[0, 0, 0, 1].toONSeq(), phase: Phase.pos)
      check: vac.create(0).get().create(1) == some(ONVector(vec: @[1, 1, 0, 0].toONSeq(), phase: Phase.neg))
      check: vac.create(3).get().create(0) == some(ONVector(vec: @[1, 0, 0, 1].toONSeq(), phase: Phase.pos))
      check: vac.create(0).get().create(0) == none(ONVector)
    test "annihilate":
      check: in1.annihilate(1).get() == vac
      check: in1.annihilate(0) == none(ONVector)
