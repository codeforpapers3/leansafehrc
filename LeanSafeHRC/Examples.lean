/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Examples.lean

This file contains executable smoke tests and additional illustrative
instantiations of the generic LeanSafeHRC monitoring framework.

These examples are provided to demonstrate executability and reuse of
the formal framework. They are not additional evaluated case studies
reported in the paper. The collaborative-assembly case study presented
in Section 5 of the paper is formalized separately in `CaseStudy.lean`.

The examples cover:

1. Core executable smoke tests
2. Collaborative welding
3. Pick-and-place collaboration
4. Warehouse mobile robotics
5. Surgical robotic assistance
6. Human-free autonomous operation
7. Cross-domain monitor execution

All examples reuse the same executable risk classifier, runtime safety
policy, monitor construction, and generic correctness results.
-/

import LeanSafeHRC.Correctness

namespace LeanSafeHRC
namespace Examples

/-
===========================================================
1. Core Executable Smoke Tests
===========================================================
-/

/-
-----------------------------------------------------------
1a. Basic Definitions
-----------------------------------------------------------
-/

/-- A representative collaborative operating state. -/
def exampleState : HRCState Nat where
  distance := 120
  velocity := 10
  interactionForce := 2
  humanPresence := .present
  emergencySignal := false
  mode := .collaborative

#eval exampleConfig
#eval exampleState


/-
-----------------------------------------------------------
1b. Risk and Action Orderings
-----------------------------------------------------------
-/

#eval riskSeverity RiskLevel.safe
#eval riskSeverity RiskLevel.emergency

#eval actionSeverity MonitorAction.continueOperation
#eval actionSeverity MonitorAction.emergencyStop

example : RiskLevel.safe < RiskLevel.warning := by
  decide

example : RiskLevel.warning ≤ RiskLevel.danger := by
  decide

example :
    MonitorAction.continueOperation <
      MonitorAction.reduceSpeed := by
  decide

example :
    MonitorAction.protectiveStop ≤
      MonitorAction.emergencyStop := by
  decide

example :
    ¬ MonitorAction.emergencyStop ≤
      MonitorAction.protectiveStop := by
  decide


/-
-----------------------------------------------------------
1c. Risk Assessment
-----------------------------------------------------------
-/

#eval baseRisk exampleConfig safeExampleState
-- safe

#eval baseRisk exampleConfig warningExampleState
-- warning

#eval baseRisk exampleConfig dangerExampleState
-- danger

#eval riskLevel exampleConfig safeExampleState
-- safe

#eval riskLevel exampleConfig warningExampleState
-- warning

#eval riskLevel exampleConfig dangerExampleState
-- danger

#eval riskLevel exampleConfig emergencyExampleState
-- emergency

#eval riskLevel exampleConfig velocityViolationExampleState
-- warning

#eval riskLevel exampleConfig forceViolationExampleState
-- danger

#eval riskLevel exampleConfig absentHumanExampleState
-- safe

/-
The following machine-checked smoke tests exercise the four qualitative
risk classifications together with velocity- and force-based upgrading.
-/

example :
    riskLevel exampleConfig safeExampleState =
      RiskLevel.safe := by
  decide

example :
    riskLevel exampleConfig warningExampleState =
      RiskLevel.warning := by
  decide

example :
    riskLevel exampleConfig dangerExampleState =
      RiskLevel.danger := by
  decide

example :
    riskLevel exampleConfig emergencyExampleState =
      RiskLevel.emergency := by
  decide

example :
    riskLevel exampleConfig velocityViolationExampleState =
      RiskLevel.warning := by
  decide

example :
    riskLevel exampleConfig forceViolationExampleState =
      RiskLevel.danger := by
  decide

example :
    riskLevel exampleConfig absentHumanExampleState =
      RiskLevel.safe := by
  decide


/-
-----------------------------------------------------------
1d. Runtime Safety Policy
-----------------------------------------------------------
-/

#eval allowedBool .safe .continueOperation
-- true

#eval allowedBool .warning .continueOperation
-- false

#eval allowedBool .warning .reduceSpeed
-- true

#eval allowedBool .danger .reduceSpeed
-- false

#eval allowedBool .danger .protectiveStop
-- true

#eval allowedBool .emergency .protectiveStop
-- false

