/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: CaseStudy.lean

This file presents the executable collaborative-assembly case study
used to evaluate the LeanSafeHRC framework.

The case study consists of seven representative runtime scenarios,
corresponding to scenarios S1--S7 reported in the paper:

    S1. Robot-only operation with no human detected.
    S2. Safe human--robot collaboration.
    S3. Proximity-based warning condition.
    S4. Robot-velocity violation.
    S5. Proximity-based danger condition.
    S6. Interaction-force violation.
    S7. Emergency condition.

The scenarios exercise all four qualitative risk levels and their
corresponding canonical monitor actions.

Each state is evaluated using the same executable monitor developed
in `Monitor.lean`. The file establishes:

1. Risk classifications for the seven scenarios
2. Canonical monitor actions
3. Instantiations of policy-soundness and safety guarantees
4. Instantiations of the minimal-intervention theorem
5. Machine-checked characterizations of the complete risk and
   action sequences
6. Executable evaluations of the case-study scenarios

The generic correctness results instantiated here are established
in `Correctness.lean`.
-/

import LeanSafeHRC.Correctness

namespace LeanSafeHRC
namespace CaseStudy

/-
===========================================================
1. Collaborative-Assembly Scenarios
===========================================================
-/

/--
Scenario S1: Robot-only operation.

The robot performs its task while no human operator is detected in
the monitored workspace. The expected monitor response is continued
operation.
-/
def robotOnlyOperationState :=
  absentHumanExampleState

/--
Scenario S2: Safe human--robot collaboration.

The human operator is present but remains in the safe collaboration
region. The expected monitor response is continued operation.
-/
def humanInSafeRegionState :=
  safeExampleState

/--
Scenario S3: Proximity-based warning.

The human operator approaches the robot and enters the warning region.
The expected monitor response is speed reduction.
-/
def humanInWarningRegionState :=
  warningExampleState

/--
Scenario S4: Robot-velocity violation.

The human remains at a safe separation distance, but the robot exceeds
the configured velocity threshold. The expected monitor response is
speed reduction.
-/
def excessiveVelocityState :=
  velocityViolationExampleState

/--
Scenario S5: Proximity-based danger.

The human operator enters the danger region. The expected monitor
response is a protective stop.
-/
def humanInDangerRegionState :=
  dangerExampleState

/--
Scenario S6: Interaction-force violation.

The human remains at a safe separation distance, but the measured
interaction force exceeds the configured force threshold. The expected
monitor response is a protective stop.
-/
def excessiveForceState :=
  forceViolationExampleState

/--
Scenario S7: Emergency condition.

A critical runtime condition requires immediate emergency intervention.
The expected monitor response is an emergency stop.
-/
def criticalEmergencyState :=
  emergencyExampleState


/-
===========================================================
2. Executable Scenario Trace
===========================================================
-/

/--
The seven-state runtime trace used in the collaborative-assembly
case study.

The trace exercises normal operation, proximity-based hazards,
operational safety violations, and an emergency condition.
-/
def collaborativeAssemblyTrace :=
  [
    robotOnlyOperationState,
    humanInSafeRegionState,
    humanInWarningRegionState,
    excessiveVelocityState,
    humanInDangerRegionState,
    excessiveForceState,
    criticalEmergencyState
  ]

/--
Computes the qualitative risk levels associated with the complete
collaborative-assembly trace.
-/
def collaborativeAssemblyRisks :=
  collaborativeAssemblyTrace.map
    (monitorRisk exampleConfig)

/--
Computes the canonical monitor actions associated with the complete
collaborative-assembly trace.
-/
def collaborativeAssemblyActions :=
  collaborativeAssemblyTrace.map
    (monitorAction exampleConfig)

/--
Runs the complete executable monitor on every state of the
collaborative-assembly trace.
-/
def collaborativeAssemblyResults :=
  collaborativeAssemblyTrace.map
    (runMonitor exampleConfig)


/-
===========================================================
3. Risk-Assessment Results
===========================================================
-/

/--
Scenario S1 is classified as safe when the human operator is absent.
-/
theorem robotOnlyOperation_risk :
    monitorRisk exampleConfig robotOnlyOperationState =
      .safe := by
  decide

/--
Scenario S2 is classified as safe when the human remains in the
safe collaboration region.
-/
theorem humanInSafeRegion_risk :
    monitorRisk exampleConfig humanInSafeRegionState =
      .safe := by
  decide

