# LeanSafeHRC

**LeanSafeHRC: Verified Executable Runtime Safety Monitoring for  Human-Robot Collaboration**

LeanSafeHRC is a Lean 4 framework for constructing executable runtime safety monitors for Human–Robot Collaboration (HRC) together with machine-checked correctness proofs.

The framework integrates runtime risk assessment, safety-policy evaluation, canonical action selection, executable monitor construction, and formal verification within a single Lean 4 development. The same definitions used to execute the monitor are therefore also used as the basis for proving its correctness properties.

The repository accompanies the research paper:

> **LeanSafeHRC: Verified Executable Runtime Safety Monitoring for Human-Robot Collaboration**

The formal development contains the complete Lean definitions, executable monitor, correctness theorems, collaborative-assembly case study, and additional illustrative examples.

---

## 1. Overview

LeanSafeHRC models the runtime monitoring pipeline as

```text
Observed HRC State
        |
        v
Runtime Risk Assessment
        |
        v
Runtime Safety Policy
        |
        v
Canonical Action Selection
        |
        v
Executable Monitor
```

The risk-assessment layer classifies the current runtime state into one of four qualitative risk levels:

```text
safe < warning < danger < emergency
```

The monitor can issue four increasingly restrictive actions:

```text
continueOperation < reduceSpeed < protectiveStop < emergencyStop
```

For each assessed risk level, the runtime safety policy specifies the set of permissible actions. The monitor then selects the least restrictive action permitted by that policy.

The resulting canonical correspondence is:

| Risk Level | Canonical Monitor Action |
|---|---|
| `safe` | `continueOperation` |
| `warning` | `reduceSpeed` |
| `danger` | `protectiveStop` |
| `emergency` | `emergencyStop` |

The formal development establishes that the resulting executable monitor satisfies the specified runtime safety policy and selects a minimum-severity permissible intervention.

---

## 2. Repository Structure

The principal files are organized as follows:

```text
LeanSafeHRC/
|
|-- LeanSafeHRC.lean
|-- Main.lean
|-- lakefile.toml
|-- lake-manifest.json
|-- lean-toolchain
|-- README.md
|
`-- LeanSafeHRC/
    |-- Basic.lean
    |-- Ordering.lean
    |-- Risk.lean
    |-- Policy.lean
    |-- Monitor.lean
    |-- Correctness.lean
    |-- CaseStudy.lean
    `-- Examples.lean
```

### `Basic.lean`

Defines the foundational datatypes and structures used throughout the framework, including:

- robot operating modes;
- monitor actions;
- human-presence information;
- qualitative risk levels;
- safety configurations; and
- observable HRC runtime states.

### `Ordering.lean`

Defines numerical severity measures and ordering relations for:

- qualitative risk levels; and
- runtime monitor actions.

For monitor actions, increasing severity represents increasingly restrictive intervention.

### `Risk.lean`

Implements the executable runtime risk-assessment layer.

The assessment combines:

- human presence;
- human–robot separation distance;
- robot velocity;
- interaction force; and
- emergency conditions.

Distance first determines a base risk classification. Independent velocity, force, and emergency conditions can then conservatively upgrade this classification. The risk-upgrading procedure is machine checked to be non-decreasing with respect to risk severity. In particular, a safety violation can preserve or increase the current risk severity, but can never reduce it.
This property is established by:

```lean
upgradeRisk_non_decreasing

### `Policy.lean`

Defines the runtime safety policy in three equivalent forms:

```text
allowedBool
    |
    v
  allowed
    |
    v
