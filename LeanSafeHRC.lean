/-
Copyright (c) 2026 Adnan Rashid.
School of Electrical Engineering and Computer Science (SEECS)
National University of Sciences and Technology (NUST)
Islamabad, Pakistan

LeanSafeHRC: A Lean 4 Framework for Verified Runtime
Safety Monitoring in Human–Robot Collaboration

File: LeanSafeHRC.lean

Root library module for the LeanSafeHRC formal development.

The imported modules provide:

1. Basic        - Core datatypes, safety configurations, and HRC states
2. Ordering     - Risk-severity and action-severity orderings
3. Risk         - Executable runtime risk assessment
4. Policy       - Executable and logical runtime safety policy
5. Monitor      - Executable monitor construction
6. Correctness  - Machine-checked correctness guarantees
7. CaseStudy    - Collaborative-assembly case study reported in the paper
8. Examples     - Additional illustrative examples and smoke tests

Importing `LeanSafeHRC` therefore makes the complete formal development
available as a single library.
-/

import LeanSafeHRC.Basic
import LeanSafeHRC.Ordering
import LeanSafeHRC.Risk
import LeanSafeHRC.Policy
import LeanSafeHRC.Monitor
import LeanSafeHRC.Correctness
import LeanSafeHRC.CaseStudy
import LeanSafeHRC.Examples
