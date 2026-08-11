/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: Verified Executable Runtime Safety Monitoring for
Human-Robot Collaboration

File: Main.lean

This file provides the executable entry point for the LeanSafeHRC
artifact.

Running this executable demonstrates:

1. The collaborative-assembly case study reported in the paper.
2. Additional illustrative examples showing reuse of the same
   verified monitoring framework across different application contexts.

The additional examples are demonstrations of framework reuse and are
not additional evaluated case studies reported in the paper.
-/

import LeanSafeHRC

open LeanSafeHRC
open LeanSafeHRC.CaseStudy
open LeanSafeHRC.Examples


/-
===========================================================
1. Monitor-Result Display
===========================================================
-/

/--
Executes the verified monitor for a single runtime state and prints
the resulting qualitative risk level and canonical monitor action.
-/
def printMonitorResult
    (name : String)
    (s : HRCState Nat) : IO Unit := do
  let result := runMonitor exampleConfig s

  IO.println s!"Scenario: {name}"
  IO.println s!"  Risk:   {repr result.risk}"
  IO.println s!"  Action: {repr result.action}"
  IO.println ""


/-
===========================================================
2. Collaborative-Assembly Case Study
===========================================================
-/

/--
Runs the seven collaborative-assembly scenarios reported in the
paper using the executable LeanSafeHRC monitor.
-/
def runCollaborativeAssemblyDemo : IO Unit := do
  IO.println "=================================================="
  IO.println "LeanSafeHRC Collaborative-Assembly Case Study"
  IO.println "=================================================="
  IO.println "Case study reported in the paper"
  IO.println ""

  printMonitorResult
    "S1 - Robot-only operation"
    robotOnlyOperationState

  printMonitorResult
    "S2 - Human in safe region"
    humanInSafeRegionState

  printMonitorResult
    "S3 - Human in warning region"
    humanInWarningRegionState

  printMonitorResult
    "S4 - Velocity-limit violation"
    excessiveVelocityState

  printMonitorResult
    "S5 - Human in danger region"
    humanInDangerRegionState

  printMonitorResult
    "S6 - Force-limit violation"
    excessiveForceState

  printMonitorResult
    "S7 - Critical emergency"
    criticalEmergencyState


/-
===========================================================
3. Additional Illustrative Examples
===========================================================
-/

/--
Prints the monitor result associated with a named illustrative
application scenario.
-/
def printNamedMonitorResult
    (result : NamedMonitorResult) : IO Unit := do
  IO.println s!"Scenario: {result.scenario}"
  IO.println s!"  Risk:   {repr result.risk}"
  IO.println s!"  Action: {repr result.action}"
  IO.println ""

/--
Runs additional illustrative examples demonstrating reuse of the
same verified monitoring framework.

These examples are not additional evaluated case studies from the
paper.
-/
def runCrossDomainDemo : IO Unit := do
  IO.println "=================================================="
  IO.println "Additional Illustrative Examples"
  IO.println "=================================================="
  IO.println "Demonstrations of framework reuse"
  IO.println ""

  for result in crossDomainResults do
    printNamedMonitorResult result


/-
===========================================================
4. Verification Summary
===========================================================
-/

/--
Prints the principal machine-checked correctness guarantees
established in `Correctness.lean`.
-/
def printVerificationSummary : IO Unit := do
  IO.println "=================================================="
  IO.println "Machine-Checked Correctness Guarantees"
  IO.println "=================================================="
  IO.println ""
  IO.println "The LeanSafeHRC development establishes:"
  IO.println "  - policy soundness"
  IO.println "  - deterministic and risk-responsive behaviour"
  IO.println "  - safe continuation"
  IO.println "  - minimal intervention"
  IO.println ""


/-
===========================================================
5. Complete Executable Demonstration
===========================================================
-/

/--
Main executable entry point for the LeanSafeHRC artifact.
-/
def main : IO Unit := do
  IO.println ""
  IO.println "LeanSafeHRC"
  IO.println "Verified Runtime Safety Monitoring in Lean 4"
  IO.println ""

  runCollaborativeAssemblyDemo
  runCrossDomainDemo
  printVerificationSummary
