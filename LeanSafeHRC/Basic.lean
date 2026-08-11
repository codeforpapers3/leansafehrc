/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Basic.lean

This file defines the foundational datatypes and structures used
throughout the LeanSafeHRC development:

1. Robot operating modes
2. Runtime monitor actions
3. Human-presence information
4. Qualitative risk levels
5. Safety configurations and their well-formedness condition
6. Observable human–robot collaboration states
7. A reference configuration used by the executable examples and
   collaborative assembly case study

The numerical type `α` is intentionally generic. This allows the same
monitoring model to be instantiated with different ordered numerical
domains for distance, velocity, and interaction-force measurements.
-/

namespace LeanSafeHRC

/-
===========================================================
1. Robot Operating Modes
===========================================================
-/

/-- Operating modes of a collaborative robot. -/
inductive RobotMode where
  | idle
  | automatic
  | collaborative
  | protectiveStop
  | emergencyStop
deriving Repr, DecidableEq, BEq, Inhabited


/-
===========================================================
2. Runtime Monitor Actions
===========================================================
-/

/-- Actions that may be issued by the runtime safety monitor. -/
inductive MonitorAction where
  | continueOperation
  | reduceSpeed
  | protectiveStop
  | emergencyStop
deriving Repr, DecidableEq, BEq, Inhabited


/-
===========================================================
3. Human Presence
===========================================================
-/

/-- Whether a human is currently detected in the monitored workspace. -/
inductive HumanPresence where
  | absent
  | present
deriving Repr, DecidableEq, BEq, Inhabited


/-
===========================================================
4. Risk Levels
===========================================================
-/

/-- Qualitative risk levels used by the runtime safety monitor. -/
inductive RiskLevel where
  | safe
  | warning
  | danger
  | emergency
deriving Repr, DecidableEq, BEq, Inhabited


/-
===========================================================
5. Safety Configuration
===========================================================
-/

/--
A configurable collection of thresholds used by the runtime monitor.

The type `α` represents the numerical domain used for human--robot
separation distance, robot velocity, and interaction-force measurements.
-/
structure SafetyConfig (α : Type) where
  warningDistance : α
  stopDistance : α
  maxVelocity : α
  maxForce : α
deriving Repr

/--
A safety configuration is well formed when the protective-stop
distance is strictly smaller than the warning distance.
-/
def SafetyConfig.WellFormed
    {α : Type}
    [LT α]
    (cfg : SafetyConfig α) : Prop :=
  cfg.stopDistance < cfg.warningDistance


/-
===========================================================
6. Human--Robot Collaboration State
===========================================================
-/

/--
The observable runtime state supplied to the safety monitor.

The fields record the human--robot separation distance, current robot
velocity, measured interaction force, human-presence information,
emergency signal, and current robot operating mode.
-/
structure HRCState (α : Type) where
  distance : α
  velocity : α
  interactionForce : α
  humanPresence : HumanPresence
  emergencySignal : Bool
  mode : RobotMode
deriving Repr, DecidableEq


/-
===========================================================
7. Reference Safety Configuration
===========================================================
-/

/--
A natural-number safety configuration used by the executable examples
and collaborative assembly case study.
-/
def exampleConfig : SafetyConfig Nat where
  warningDistance := 100
  stopDistance := 40
  maxVelocity := 20
  maxForce := 10

/--
The reference safety configuration satisfies the required threshold
ordering.
-/
theorem exampleConfig_wellFormed : exampleConfig.WellFormed := by
  unfold SafetyConfig.WellFormed
  decide

end LeanSafeHRC
