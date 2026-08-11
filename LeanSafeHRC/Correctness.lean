/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Correctness.lean

This file establishes the principal machine-checked correctness
properties of the LeanSafeHRC executable runtime safety monitor.

The verified results are organized into the following categories:

1. Policy correctness
2. Monitor determinism
3. Risk-to-action responsiveness
4. Exact action-to-risk characterizations
5. Prevention of unsafe continuation
6. Minimal intervention

Together, these results connect the executable monitor construction
to the formally specified runtime safety policy and establish that
the monitor behaves deterministically, responds appropriately to each
qualitative risk level, prevents unrestricted continuation under
non-safe conditions, and selects a minimum-severity permissible action.

The generic results in this file are instantiated for the collaborative
assembly scenarios in `CaseStudy.lean`.
-/

import LeanSafeHRC.Monitor

namespace LeanSafeHRC

/-
===========================================================
1. Policy Correctness
===========================================================
-/

/--
Policy Soundness.

The action selected by the executable runtime monitor satisfies the
logical safety policy for the risk assessed from the current state.

Formally:

    allowed (monitorRisk C s) (monitorAction C s).
-/
theorem monitor_sound
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    allowed (monitorRisk cfg s) (monitorAction cfg s) := by
  exact monitorAction_allowed cfg s

/--
Set-theoretic formulation of policy soundness.

The action selected by the executable monitor belongs to the set of
actions permissible for the assessed risk level.
-/
theorem monitor_mem_permissible
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s ∈
      permissibleActions (monitorRisk cfg s) := by
  exact monitorAction_mem_permissibleActions cfg s


/-
===========================================================
2. Monitor Determinism
===========================================================
-/

/--
For a fixed safety configuration and runtime state, the executable
monitor produces a unique action.

Since `monitorAction` is a function, determinism follows directly
from functional equality.
-/
theorem monitor_deterministic
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (a₁ a₂ : MonitorAction)
    (h₁ : monitorAction cfg s = a₁)
    (h₂ : monitorAction cfg s = a₂) :
    a₁ = a₂ := by
  rw [← h₁, ← h₂]

/--
For a fixed safety configuration and runtime state, the complete
monitoring result returned by `runMonitor` is unique.
-/
theorem runMonitor_deterministic
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (r₁ r₂ : MonitorResult)
    (h₁ : runMonitor cfg s = r₁)
    (h₂ : runMonitor cfg s = r₂) :
    r₁ = r₂ := by
  rw [← h₁, ← h₂]


/-
===========================================================
3. Risk-to-Action Responsiveness
===========================================================
-/

/--
A safe risk assessment causes the monitor to continue normal
operation.
-/
theorem safe_risk_implies_continue
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .safe) :
    monitorAction cfg s = .continueOperation := by
  unfold monitorAction
  rw [h]
  rfl

/--
A warning risk assessment causes the monitor to reduce robot speed.
-/
theorem warning_risk_implies_reduceSpeed
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .warning) :
    monitorAction cfg s = .reduceSpeed := by
  unfold monitorAction
  rw [h]
  rfl

/--
A danger risk assessment causes the monitor to issue a protective
stop.
-/
theorem danger_risk_implies_protectiveStop
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .danger) :
    monitorAction cfg s = .protectiveStop := by
  unfold monitorAction
  rw [h]
  rfl

/--
An emergency risk assessment causes the monitor to issue an
emergency stop.
-/
theorem emergency_risk_implies_emergencyStop
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .emergency) :
    monitorAction cfg s = .emergencyStop := by
  unfold monitorAction
  rw [h]
  rfl


/-
===========================================================
4. Action-to-Risk Characterizations
===========================================================
-/

/--
The monitor continues normal operation exactly when the assessed
risk level is safe.
-/
theorem monitor_continue_iff_safe
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s = .continueOperation ↔
      monitorRisk cfg s = .safe := by
  unfold monitorAction
  cases h : monitorRisk cfg s <;>
    simp [minimumPermissibleAction]