#eval allowedBool .emergency .emergencyStop
-- true

#eval minimumPermissibleAction .safe
-- continueOperation

#eval minimumPermissibleAction .warning
-- reduceSpeed

#eval minimumPermissibleAction .danger
-- protectiveStop

#eval minimumPermissibleAction .emergency
-- emergencyStop

example :
    allowed .safe .continueOperation := by
  rfl

example :
    ¬ allowed .warning .continueOperation := by
  simp [allowed, allowedBool]

example :
    allowed .warning .reduceSpeed := by
  rfl

example :
    ¬ allowed .danger .reduceSpeed := by
  simp [allowed, allowedBool]

example :
    allowed .danger .protectiveStop := by
  rfl

example :
    ¬ allowed .emergency .protectiveStop := by
  simp [allowed, allowedBool]

example :
    allowed .emergency .emergencyStop := by
  rfl


/-
-----------------------------------------------------------
1e. Executable Monitor
-----------------------------------------------------------
-/

#eval monitorRisk exampleConfig safeExampleState
-- safe

#eval monitorRisk exampleConfig warningExampleState
-- warning

#eval monitorRisk exampleConfig dangerExampleState
-- danger

#eval monitorRisk exampleConfig emergencyExampleState
-- emergency

#eval monitorAction exampleConfig safeExampleState
-- continueOperation

#eval monitorAction exampleConfig warningExampleState
-- reduceSpeed

#eval monitorAction exampleConfig dangerExampleState
-- protectiveStop

#eval monitorAction exampleConfig emergencyExampleState
-- emergencyStop

#eval monitorAction exampleConfig velocityViolationExampleState
-- reduceSpeed

#eval monitorAction exampleConfig forceViolationExampleState
-- protectiveStop

#eval monitorAction exampleConfig absentHumanExampleState
-- continueOperation

#eval runMonitor exampleConfig safeExampleState
-- { risk := safe, action := continueOperation }

#eval runMonitor exampleConfig warningExampleState
-- { risk := warning, action := reduceSpeed }

#eval runMonitor exampleConfig dangerExampleState
-- { risk := danger, action := protectiveStop }

#eval runMonitor exampleConfig emergencyExampleState
-- { risk := emergency, action := emergencyStop }

example :
    monitorAction exampleConfig safeExampleState =
      MonitorAction.continueOperation := by
  decide

example :
    monitorAction exampleConfig warningExampleState =
      MonitorAction.reduceSpeed := by
  decide

example :
    monitorAction exampleConfig dangerExampleState =
      MonitorAction.protectiveStop := by
  decide

example :
    monitorAction exampleConfig emergencyExampleState =
      MonitorAction.emergencyStop := by
  decide

example :
    monitorAction exampleConfig velocityViolationExampleState =
      MonitorAction.reduceSpeed := by
  decide

example :
    monitorAction exampleConfig forceViolationExampleState =
      MonitorAction.protectiveStop := by
  decide

example :
    monitorAction exampleConfig absentHumanExampleState =
      MonitorAction.continueOperation := by
  decide


/-
===========================================================
2. Named Monitor Results
===========================================================
-/

/--
A named monitor result associates an illustrative application scenario
with the risk level and action produced by the verified monitor.
-/
structure NamedMonitorResult where
  scenario : String
  risk : RiskLevel
  action : MonitorAction
deriving Repr, DecidableEq, BEq, Inhabited

/--
Runs the verified monitor on a named illustrative application scenario.
-/
def runNamedScenario
    (name : String)
    (s : HRCState Nat) : NamedMonitorResult :=
  {
    scenario := name
    risk := monitorRisk exampleConfig s
    action := monitorAction exampleConfig s
  }


/-
===========================================================
3. Illustrative Cross-Domain Instantiations
===========================================================
-/

/-
-----------------------------------------------------------
3a. Collaborative Welding
-----------------------------------------------------------
-/

/--
Illustrative welding state in which the human worker remains in the
safe collaboration region.
-/
def weldingSafeState : HRCState Nat :=
  safeExampleState

/--
Illustrative welding state in which the human worker enters the
warning region.
-/
def weldingWarningState : HRCState Nat :=
  warningExampleState

/--
Illustrative welding state containing an emergency condition.
-/
def weldingEmergencyState : HRCState Nat :=
  emergencyExampleState