/--
Scenario S3 is classified as warning when the human enters the
warning region.
-/
theorem humanInWarningRegion_risk :
    monitorRisk exampleConfig humanInWarningRegionState =
      .warning := by
  decide

/--
Scenario S4 is upgraded to warning because the configured robot
velocity threshold is exceeded.
-/
theorem excessiveVelocity_risk :
    monitorRisk exampleConfig excessiveVelocityState =
      .warning := by
  decide

/--
Scenario S5 is classified as danger when the human enters the
danger region.
-/
theorem humanInDangerRegion_risk :
    monitorRisk exampleConfig humanInDangerRegionState =
      .danger := by
  decide

/--
Scenario S6 is upgraded to danger because the configured interaction-
force threshold is exceeded.
-/
theorem excessiveForce_risk :
    monitorRisk exampleConfig excessiveForceState =
      .danger := by
  decide

/--
Scenario S7 is classified as emergency.
-/
theorem criticalEmergency_risk :
    monitorRisk exampleConfig criticalEmergencyState =
      .emergency := by
  decide


/-
===========================================================
4. Monitor-Action Results
===========================================================
-/

/--
Scenario S1 permits continued robot operation.
-/
theorem robotOnlyOperation_action :
    monitorAction exampleConfig robotOnlyOperationState =
      .continueOperation := by
  decide

/--
Scenario S2 permits continued operation during safe collaboration.
-/
theorem humanInSafeRegion_action :
    monitorAction exampleConfig humanInSafeRegionState =
      .continueOperation := by
  decide

/--
Scenario S3 results in robot speed reduction.
-/
theorem humanInWarningRegion_action :
    monitorAction exampleConfig humanInWarningRegionState =
      .reduceSpeed := by
  decide

/--
Scenario S4 results in robot speed reduction following the velocity
violation.
-/
theorem excessiveVelocity_action :
    monitorAction exampleConfig excessiveVelocityState =
      .reduceSpeed := by
  decide

/--
Scenario S5 results in a protective stop.
-/
theorem humanInDangerRegion_action :
    monitorAction exampleConfig humanInDangerRegionState =
      .protectiveStop := by
  decide

/--
Scenario S6 results in a protective stop following the interaction-
force violation.
-/
theorem excessiveForce_action :
    monitorAction exampleConfig excessiveForceState =
      .protectiveStop := by
  decide

/--
Scenario S7 results in an emergency stop.
-/
theorem criticalEmergency_action :
    monitorAction exampleConfig criticalEmergencyState =
      .emergencyStop := by
  decide


/-
===========================================================
5. Safety Guarantees for the Case Study
===========================================================
-/

/--
The action selected in Scenario S1 satisfies the runtime safety policy.
-/
theorem robotOnlyOperation_sound :
    allowed
      (monitorRisk exampleConfig robotOnlyOperationState)
      (monitorAction exampleConfig robotOnlyOperationState) := by
  exact monitor_sound exampleConfig robotOnlyOperationState

/--
The action selected in Scenario S3 satisfies the runtime safety policy.
-/
theorem humanInWarningRegion_sound :
    allowed
      (monitorRisk exampleConfig humanInWarningRegionState)
      (monitorAction exampleConfig humanInWarningRegionState) := by
  exact monitor_sound exampleConfig humanInWarningRegionState

/--
The action selected in Scenario S5 satisfies the runtime safety policy.
-/
theorem humanInDangerRegion_sound :
    allowed
      (monitorRisk exampleConfig humanInDangerRegionState)
      (monitorAction exampleConfig humanInDangerRegionState) := by
  exact monitor_sound exampleConfig humanInDangerRegionState

/--
The action selected in Scenario S7 satisfies the runtime safety policy.
-/
theorem criticalEmergency_sound :
    allowed
      (monitorRisk exampleConfig criticalEmergencyState)
      (monitorAction exampleConfig criticalEmergencyState) := by
  exact monitor_sound exampleConfig criticalEmergencyState

/--
Scenario S5 cannot result in unrestricted continuation.
-/
theorem dangerRegion_prevents_continuation :
    monitorAction exampleConfig humanInDangerRegionState ≠
      .continueOperation := by
  apply danger_prevents_continuation
  exact humanInDangerRegion_risk

/--
Scenario S6 cannot result in unrestricted continuation.
-/
theorem excessiveForce_prevents_continuation :
    monitorAction exampleConfig excessiveForceState ≠
      .continueOperation := by
  apply danger_prevents_continuation
  exact excessiveForce_risk

