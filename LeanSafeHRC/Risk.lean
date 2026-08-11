/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Risk.lean

This file formalizes the executable runtime risk-assessment layer of
LeanSafeHRC.

The assessment proceeds in three stages:

    Observed HRC State
           ↓
    Distance-Zone Classification
           ↓
    Safety-Violation Detection
           ↓
    Final Risk Level

The geometric component classifies the human--robot separation into
safe, warning, and danger regions. The resulting base risk is then
refined according to emergency, interaction-force, and robot-velocity
conditions using priority-based risk upgrading.

This module is independent of runtime monitor actions and policy
selection. Those layers are introduced in `Policy.lean` and
`Monitor.lean`.
-/

import LeanSafeHRC.Ordering

namespace LeanSafeHRC

/-
===========================================================
1. Distance-Zone Predicates
===========================================================
-/

/--
The system is in the safe zone when either:

1. no human is detected; or
2. a human is present but the measured separation distance is greater
   than the configured warning distance.

Mathematically:

    SafeZone(C, s) ⇔
      humanAbsent(s) ∨ warningDistance(C) < distance(s)
-/
def safeZone
    {α : Type}
    [LT α]
    (cfg : SafetyConfig α)
    (s : HRCState α) : Prop :=
  s.humanPresence = .absent ∨
  cfg.warningDistance < s.distance

/--
The system is in the warning zone when a human is present and the
measured separation distance lies strictly above the stop distance but
at or below the warning distance.

Mathematically:

    WarningZone(C, s) ⇔
      humanPresent(s) ∧
      stopDistance(C) < distance(s) ∧
      distance(s) ≤ warningDistance(C)
-/
def warningZone
    {α : Type}
    [LT α]
    [LE α]
    (cfg : SafetyConfig α)
    (s : HRCState α) : Prop :=
  s.humanPresence = .present ∧
  cfg.stopDistance < s.distance ∧
  s.distance ≤ cfg.warningDistance

/--
The system is in the danger zone when a human is present and the
measured separation distance is at or below the configured stop distance.

Mathematically:

    DangerZone(C, s) ⇔
      humanPresent(s) ∧
      distance(s) ≤ stopDistance(C)
-/
def dangerZone
    {α : Type}
    [LE α]
    (cfg : SafetyConfig α)
    (s : HRCState α) : Prop :=
  s.humanPresence = .present ∧
  s.distance ≤ cfg.stopDistance


/-
===========================================================
2. Safety-Violation Predicates
===========================================================
-/

/--
A velocity violation occurs when the current robot velocity exceeds
the configured maximum velocity.
-/
def velocityViolation
    {α : Type}
    [LT α]
    (cfg : SafetyConfig α)
    (s : HRCState α) : Prop :=
  cfg.maxVelocity < s.velocity

/--
A force violation occurs when the measured interaction force exceeds
the configured maximum interaction force.
-/
def forceViolation
    {α : Type}
    [LT α]
    (cfg : SafetyConfig α)
    (s : HRCState α) : Prop :=
  cfg.maxForce < s.interactionForce

/--
An emergency condition holds when either:

1. an explicit emergency signal is active; or
2. the robot is already in emergency-stop mode.
-/
def emergencyCondition
    {α : Type}
    (s : HRCState α) : Prop :=
  s.emergencySignal = true ∨
  s.mode = .emergencyStop


/-
===========================================================
3. Base Risk Classification
===========================================================
-/

/--
Computes the risk induced by the human--robot separation zone.

The danger condition is checked first, followed by the warning
condition. Every remaining state is classified as safe.

For a well-formed safety configuration, this corresponds to:

    danger zone  ↦ danger
    warning zone ↦ warning
    safe zone    ↦ safe
-/
def baseRisk
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) : RiskLevel := by
  letI : Decidable (dangerZone cfg s) := by
    unfold dangerZone
    infer_instance

  letI : Decidable (warningZone cfg s) := by
    unfold warningZone
    infer_instance

  exact
    if dangerZone cfg s then
      .danger
    else if warningZone cfg s then
      .warning
    else
      .safe


/-
===========================================================
4. Risk-Upgrading Operations
===========================================================
-/

/--
Raises a risk level to at least `warning`.

The operation leaves warning, danger, and emergency classifications
unchanged.
-/
def atLeastWarning : RiskLevel → RiskLevel
  | .safe      => .warning
  | .warning   => .warning
  | .danger    => .danger
  | .emergency => .emergency

/--
Raises a risk level to at least `danger`.

The operation leaves danger and emergency classifications unchanged.
-/
def atLeastDanger : RiskLevel → RiskLevel
  | .safe      => .danger
  | .warning   => .danger
  | .danger    => .danger
  | .emergency => .emergency

