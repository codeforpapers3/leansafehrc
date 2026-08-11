/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Ordering.lean

This file defines severity measures and ordering relations for:

1. Qualitative risk levels
2. Runtime monitor actions

The risk ordering is:

    safe < warning < danger < emergency

where increasing severity represents increasing runtime risk.

The monitor-action ordering is:

    continueOperation < reduceSpeed
        < protectiveStop < emergencyStop

where increasing severity represents a more restrictive intervention.

These orderings provide the formal basis for risk escalation and for
the minimal-intervention properties established later in the development.
-/

import LeanSafeHRC.Basic

namespace LeanSafeHRC

/-
===========================================================
1. Risk-Level Severity
===========================================================
-/

/--
Assigns a natural-number severity to each qualitative risk level.

The severity mapping is:

    safe      ↦ 0
    warning   ↦ 1
    danger    ↦ 2
    emergency ↦ 3
-/
def riskSeverity : RiskLevel → Nat
  | .safe      => 0
  | .warning   => 1
  | .danger    => 2
  | .emergency => 3


/-
===========================================================
2. Monitor-Action Severity
===========================================================
-/

/--
Assigns a natural-number severity to each runtime monitor action.

A larger value represents a more restrictive safety intervention:

    continueOperation ↦ 0
    reduceSpeed       ↦ 1
    protectiveStop    ↦ 2
    emergencyStop     ↦ 3
-/
def actionSeverity : MonitorAction → Nat
  | .continueOperation => 0
  | .reduceSpeed       => 1
  | .protectiveStop    => 2
  | .emergencyStop     => 3


/-
===========================================================
3. Ordering of Risk Levels
===========================================================
-/

/--
A risk level is less than or equal to another risk level when its
numerical severity is less than or equal to the severity of the other.
-/
instance : LE RiskLevel where
  le r₁ r₂ :=
    riskSeverity r₁ ≤ riskSeverity r₂

/--
A risk level is strictly smaller than another risk level when its
numerical severity is strictly smaller than the severity of the other.
-/
instance : LT RiskLevel where
  lt r₁ r₂ :=
    riskSeverity r₁ < riskSeverity r₂

/-- The risk-level `≤` relation is decidable. -/
instance riskLevelDecidableLE
    (r₁ r₂ : RiskLevel) :
    Decidable (r₁ ≤ r₂) := by
  change Decidable (riskSeverity r₁ ≤ riskSeverity r₂)
  infer_instance

/-- The risk-level `<` relation is decidable. -/
instance riskLevelDecidableLT
    (r₁ r₂ : RiskLevel) :
    Decidable (r₁ < r₂) := by
  change Decidable (riskSeverity r₁ < riskSeverity r₂)
  infer_instance


/-
===========================================================
4. Ordering of Monitor Actions
===========================================================
-/

/--
A monitor action is less than or equal to another action when it is
no more restrictive than the other action.
-/
instance : LE MonitorAction where
  le a₁ a₂ :=
    actionSeverity a₁ ≤ actionSeverity a₂

/--
A monitor action is strictly smaller than another action when it is
strictly less restrictive than the other action.
-/
instance : LT MonitorAction where
  lt a₁ a₂ :=
    actionSeverity a₁ < actionSeverity a₂

/-- The monitor-action `≤` relation is decidable. -/
instance monitorActionDecidableLE
    (a₁ a₂ : MonitorAction) :
    Decidable (a₁ ≤ a₂) := by
  change Decidable (actionSeverity a₁ ≤ actionSeverity a₂)
  infer_instance

/-- The monitor-action `<` relation is decidable. -/
instance monitorActionDecidableLT
    (a₁ a₂ : MonitorAction) :
    Decidable (a₁ < a₂) := by
  change Decidable (actionSeverity a₁ < actionSeverity a₂)
  infer_instance

end LeanSafeHRC