permissibleActions
```

`allowedBool` provides the executable Boolean policy checker.

`allowed` provides the corresponding logical proposition.

`permissibleActions` provides the set-theoretic representation used by selected correctness results.

The file also defines `minimumPermissibleAction`, which specifies the canonical least restrictive policy-compliant action associated with each risk level.

### `Monitor.lean`

Constructs the executable runtime monitor.

The main interfaces are:

```lean
monitorRisk
monitorAction
runMonitor
```

`monitorRisk` exposes the runtime risk classifier at the monitor level.

`monitorAction` selects the canonical action associated with the assessed risk.

`runMonitor` returns both the computed risk and selected action as a single `MonitorResult`.

### `Correctness.lean`

Contains the principal machine-checked correctness results for the runtime monitor.

These include:

- policy soundness;
- monitor determinism;
- risk-to-action responsiveness;
- action-to-risk characterizations;
- prevention of unsafe continuation; and
- minimal intervention.

### `CaseStudy.lean`

Contains the collaborative-assembly case study reported in the paper.

Seven representative runtime scenarios, S1--S7, exercise the complete qualitative risk range and corresponding canonical monitor actions.

### `Examples.lean`

Contains executable smoke tests and additional illustrative instantiations demonstrating reuse of the framework in different application contexts.

These examples are **not additional evaluated case studies reported in the paper**. They are provided to demonstrate executability and reuse of the common verified monitoring framework.

### `Main.lean`

Provides the executable entry point for the artifact.

It runs:

1. the seven collaborative-assembly scenarios reported in the paper; and
2. the additional illustrative cross-domain examples.

---

## 3. Lean Environment

The development has been tested with the Lean toolchain specified in `lean-toolchain`:

```text
leanprover/lean4:v4.33.0-rc1
```

The project uses Mathlib through the dependency specified in `lakefile.toml` and resolved in `lake-manifest.json`.

The repository should therefore be built using the provided Lean/Lake configuration rather than replacing the pinned toolchain or dependency versions.

---

## 4. Building the Formal Development

After cloning the repository, enter the project directory and run:

```bash
lake build
```

A successful build checks the LeanSafeHRC library, its machine-checked proofs, the case-study development, and the executable target configured for the project.

The repository has been tested with:

```bash
lake build
```

using the toolchain provided in `lean-toolchain`.

---

## 5. Running the Executable Monitor

The complete executable demonstration can be run using:

```bash
lake exe leansafehrc
```

The executable first evaluates the collaborative-assembly case study reported in the paper and then runs the additional illustrative examples.

The case-study portion reports the assessed risk and selected action for scenarios S1--S7.

---

## 6. Collaborative-Assembly Case Study

The paper evaluates the monitor using seven representative collaborative-assembly scenarios.

| Scenario | Characteristic | Expected Risk | Expected Action |
|---|---|---|---|
| S1 | Human absent | `safe` | `continueOperation` |
| S2 | Safe collaboration | `safe` | `continueOperation` |
| S3 | Proximity warning | `warning` | `reduceSpeed` |
| S4 | Velocity violation | `warning` | `reduceSpeed` |
| S5 | Proximity danger | `danger` | `protectiveStop` |
| S6 | Force violation | `danger` | `protectiveStop` |
| S7 | Emergency condition | `emergency` | `emergencyStop` |

The complete risk sequence is machine checked in `CaseStudy.lean`:

```text
[safe, safe, warning, warning, danger, danger, emergency]
```

The corresponding action sequence is:

```text
[continueOperation,
 continueOperation,
 reduceSpeed,
 reduceSpeed,
 protectiveStop,
 protectiveStop,
 emergencyStop]