/--
Scenario S7 cannot result in unrestricted continuation.
-/
theorem criticalEmergency_prevents_continuation :
    monitorAction exampleConfig criticalEmergencyState ≠
      .continueOperation := by
  apply emergency_prevents_continuation
  exact criticalEmergency_risk

/--
Scenario S7 necessarily results in an emergency stop.
-/
theorem criticalEmergency_requires_emergencyStop :
    monitorAction exampleConfig criticalEmergencyState =
      .emergencyStop := by
  apply emergency_risk_implies_emergencyStop
  exact criticalEmergency_risk


/-
===========================================================
6. Minimal-Intervention Results
===========================================================
-/

/--
For Scenario S3, the selected speed-reduction action has minimum
severity among all actions permitted for the assessed warning risk.
-/
theorem warningRegion_minimal_intervention
    (a : MonitorAction)
    (hAllowed :
      allowed
        (monitorRisk exampleConfig humanInWarningRegionState)
        a) :
    actionSeverity
        (monitorAction exampleConfig humanInWarningRegionState) ≤
      actionSeverity a := by
  exact
    monitor_minimal_intervention
      exampleConfig
      humanInWarningRegionState
      a
      hAllowed

/--
For Scenario S5, the selected protective-stop action has minimum
severity among all actions permitted for the assessed danger risk.
-/
theorem dangerRegion_minimal_intervention
    (a : MonitorAction)
    (hAllowed :
      allowed
        (monitorRisk exampleConfig humanInDangerRegionState)
        a) :
    actionSeverity
        (monitorAction exampleConfig humanInDangerRegionState) ≤
      actionSeverity a := by
  exact
    monitor_minimal_intervention
      exampleConfig
      humanInDangerRegionState
      a
      hAllowed

/--
For Scenario S7, the selected emergency-stop action has minimum
severity among all actions permitted for the assessed emergency risk.
-/
theorem emergency_minimal_intervention
    (a : MonitorAction)
    (hAllowed :
      allowed
        (monitorRisk exampleConfig criticalEmergencyState)
        a) :
    actionSeverity
        (monitorAction exampleConfig criticalEmergencyState) ≤
      actionSeverity a := by
  exact
    monitor_minimal_intervention
      exampleConfig
      criticalEmergencyState
      a
      hAllowed


/-
===========================================================
7. Complete Trace Characterization
===========================================================
-/

/--
The complete machine-checked risk sequence for scenarios S1--S7.
-/
theorem collaborativeAssemblyRisks_correct :
    collaborativeAssemblyRisks =
      [
        .safe,
        .safe,
        .warning,
        .warning,
        .danger,
        .danger,
        .emergency
      ] := by
  decide

/--
The complete machine-checked action sequence for scenarios S1--S7.
-/
theorem collaborativeAssemblyActions_correct :
    collaborativeAssemblyActions =
      [
        .continueOperation,
        .continueOperation,
        .reduceSpeed,
        .reduceSpeed,
        .protectiveStop,
        .protectiveStop,
        .emergencyStop
      ] := by
  decide


/-
===========================================================
8. Executable Demonstration
===========================================================
-/

#eval monitorRisk exampleConfig robotOnlyOperationState
-- safe

#eval monitorAction exampleConfig robotOnlyOperationState
-- continueOperation

#eval monitorRisk exampleConfig humanInSafeRegionState
-- safe

#eval monitorAction exampleConfig humanInSafeRegionState
-- continueOperation

#eval monitorRisk exampleConfig humanInWarningRegionState
-- warning

#eval monitorAction exampleConfig humanInWarningRegionState
-- reduceSpeed

#eval monitorRisk exampleConfig excessiveVelocityState
-- warning

#eval monitorAction exampleConfig excessiveVelocityState
-- reduceSpeed

#eval monitorRisk exampleConfig humanInDangerRegionState
-- danger

#eval monitorAction exampleConfig humanInDangerRegionState
-- protectiveStop

#eval monitorRisk exampleConfig excessiveForceState
-- danger

#eval monitorAction exampleConfig excessiveForceState
-- protectiveStop

#eval monitorRisk exampleConfig criticalEmergencyState
-- emergency

#eval monitorAction exampleConfig criticalEmergencyState
-- emergencyStop

#eval collaborativeAssemblyRisks
-- [safe, safe, warning, warning, danger, danger, emergency]

#eval collaborativeAssemblyActions
-- [continueOperation, continueOperation, reduceSpeed, reduceSpeed,
--  protectiveStop, protectiveStop, emergencyStop]

#eval collaborativeAssemblyResults

end CaseStudy
end LeanSafeHRC