theorem weldingSafe_risk :
    monitorRisk exampleConfig weldingSafeState = .safe := by
  decide

theorem weldingSafe_action :
    monitorAction exampleConfig weldingSafeState =
      .continueOperation := by
  decide

theorem weldingWarning_risk :
    monitorRisk exampleConfig weldingWarningState = .warning := by
  decide

theorem weldingWarning_action :
    monitorAction exampleConfig weldingWarningState =
      .reduceSpeed := by
  decide

theorem weldingEmergency_action :
    monitorAction exampleConfig weldingEmergencyState =
      .emergencyStop := by
  decide


/-
-----------------------------------------------------------
3b. Pick-and-Place Collaboration
-----------------------------------------------------------
-/

/--
Illustrative pick-and-place state in which the human operator enters
the danger region.
-/
def pickAndPlaceDangerState : HRCState Nat :=
  dangerExampleState

/--
Illustrative pick-and-place state containing a robot-velocity
violation.
-/
def pickAndPlaceVelocityViolationState : HRCState Nat :=
  velocityViolationExampleState

theorem pickAndPlaceDanger_risk :
    monitorRisk exampleConfig pickAndPlaceDangerState =
      .danger := by
  decide

theorem pickAndPlaceDanger_action :
    monitorAction exampleConfig pickAndPlaceDangerState =
      .protectiveStop := by
  decide

theorem pickAndPlaceVelocityViolation_risk :
    monitorRisk exampleConfig
      pickAndPlaceVelocityViolationState = .warning := by
  decide

theorem pickAndPlaceVelocityViolation_action :
    monitorAction exampleConfig
      pickAndPlaceVelocityViolationState = .reduceSpeed := by
  decide


/-
-----------------------------------------------------------
3c. Warehouse Mobile Robotics
-----------------------------------------------------------
-/

/--
Illustrative warehouse state in which a worker enters the warning
region of an autonomous mobile robot.
-/
def warehouseAMRWarningState : HRCState Nat :=
  warningExampleState

/--
Illustrative warehouse state in which a worker enters the danger
region of an autonomous mobile robot.
-/
def warehouseAMRDangerState : HRCState Nat :=
  dangerExampleState

theorem warehouseAMRWarning_action :
    monitorAction exampleConfig warehouseAMRWarningState =
      .reduceSpeed := by
  decide

theorem warehouseAMRDanger_action :
    monitorAction exampleConfig warehouseAMRDangerState =
      .protectiveStop := by
  decide

theorem warehouseAMRDanger_prevents_continuation :
    monitorAction exampleConfig warehouseAMRDangerState ≠
      .continueOperation := by
  apply danger_prevents_continuation
  decide


/-
-----------------------------------------------------------
3d. Surgical Robotic Assistance
-----------------------------------------------------------
-/

/--
Illustrative surgical-assistance state in which the measured
interaction force exceeds the configured safety limit.
-/
def surgicalForceViolationState : HRCState Nat :=
  forceViolationExampleState

/--
Illustrative surgical-assistance state containing an emergency
condition.
-/
def surgicalEmergencyState : HRCState Nat :=
  emergencyExampleState

theorem surgicalForceViolation_risk :
    monitorRisk exampleConfig surgicalForceViolationState =
      .danger := by
  decide

theorem surgicalForceViolation_action :
    monitorAction exampleConfig surgicalForceViolationState =
      .protectiveStop := by
  decide

theorem surgicalEmergency_risk :
    monitorRisk exampleConfig surgicalEmergencyState =
      .emergency := by
  decide

theorem surgicalEmergency_action :
    monitorAction exampleConfig surgicalEmergencyState =
      .emergencyStop := by
  decide

theorem surgicalEmergency_sound :
    allowed
      (monitorRisk exampleConfig surgicalEmergencyState)
      (monitorAction exampleConfig surgicalEmergencyState) := by
  exact monitor_sound exampleConfig surgicalEmergencyState


/-
-----------------------------------------------------------
3e. Human-Free Autonomous Operation
-----------------------------------------------------------
-/

/--
Illustrative autonomous-operation state in which no human is detected
in the monitored workspace.
-/
def autonomousRobotOnlyState : HRCState Nat :=
  absentHumanExampleState