```

These sequences are established by the theorems:

```lean
collaborativeAssemblyRisks_correct
collaborativeAssemblyActions_correct
```

---

## 7. Main Machine-Checked Correctness Results

The principal generic correctness results are contained in `Correctness.lean`.

### Policy Soundness

```lean
monitor_sound
```

establishes that the action selected by the executable monitor satisfies the logical runtime safety policy for the assessed risk.

The corresponding set-based result is:

```lean
monitor_mem_permissible
```

which establishes that the selected action belongs to the set of permissible actions.

### Monitor Determinism

```lean
monitor_deterministic
runMonitor_deterministic
```

establish uniqueness of the action and complete monitor result for a fixed safety configuration and runtime state.

### Risk-to-Action Responsiveness

The following theorems characterize the monitor response to each qualitative risk level:

```lean
safe_risk_implies_continue
warning_risk_implies_reduceSpeed
danger_risk_implies_protectiveStop
emergency_risk_implies_emergencyStop
```

### Safe Continuation

```lean
no_unsafe_continuation
```

establishes that if the monitor permits unrestricted continuation, then the assessed runtime risk must be `safe`.

Related results explicitly establish that warning, danger, and emergency classifications cannot result in unrestricted continuation.

### Minimal Intervention

```lean
monitor_minimal_intervention
```

establishes that the action selected by the monitor has severity no greater than that of any other action permitted by the safety policy for the assessed risk.

The corresponding set-based formulation is:

```lean
monitor_minimal_in_permissible_set
```

---

## 8. Paper-to-Lean Correspondence

The following table maps central concepts used in the paper to their Lean definitions and theorem names.

| Paper Concept | Lean Identifier | File |
|---|---|---|
| Robot operating mode | `RobotMode` | `Basic.lean` |
| Monitor action | `MonitorAction` | `Basic.lean` |
| Human presence | `HumanPresence` | `Basic.lean` |
| Runtime risk level | `RiskLevel` | `Basic.lean` |
| Safety configuration | `SafetyConfig` | `Basic.lean` |
| Runtime HRC state | `HRCState` | `Basic.lean` |
| Risk severity | `riskSeverity` | `Ordering.lean` |
| Action severity | `actionSeverity` | `Ordering.lean` |
| Distance-based risk | `baseRisk` | `Risk.lean` |
| Risk upgrading | `upgradeRisk` | `Risk.lean` |
| Non-decreasing risk upgrading | `upgradeRisk_non_decreasing` | `Risk.lean` |
| Runtime risk classifier | `riskLevel` | `Risk.lean` |
| Executable safety policy | `allowedBool` | `Policy.lean` |
| Logical safety policy | `allowed` | `Policy.lean` |
| Permissible-action set | `permissibleActions` | `Policy.lean` |
| Canonical action selection | `minimumPermissibleAction` | `Policy.lean` |
| Monitor-level risk | `monitorRisk` | `Monitor.lean` |
| Monitor action | `monitorAction` | `Monitor.lean` |
| Complete executable monitor | `runMonitor` | `Monitor.lean` |
| Policy Soundness | `monitor_sound` | `Correctness.lean` |
| Safe Continuation | `no_unsafe_continuation` | `Correctness.lean` |
| Minimal Intervention | `monitor_minimal_intervention` | `Correctness.lean` |
| S1--S7 runtime trace | `collaborativeAssemblyTrace` | `CaseStudy.lean` |
| Verified risk sequence | `collaborativeAssemblyRisks_correct` | `CaseStudy.lean` |
| Verified action sequence | `collaborativeAssemblyActions_correct` | `CaseStudy.lean` |

This correspondence is intended to make it straightforward to locate the formal definitions and proofs associated with the terminology and results presented in the paper.

---

## 9. Case-Study Proofs

In addition to executable evaluation, `CaseStudy.lean` instantiates the generic correctness results for representative collaborative-assembly states.

Examples include policy-soundness results such as:

```lean
robotOnlyOperation_sound
humanInWarningRegion_sound
humanInDangerRegion_sound
criticalEmergency_sound
```

prevention-of-unsafe-continuation results such as:

```lean
dangerRegion_prevents_continuation
excessiveForce_prevents_continuation
criticalEmergency_prevents_continuation
```

and case-specific minimal-intervention results:

```lean
warningRegion_minimal_intervention
dangerRegion_minimal_intervention
emergency_minimal_intervention
```

Thus, the case study is not only an executable trace: its monitoring decisions are connected directly to the generic correctness theorems through machine-checked Lean proofs.

---

## 10. Additional Illustrative Examples

`Examples.lean` contains additional examples involving:

- collaborative welding;
- collaborative pick-and-place;
- warehouse mobile robotics;
- surgical robotic assistance; and
- human-free autonomous operation.

These examples reuse the common reference states and safety configuration to demonstrate how the verified monitoring pipeline can be instantiated and executed in different illustrative application contexts.

They should not be interpreted as separate experimentally evaluated application case studies.

The corresponding cross-domain risk and action sequences are also checked by Lean through:

```lean
crossDomainRisks_correct
crossDomainActions_correct
```

---

## 11. Scope of the Formalization

The current formalization focuses on an executable qualitative runtime safety monitor.

Runtime risk is determined from:

- human presence;
- human--robot separation distance;
- robot velocity;
- interaction force; and
- emergency conditions.

The safety thresholds are supplied through `SafetyConfig`.

The formal verification establishes correctness and compliance **with respect to the formally specified monitoring policy and configuration**. Application-specific validation of numerical safety thresholds, sensing assumptions, and mitigation requirements is outside the scope of the current formal development.

The current framework evaluates individual runtime states and does not yet formalize temporal evolution, sensor uncertainty, probabilistic risk, continuous robot dynamics, or physical middleware integration.

---

## 12. Reproducing the Paper Case Study

To reproduce the executable results reported for the collaborative-assembly case study:

```bash
lake build
lake exe leansafehrc
```

The first seven scenarios printed by the executable correspond directly to S1--S7 in the paper.

The same results are independently represented as machine-checked statements in `CaseStudy.lean`, including:

```lean
collaborativeAssemblyRisks_correct
collaborativeAssemblyActions_correct
```

A successful `lake build` checks these theorems together with the remainder of the formal development.

---

## 13. Artifact Reproducibility

The repository includes:

```text
lean-toolchain
lakefile.toml
lake-manifest.json
```

to record the Lean toolchain, project configuration, and resolved dependencies used by the artifact.

For reproducibility, users are encouraged to retain these files when building the project.

The artifact has been checked successfully using:

```bash
lake build
lake exe leansafehrc
```

---

## 14. Copyright

Copyright (c) 2026 Adnan Rashid.

School of Electrical Engineering and Computer Science (SEECS)  
National University of Sciences and Technology (NUST)  
Islamabad, Pakistan