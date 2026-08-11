/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Policy.lean

This file formalizes the executable and logical runtime safety-policy
layer of LeanSafeHRC.

The policy is represented through three equivalent views:

    allowedBool
        ↓
      allowed
        ↓
  permissibleActions

`allowedBool` provides the executable Boolean policy used by the
monitor. The logical relation `allowed` and the set-valued
representation `permissibleActions` are derived directly from this
executable definition and are used for formal reasoning.

The file also defines `minimumPermissibleAction`, which associates
each qualitative risk level with its canonical least-restrictive
policy-compliant intervention.

The main monitor-level correctness and minimal-intervention results
are established later in `Correctness.lean`.
-/

import LeanSafeHRC.Risk
import Mathlib.Data.Set.Basic

namespace LeanSafeHRC

/-
===========================================================
1. Executable Safety Policy
===========================================================
-/

/--
Executable runtime safety-policy checker.

`allowedBool r a` returns `true` exactly when monitor action `a` is
permissible at qualitative risk level `r`.

The policy is:

    Safe:
      continue operation
      reduce speed
      protective stop
      emergency stop

    Warning:
      reduce speed
      protective stop
      emergency stop

    Danger:
      protective stop
      emergency stop

    Emergency:
      emergency stop

Thus, the set of permissible actions becomes progressively more
restrictive as the assessed runtime risk increases.
-/
def allowedBool : RiskLevel → MonitorAction → Bool
  | .safe, _ =>
      true

  | .warning, .continueOperation =>
      false

  | .warning, _ =>
      true

  | .danger, .continueOperation =>
      false

  | .danger, .reduceSpeed =>
      false

  | .danger, _ =>
      true

  | .emergency, .emergencyStop =>
      true

  | .emergency, _ =>
      false


/-
===========================================================
2. Logical Safety Policy
===========================================================
-/

/--
Logical policy relation derived directly from the executable Boolean
policy.

`allowed r a` means that action `a` is permissible at risk level `r`.
-/
def allowed
    (r : RiskLevel)
    (a : MonitorAction) : Prop :=
  allowedBool r a = true

/--
The executable Boolean policy and logical policy relation coincide.
-/
theorem allowedBool_eq_true_iff
    (r : RiskLevel)
    (a : MonitorAction) :
    allowedBool r a = true ↔ allowed r a := by
  rfl


/-
===========================================================
3. Set-Based Policy Representation
===========================================================
-/

/--
The set of monitor actions permissible at a given risk level.

Mathematically:

    PermissibleActions(r) = { a | allowed(r, a) }.
-/
def permissibleActions
    (r : RiskLevel) : Set MonitorAction :=
  {a | allowed r a}

/--
Membership in the permissible-action set is equivalent to
satisfaction of the logical policy relation.
-/
theorem mem_permissibleActions_iff
    (r : RiskLevel)
    (a : MonitorAction) :
    a ∈ permissibleActions r ↔ allowed r a := by
  rfl

/--
Membership in the permissible-action set is also equivalent to
successful evaluation of the executable Boolean policy.
-/
theorem mem_permissibleActions_iff_bool
    (r : RiskLevel)
    (a : MonitorAction) :
    a ∈ permissibleActions r ↔ allowedBool r a = true := by
  rfl


/-
===========================================================
4. Canonical Minimum Permissible Action
===========================================================
-/

/--
Returns the canonical least-restrictive action selected by the
framework for each qualitative risk level.

The mapping is:

    Safe      ↦ continue operation
    Warning   ↦ reduce speed
    Danger    ↦ protective stop
    Emergency ↦ emergency stop

Its formal minimality with respect to `actionSeverity` is established
in `Correctness.lean`.
-/
def minimumPermissibleAction : RiskLevel → MonitorAction
  | .safe      => .continueOperation
  | .warning   => .reduceSpeed
  | .danger    => .protectiveStop
  | .emergency => .emergencyStop


/-
===========================================================
5. Basic Policy Properties
===========================================================
-/

/--
The canonical minimum action is permissible at every risk level.
-/
theorem minimumPermissibleAction_allowed
    (r : RiskLevel) :
    allowed r (minimumPermissibleAction r) := by
  cases r <;> rfl

/--
The canonical minimum action belongs to the corresponding
permissible-action set.
-/
theorem minimumPermissibleAction_mem
    (r : RiskLevel) :
    minimumPermissibleAction r ∈ permissibleActions r := by
  exact minimumPermissibleAction_allowed r

/--
Emergency stop is permissible at every risk level.
-/
theorem emergencyStop_always_allowed
    (r : RiskLevel) :
    allowed r .emergencyStop := by
  cases r <;> rfl

/--
Continuing operation is permissible exactly at the safe risk level.
-/
theorem continueOperation_allowed_iff
    (r : RiskLevel) :
    allowed r .continueOperation ↔ r = .safe := by
  cases r <;> simp [allowed, allowedBool]

/--
Reducing speed is permissible exactly at the safe or warning risk
levels.
-/
theorem reduceSpeed_allowed_iff
    (r : RiskLevel) :
    allowed r .reduceSpeed ↔
      r = .safe ∨ r = .warning := by
  cases r <;> simp [allowed, allowedBool]

/--
Protective stop is permissible exactly when the risk level is not
emergency.
-/
theorem protectiveStop_allowed_iff
    (r : RiskLevel) :
    allowed r .protectiveStop ↔
      r ≠ .emergency := by
  cases r <;> simp [allowed, allowedBool]

/--
At emergency risk, emergency stop is the only permissible action.
-/
theorem emergency_allowed_iff
    (a : MonitorAction) :
    allowed .emergency a ↔ a = .emergencyStop := by
  cases a <;> simp [allowed, allowedBool]

end LeanSafeHRC