/--
Upgrades a base risk according to operational safety conditions.

Priority is assigned as follows:

1. Emergency condition  → `emergency`
2. Force violation      → at least `danger`
3. Velocity violation   → at least `warning`
4. No violation         → unchanged base risk

The upgrading operations preserve or increase risk severity and never
reduce an existing classification.
-/
def upgradeRisk
    {α : Type}
    [LT α]
    [DecidableRel (fun x y : α => x < y)]
    (cfg : SafetyConfig α)
    (s : HRCState α)
    (r : RiskLevel) : RiskLevel := by
  letI : Decidable (emergencyCondition s) := by
    unfold emergencyCondition
    infer_instance

  letI : Decidable (forceViolation cfg s) := by
    unfold forceViolation
    infer_instance

  letI : Decidable (velocityViolation cfg s) := by
    unfold velocityViolation
    infer_instance

  exact
    if emergencyCondition s then
      .emergency
    else if forceViolation cfg s then
      atLeastDanger r
    else if velocityViolation cfg s then
      atLeastWarning r
    else
      r

/--
Risk upgrading is non-decreasing with respect to risk severity.

For every safety configuration, runtime state, and input risk level,
`upgradeRisk` either preserves the current risk or raises it to a
more severe classification. In particular, additional safety
violations can never reduce the severity of the input risk.
-/
theorem upgradeRisk_non_decreasing
{α : Type}
[LT α]
[DecidableRel (fun x y : α => x < y)]
(cfg : SafetyConfig α)
(s : HRCState α)
(r : RiskLevel) :
riskSeverity r ≤ riskSeverity (upgradeRisk cfg s r) := by
  unfold upgradeRisk
  split
  · cases r <;> decide
  · split
    · cases r <;> decide
    · split
      · cases r <;> decide
      · exact Nat.le_refl (riskSeverity r)

/-
===========================================================
5. Final Risk Classifier
===========================================================
-/

/--
The executable HRC risk classifier.

It first computes the distance-based base risk and then upgrades that
classification according to emergency, interaction-force, and
robot-velocity conditions.

Mathematically:

    RiskLevel(C, s) =
      UpgradeRisk(C, s, BaseRisk(C, s))
-/
def riskLevel
    {α : Type}
    [LT α]
    [LE α]
    [DecidableRel (fun x y : α => x < y)]
    [DecidableRel (fun x y : α => x ≤ y)]
    (cfg : SafetyConfig α)
    (s : HRCState α) : RiskLevel :=
  upgradeRisk cfg s (baseRisk cfg s)

/-
===========================================================
6. Reference Runtime States
===========================================================

The following concrete states provide reusable instances of the
risk-assessment conditions defined above. They are used by subsequent
modules for executable evaluation and by the collaborative assembly
case study to instantiate the generic monitoring framework.
-/

/-- Human present beyond the warning distance. -/
def safeExampleState : HRCState Nat where
  distance := 120
  velocity := 10
  interactionForce := 2
  humanPresence := .present
  emergencySignal := false
  mode := .collaborative

/-- Human present between the stop and warning distances. -/
def warningExampleState : HRCState Nat where
  distance := 80
  velocity := 10
  interactionForce := 2
  humanPresence := .present
  emergencySignal := false
  mode := .collaborative

/-- Human present within the protective-stop distance. -/
def dangerExampleState : HRCState Nat where
  distance := 30
  velocity := 10
  interactionForce := 2
  humanPresence := .present
  emergencySignal := false
  mode := .collaborative

/-- State containing an explicit emergency signal. -/
def emergencyExampleState : HRCState Nat where
  distance := 120
  velocity := 10
  interactionForce := 2
  humanPresence := .present
  emergencySignal := true
  mode := .collaborative

/-- Safe separation distance combined with excessive robot velocity. -/
def velocityViolationExampleState : HRCState Nat where
  distance := 120
  velocity := 25
  interactionForce := 2
  humanPresence := .present
  emergencySignal := false
  mode := .collaborative

/-- Safe separation distance combined with excessive interaction force. -/
def forceViolationExampleState : HRCState Nat where
  distance := 120
  velocity := 10
  interactionForce := 15
  humanPresence := .present
  emergencySignal := false
  mode := .collaborative

/-- No human is detected, regardless of the measured separation distance. -/
def absentHumanExampleState : HRCState Nat where
  distance := 10
  velocity := 10
  interactionForce := 2
  humanPresence := .absent
  emergencySignal := false
  mode := .automatic

end LeanSafeHRC