theorem autonomousRobotOnly_risk :
    monitorRisk exampleConfig autonomousRobotOnlyState =
      .safe := by
  decide

theorem autonomousRobotOnly_action :
    monitorAction exampleConfig autonomousRobotOnlyState =
      .continueOperation := by
  decide


/-
-----------------------------------------------------------
3f. Cross-Domain Monitor Results
-----------------------------------------------------------
-/

/--
Representative monitor results constructed from the illustrative
cross-domain instantiations above.
-/
def crossDomainResults : List NamedMonitorResult :=
  [
    runNamedScenario
      "Collaborative welding: safe region"
      weldingSafeState,

    runNamedScenario
      "Collaborative welding: warning region"
      weldingWarningState,

    runNamedScenario
      "Pick-and-place: velocity violation"
      pickAndPlaceVelocityViolationState,

    runNamedScenario
      "Warehouse AMR: danger region"
      warehouseAMRDangerState,

    runNamedScenario
      "Surgical robot: force violation"
      surgicalForceViolationState,

    runNamedScenario
      "Surgical robot: emergency"
      surgicalEmergencyState,

    runNamedScenario
      "Autonomous operation: human absent"
      autonomousRobotOnlyState
  ]

/--
The risk sequence generated by the illustrative cross-domain
instantiations.
-/
def crossDomainRisks : List RiskLevel :=
  crossDomainResults.map NamedMonitorResult.risk

/--
The action sequence generated by the illustrative cross-domain
instantiations.
-/
def crossDomainActions : List MonitorAction :=
  crossDomainResults.map NamedMonitorResult.action

/--
The executable monitor produces the expected risk sequence across
the illustrative cross-domain instantiations.
-/
theorem crossDomainRisks_correct :
    crossDomainRisks =
      [
        .safe,
        .warning,
        .warning,
        .danger,
        .danger,
        .emergency,
        .safe
      ] := by
  decide

/--
The executable monitor produces the expected action sequence across
the illustrative cross-domain instantiations.
-/
theorem crossDomainActions_correct :
    crossDomainActions =
      [
        .continueOperation,
        .reduceSpeed,
        .reduceSpeed,
        .protectiveStop,
        .protectiveStop,
        .emergencyStop,
        .continueOperation
      ] := by
  decide


/-
===========================================================
4. Reusable Correctness Guarantees
===========================================================
-/

/--
Every state evaluated using `exampleConfig` receives an action
permitted by the common runtime safety policy.
-/
theorem application_monitor_sound
    (s : HRCState Nat) :
    allowed
      (monitorRisk exampleConfig s)
      (monitorAction exampleConfig s) := by
  exact monitor_sound exampleConfig s

/--
For every state evaluated using `exampleConfig`, the monitor selects
an action whose severity is minimum among all actions permitted for
the assessed risk level.
-/
theorem application_monitor_minimal
    (s : HRCState Nat)
    (a : MonitorAction)
    (hAllowed :
      allowed (monitorRisk exampleConfig s) a) :
    actionSeverity (monitorAction exampleConfig s) ≤
      actionSeverity a := by
  exact
    monitor_minimal_intervention
      exampleConfig
      s
      a
      hAllowed

/--
Any state evaluated using `exampleConfig` for which the monitor
continues operation must have been classified as safe.
-/
theorem application_no_unsafe_continuation
    (s : HRCState Nat)
    (h :
      monitorAction exampleConfig s =
        .continueOperation) :
    monitorRisk exampleConfig s = .safe := by
  exact no_unsafe_continuation exampleConfig s h


/-
===========================================================
5. Executable Demonstration
===========================================================
-/

#eval runNamedScenario
  "Collaborative welding: warning region"
  weldingWarningState

#eval runNamedScenario
  "Pick-and-place: danger region"
  pickAndPlaceDangerState

#eval runNamedScenario
  "Warehouse AMR: warning region"
  warehouseAMRWarningState

#eval runNamedScenario
  "Surgical robot: force violation"
  surgicalForceViolationState

#eval runNamedScenario
  "Autonomous operation: human absent"
  autonomousRobotOnlyState

#eval crossDomainRisks

#eval crossDomainActions

#eval crossDomainResults

end Examples
end LeanSafeHRC
