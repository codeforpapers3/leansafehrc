/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Monitor.lean

This file formalizes the executable runtime-monitor construction layer
of LeanSafeHRC.

The monitor exposes two principal functions:

    monitorRisk
        provides the monitor-level interface to the executable
        risk classifier defined in `Risk.lean`;

    monitorAction
        selects the canonical action associated with the assessed
        risk through `minimumPermissibleAction`.

The complete executable monitor therefore follows the composition:

    HRC State
        ↓
    Risk Assessment
        ↓
    Canonical Action Selection
        ↓
    Monitor Result

The function `runMonitor` combines the assessed qualitative risk and
selected canonical action into a single executable monitoring result.

This module also establishes basic interface properties connecting the
monitor construction to the risk-assessment and policy layers. The main
behavioural and minimal-intervention guarantees are proved later in
`Correctness.lean`.
-/

import LeanSafeHRC.Policy

namespace LeanSafeHRC

/-
===========================================================
1. Monitor Risk Assessment
===========================================================
-/

/--
Computes the qualitative risk level observed by the runtime safety
monitor.

This definition provides a monitor-level interface to `riskLevel`,
the executable risk classifier defined in `Risk.lean`. It does not
introduce a separate risk-assessment procedure.
-/
def monitorRisk
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) : RiskLevel :=
  riskLevel cfg s


/-
===========================================================
2. Monitor Action Selection
===========================================================
-/

/--
Computes the canonical action issued by the runtime safety monitor.

The monitor first evaluates the current qualitative risk and then
selects the canonical action associated with that risk through
`minimumPermissibleAction`.

Mathematically:

    MonitorAction(C, s) =
      MinimumPermissibleAction(MonitorRisk(C, s)).
-/
def monitorAction
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) : MonitorAction :=
  minimumPermissibleAction (monitorRisk cfg s)


/-
===========================================================
3. Monitor Result
===========================================================
-/

/--
Combined output of the executable runtime monitor.

The result records both the qualitative risk assessed from the current
HRC state and the canonical mitigation action selected for that risk.
-/
structure MonitorResult where
  risk : RiskLevel
  action : MonitorAction
deriving Repr, DecidableEq, BEq, Inhabited

/--
Runs the complete executable monitor and returns both the assessed risk
and the corresponding canonical action.
-/
def runMonitor
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) : MonitorResult :=
  {
    risk := monitorRisk cfg s
    action := monitorAction cfg s
  }


/-
===========================================================
4. Monitor Interface Properties
===========================================================
-/

/--
The risk field returned by `runMonitor` is exactly the risk computed
by `monitorRisk`.
-/
theorem runMonitor_risk
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    (runMonitor cfg s).risk = monitorRisk cfg s := by
  rfl

/--
The action field returned by `runMonitor` is exactly the action
computed by `monitorAction`.
-/
theorem runMonitor_action
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    (runMonitor cfg s).action = monitorAction cfg s := by
  rfl

/--
The action selected by the monitor is the canonical action associated
with the risk assessed by the monitor.
-/
theorem monitorAction_eq_minimum
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s =
      minimumPermissibleAction (monitorRisk cfg s) := by
  rfl

/--
The action selected by the monitor satisfies the logical runtime safety
policy for the risk assessed by the monitor.
-/
theorem monitorAction_allowed
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    allowed (monitorRisk cfg s) (monitorAction cfg s) := by
  unfold monitorAction
  exact minimumPermissibleAction_allowed (monitorRisk cfg s)

/--
The action selected by the monitor belongs to the permissible-action
set associated with the assessed risk level.
-/
theorem monitorAction_mem_permissibleActions
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s ∈
      permissibleActions (monitorRisk cfg s) := by
  exact monitorAction_allowed cfg s

end LeanSafeHRC