/--
The monitor reduces speed exactly when the assessed risk level is
warning.
-/
theorem monitor_reduceSpeed_iff_warning
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s = .reduceSpeed ↔
      monitorRisk cfg s = .warning := by
  unfold monitorAction
  cases h : monitorRisk cfg s <;>
    simp [minimumPermissibleAction]

/--
The monitor issues a protective stop exactly when the assessed risk
level is danger.
-/
theorem monitor_protectiveStop_iff_danger
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s = .protectiveStop ↔
      monitorRisk cfg s = .danger := by
  unfold monitorAction
  cases h : monitorRisk cfg s <;>
    simp [minimumPermissibleAction]

/--
The monitor issues an emergency stop exactly when the assessed risk
level is emergency.
-/
theorem monitor_emergencyStop_iff_emergency
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) :
    monitorAction cfg s = .emergencyStop ↔
      monitorRisk cfg s = .emergency := by
  unfold monitorAction
  cases h : monitorRisk cfg s <;>
    simp [minimumPermissibleAction]


/-
===========================================================
5. Prevention of Unsafe Continuation
===========================================================
-/

/--
The monitor cannot continue normal operation at warning risk.
-/
theorem warning_prevents_continuation
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .warning) :
    monitorAction cfg s ≠ .continueOperation := by
  rw [warning_risk_implies_reduceSpeed cfg s h]
  decide

/--
The monitor cannot continue normal operation at danger risk.
-/
theorem danger_prevents_continuation
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .danger) :
    monitorAction cfg s ≠ .continueOperation := by
  rw [danger_risk_implies_protectiveStop cfg s h]
  decide

/--
The monitor cannot continue normal operation at emergency risk.
-/
theorem emergency_prevents_continuation
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorRisk cfg s = .emergency) :
    monitorAction cfg s ≠ .continueOperation := by
  rw [emergency_risk_implies_emergencyStop cfg s h]
  decide

/--
Safe Continuation.

If the monitor permits unrestricted continuation, then the assessed
runtime risk must be safe.
-/
theorem no_unsafe_continuation
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (h : monitorAction cfg s = .continueOperation) :
    monitorRisk cfg s = .safe := by
  exact (monitor_continue_iff_safe cfg s).mp h


/-
===========================================================
6. Minimal Intervention
===========================================================
-/

/--
The canonical action associated with a risk level has severity no
greater than that of any other action allowed at the same risk level.

This establishes the policy-level minimality of
`minimumPermissibleAction` with respect to `actionSeverity`.
-/
theorem minimumPermissibleAction_minimal
    (r : RiskLevel)
    (a : MonitorAction)
    (hAllowed : allowed r a) :
    actionSeverity (minimumPermissibleAction r) ≤
      actionSeverity a := by
  cases r <;> cases a <;>
    simp [minimumPermissibleAction, allowed, allowedBool,
      actionSeverity] at hAllowed ⊢

/--
Minimal Intervention Theorem.

Among all actions permitted by the runtime safety policy for the
currently assessed risk, the executable monitor selects an action
with minimum intervention severity.

Formally:

    allowed (monitorRisk C s) a
      →
    actionSeverity (monitorAction C s) ≤ actionSeverity a.
-/
theorem monitor_minimal_intervention
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (a : MonitorAction)
    (hAllowed : allowed (monitorRisk cfg s) a) :
    actionSeverity (monitorAction cfg s) ≤
      actionSeverity a := by
  unfold monitorAction
  exact
    minimumPermissibleAction_minimal
      (monitorRisk cfg s) a hAllowed

/--
Set-theoretic formulation of the Minimal Intervention Theorem.

Every member of the permissible-action set has severity greater than
or equal to the severity of the action selected by the monitor.
-/
theorem monitor_minimal_in_permissible_set
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (a : MonitorAction)
    (hMem :
      a ∈ permissibleActions (monitorRisk cfg s)) :
    actionSeverity (monitorAction cfg s) ≤
      actionSeverity a := by
  apply monitor_minimal_intervention cfg s a
  exact hMem

end LeanSafeHRC
