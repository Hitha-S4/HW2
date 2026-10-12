# Homework 2 Implementation Checkpoint

## Checkpoint 1: Tool setup and baseline verification

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

The first implementation part was tool setup and baseline verification. The following components are now installed and usable:

- Defects4J 3.0.1 checkout in `defects4j-master/`
- Java 11.0.32.1
- Major 3.0.1, installed by the Defects4J initialization script
- EvoSuite 1.1.0, installed by the Defects4J initialization script
- EvoSuite standalone runtime 1.1.0
- Defects4J project repositories
- Required Defects4J Perl dependencies
- `wget`, required by the Defects4J macOS initialization script
- `cpanminus`, used to install the Perl dependencies

The required Java version was not initially available. The machine had Java 26, which Defects4J correctly rejected. Java 11 was installed with Homebrew and is now selected explicitly through `JAVA_HOME` whenever Defects4J commands are run.

The Defects4J Perl dependencies were also initially incomplete. The missing `String::Interpolate` module prevented all Defects4J commands from starting. The complete dependency set from `defects4j-master/cpanfile` was installed into the user Perl library at:

```text
~/perl5/lib/perl5
```

The `PERL5LIB` variable must therefore be set in experiment shells.

## Validation performed

The following checks passed with Java 11 and the required Perl library path:

```bash
defects4j pids
defects4j bids -p Cli
defects4j info -p Cli -b 1
gen_tests.pl -g help
run_mutation.pl --help
```

The checks confirmed:

- Defects4J recognizes all bundled projects.
- `Cli` exposes its active bug IDs.
- Defects4J can read project and bug metadata.
- Defects4J recognizes EvoSuite as a supported test generator.
- Defects4J recognizes the Major mutation-analysis wrapper.
- Bug metadata identifies modified source classes; for example, `Cli-1` modifies `org.apache.commons.cli.CommandLine`.

The exact Java version used for validation was:

```text
openjdk version "11.0.32.1"
```

The initialized Defects4J installation reports:

```text
Defects4J version 3
Major v3.0.1
EvoSuite v1.1.0
```

## Required shell environment

Use this setup at the beginning of future experiment shells:

```bash
cd /Users/hitha/Documents/SEM-1/SE-520/HW2

export D4J="$PWD/defects4j-master"
export JAVA_HOME=/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:$D4J/framework/bin:$PATH"
export TZ=America/Los_Angeles
```

`JAVA_HOME` is set explicitly because the default system Java is newer than the Java version supported by Defects4J 3.x. `PERL5LIB` is set explicitly because the CPAN modules were installed for the current user rather than system-wide.

## Why this part was necessary

The assignment depends on all three tools working before any defect can be selected or any artifacts can be generated:

- Defects4J provides the fixed bug versions, modified-class metadata, checkout, compilation, testing, and orchestration scripts.
- EvoSuite generates the required test suites.
- Major generates the mutant logs, kill matrices, and summaries.

Verifying the command-line wrappers before generating artifacts prevents producing invalid suites or mutation results with the wrong Java version, missing dependencies, or uninitialized tool data.

## Not started yet

The following work was intentionally not started in Checkpoint 1:

- Selecting the final Defects4J project.
- Selecting the five defects.
- Checking out a final defect set.
- Generating EvoSuite suites.
- Repairing or validating generated suites.
- Running Major mutation analysis.
- Writing the final assignment README.
- Creating the final submission ZIP.

No homework test suites or mutation-analysis artifacts have been generated yet.

## Next part

The next implementation part is **candidate project/defect selection**:

1. Exclude the paper's projects: `Chart`, `Closure`, `Math`, `Time`, and `Lang`.
2. Inspect candidate projects and bug metadata.
3. Try fixed-version checkout/compile checks for candidate defects.
4. Select one non-paper project and five workable defects.
5. Record the selection and metadata in the next checkpoint update before generating suites.

---

## Checkpoint 2: Project and defect selection

**Date:** 2026-10-11  
**Status:** Complete

## Selected project

The selected Defects4J project is:

```text
Cli (Apache Commons CLI)
```

This is eligible because the paper used `Chart`, `Closure`, `Math`, `Time`, and `Lang`; it did not use `Cli`.

## Selected defects

The five selected defects are:

```text
Cli-1
Cli-2
Cli-3
Cli-4
Cli-5
```

These five were selected because they are active defects in the installed Defects4J 3.0.1 metadata, have available fixed revisions, compile successfully with the required Java 11 runtime, and pass their fixed-version developer test suites.

| Defect | Fixed revision | Bug report | Modified source class | Defects4J triggering test |
|---|---|---|---|---|
| Cli-1 | `b0e1b80b6d4a10a9c9f46539bc4c7a3cce55886e` | `CLI-13` | `org.apache.commons.cli.CommandLine` | `org.apache.commons.cli.bug.BugCLI13Test::testCLI13` |
| Cli-2 | `2ff9573ffb08dd52ec3a55a49f2d77a1e94efbdf` | `CLI-51` | `org.apache.commons.cli.PosixParser` | `org.apache.commons.cli.bug.BugCLI51Test::test` |
| Cli-3 | `d35f2fa7a06457469a617677eeb4c1dc21484006` | `cli-1` | `org.apache.commons.cli.TypeHandler` | `org.apache.commons.cli.PatternOptionBuilderTest::testSimplePattern` |
| Cli-4 | `f78959477b207bf710049aa35730ef7659f0a1b9` | `cli-1` | `org.apache.commons.cli.Parser` | `org.apache.commons.cli.OptionsTest::testMissingOptionsException`; `org.apache.commons.cli.OptionsTest::testMissingOptionException` |
| Cli-5 | `3880640ee6268a2ecb2912e1ae896153dc2229e5` | `CLI-133` | `org.apache.commons.cli.Util` | `org.apache.commons.cli.UtilTest::testStripLeadingHyphens`; `org.apache.commons.cli.bug.BugCLI133Test::testOrder` |

The fixed revision identifiers and modified classes were obtained with:

```bash
defects4j info -p Cli -b <BugID>
```

## Validation performed

For each selected defect, a fixed checkout was created outside the submission directory:

```text
/tmp/cs520_cli_1_fixed
/tmp/cs520_cli_2_fixed
/tmp/cs520_cli_3_fixed
/tmp/cs520_cli_4_fixed
/tmp/cs520_cli_5_fixed
```

Each checkout was validated with:

```bash
defects4j compile
defects4j test
```

Results:

| Defect | Fixed source compilation | Fixed developer tests |
|---|---|---|
| Cli-1 | Passed | Passed; 0 failing tests |
| Cli-2 | Passed | Passed; 0 failing tests |
| Cli-3 | Passed | Passed; 0 failing tests |
| Cli-4 | Passed | Passed; 0 failing tests |
| Cli-5 | Passed | Passed; 0 failing tests |

## Why this selection was necessary

Homework 2 requires one project not used in the paper and five defects from that project. The five fixed-version test checks are an early feasibility gate: EvoSuite and Major both require a compilable fixed version, and all final generated tests must pass against that fixed version.

The selected defects also give five separate modified target classes:

```text
CommandLine
PosixParser
TypeHandler
Parser
Util
```

This makes it straightforward to verify that each EvoSuite run and Major run is restricted to the classes modified by the corresponding defect.

## Not started yet

The following work remains intentionally unstarted:

- Creating the final artifact directory.
- Generating EvoSuite suites.
- Choosing and recording the 20 seeds per defect.
- Repairing generated suites.
- Running five consecutive fixed-version passes for each retained suite.
- Running Major mutation analysis.
- Copying mutant logs, kill matrices, and summaries.
- Writing the final assignment README.
- Creating the final submission ZIP.

## Next part

The next implementation part is a **single-defect EvoSuite smoke test** for `Cli-1`:

1. Generate one fixed-version EvoSuite suite targeting `org.apache.commons.cli.CommandLine`.
2. Use a recorded seed and a small initial time budget.
3. Confirm the generated source layout and tool output.
4. Repair the suite with Defects4J's five-pass test-suite repair workflow.
5. Validate the repaired suite before scaling to 20 suites per defect.

---

## Checkpoint 3: `Cli-1` EvoSuite smoke test

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

A single EvoSuite suite was generated for the fixed version of `Cli-1` using:

```text
Project: Cli
Version: 1f
Suite number: 1
Seed: 20261001
Time budget: 60 seconds
Generator: EvoSuite 1.1.0
```

The generation command was:

```bash
gen_tests.pl \
  -g evosuite \
  -p Cli \
  -v 1f \
  -n 1 \
  -o /tmp/cs520_hw2_smoke/generated \
  -b 60 \
  -s 20261001
```

Defects4J generated the archive:

```text
/tmp/cs520_hw2_smoke/generated/Cli/evosuite/1/Cli-1f-evosuite.1.tar.bz2
```

The generation completed successfully and produced a suite for the modified class:

```text
org.apache.commons.cli.CommandLine
```

The generated archive contains:

```text
org/apache/commons/cli/CommandLine_ESTest.java
org/apache/commons/cli/CommandLine_ESTest_scaffolding.java
```

This confirms that the fixed-version generation path and the modified-class target restriction work for the selected project/defect.

## Suite repair and validation

The generated archive was copied to a flat repair-input directory because `fix_test_suite.pl` scans its input directory directly for Defects4J test archives:

```text
/tmp/cs520_hw2_smoke/repair/Cli-1f-evosuite.1.tar.bz2
```

The repair command was:

```bash
framework/util/fix_test_suite.pl \
  -p Cli \
  -d /tmp/cs520_hw2_smoke/repair \
  -v 1f \
  -s evosuite
```

The repair summary reported:

```text
Number of uncompilable test classes: 0
Number of uncompilable tests: 0
Number of failing tests: 0
```

The Defects4J repair workflow completed its required five consecutive fixed-version passes. The repaired archive remained available at:

```text
/tmp/cs520_hw2_smoke/repair/Cli-1f-evosuite.1.tar.bz2
```

## Setup corrections discovered during the smoke test

### Subversion

The first generation attempt stopped because Defects4J requires the `svn` executable during its environment check. Subversion was installed with Homebrew:

```text
subversion 1.15.0
```

Future shells must include:

```bash
export PATH="/opt/homebrew/opt/subversion/bin:$PATH"
```

### JUnit/Hamcrest compatibility path

The initialized Defects4J checkout did not provide the path expected by the `Cli` build file:

```text
framework/projects/lib/junit-4.12.jar
```

The `Cli` EvoSuite run also requires Hamcrest at runtime. The compatibility path now points to the bundled combined JUnit/Hamcrest artifact:

```text
framework/projects/lib/junit-4.12-hamcrest-1.3.jar
```

The resulting symlink is:

```text
framework/projects/lib/junit-4.12.jar
  -> framework/projects/lib/junit-4.12-hamcrest-1.3.jar
```

This setup-only compatibility correction was necessary because the otherwise successful generated tests could not start without `org.hamcrest.SelfDescribing`.

## Why this part was necessary

Before scaling to 20 suites per defect, the smoke test verifies the complete first half of the artifact pipeline:

1. Defects4J can check out the selected fixed version.
2. EvoSuite can generate tests using the selected Java/tool versions.
3. The generation is restricted to the bug-fix-modified class.
4. The generated archive has the expected Java source files.
5. Defects4J can compile and execute the generated suite.
6. The repair workflow can establish five consecutive fixed-version passes.

Finding the missing Subversion executable and JUnit/Hamcrest compatibility path here prevents the same failures from being repeated across 100 final suite-generation runs.

## Not started yet

The following work remains intentionally unstarted:

- Generating the remaining 19 suites for `Cli-1`.
- Generating suites for `Cli-2` through `Cli-5`.
- Building the final `test_suites/suiteNN/` submission directories.
- Running Major mutation analysis.
- Copying mutant logs, kill matrices, and summaries.
- Writing the final assignment README.
- Creating the final submission ZIP.

The smoke archive is a temporary validation artifact under `/tmp`; it is not yet part of the final submission directory.

## Next part

The next implementation part is **scaling EvoSuite generation and repair**:

1. Create the working artifact tree for `Cli-1` through `Cli-5`.
2. Generate 20 suites per defect with distinct recorded seeds.
3. Repair each suite using the flat-archive workflow.
4. Confirm zero uncompilable/failing tests and five consecutive fixed-version passes.
5. Extract/copy the repaired Java files into `test_suites/suite01` through `suite20`.
6. Maintain a seed and validation manifest before starting Major.

---

## Checkpoint 4: Complete EvoSuite generation for `Cli-1`

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

The validated smoke-test workflow was scaled to all 20 required suites for `Cli-1`.

Configuration:

```text
Project: Cli
Defect: 1
Version: 1f
Generator: EvoSuite 1.1.0
Time budget per suite: 60 seconds
Suite seeds: 20261001 through 20261020
Target class: org.apache.commons.cli.CommandLine
```

Every suite:

- Was generated against the fixed version `Cli-1f`.
- Used a distinct random seed.
- Targeted the bug-fix-modified class.
- Was repaired using `fix_test_suite.pl`.
- Had 0 uncompilable test classes.
- Had 0 uncompilable tests.
- Had 0 failing tests.
- Completed the five consecutive fixed-version validation runs.

## Artifact location

The final `Cli-1` generated source files are stored at:

```text
artifacts/Cli-1/test_suites/suite01/
artifacts/Cli-1/test_suites/suite02/
...
artifacts/Cli-1/test_suites/suite20/
```

Each suite currently contains two Java source files:

```text
CommandLine_ESTest.java
CommandLine_ESTest_scaffolding.java
```

The suite-generation and repair working data is outside the final suite tree:

```text
artifacts/work/Cli-1/
```

The recorded manifest is:

```text
artifacts/Cli-1/manifest.csv
```

It contains exactly 20 suite records and records the project, defect, suite number, seed, budget, archive path, validation status, and Java-file count.

## Automation added

The repeatable workflow is implemented in:

[generate_and_repair_evOSuite.sh](/Users/hitha/Documents/SEM-1/SE-520/HW2/generate_and_repair_evOSuite.sh)

The script:

1. Generates each fixed-version EvoSuite archive.
2. Gives every suite a deterministic distinct seed.
3. Places each archive in an isolated repair directory.
4. Runs Defects4J's five-pass repair workflow.
5. Checks the repair summary for zero uncompilable/failing tests.
6. Extracts the repaired Java files into the required `suiteNN` directory.
7. Writes a CSV manifest.

The isolated repair directory is important because `fix_test_suite.pl` scans all archives in its input directory. Keeping one archive per repair directory prevents a later run from accidentally reprocessing earlier suites.

## Verification

The final `Cli-1` checks reported:

```text
Manifest records: 20
Validated suites: 20
Java source files: 40
```

The 40 Java files correspond to two generated source files per suite across 20 suites.

## Manifest correction

The first version of the helper script wrote literal `\n` characters into the CSV because of an escaping mistake. This was corrected before final verification. The manifest was regenerated and now contains normal newline-delimited CSV records.

## Why this part was necessary

Homework 2 requires 20 separate EvoSuite suites per defect, not one suite copied 20 times. This checkpoint proves that:

- The seeds are distinct.
- The suites are distinct generation outputs.
- The fixed-version repair requirement is satisfied.
- The Java sources are present in the required submission layout.
- The process is reproducible enough to scale to the remaining four defects.

## Not started yet

- EvoSuite suites for `Cli-2` through `Cli-5`.
- Major mutation analysis for any defect.
- Final mutation output directories.
- Final assignment README.
- Final submission ZIP.

## Next part

Run the same generation/repair workflow for `Cli-2`, `Cli-3`, `Cli-4`, and `Cli-5`, using distinct seed ranges per defect:

```text
Cli-2: 20262001 through 20262020
Cli-3: 20263001 through 20263020
Cli-4: 20264001 through 20264020
Cli-5: 20265001 through 20265020
```

After all 100 suites are validated, begin Major mutation analysis one suite at a time and archive every mutant log, kill matrix, and summary immediately.

---

## Checkpoint 5: Complete EvoSuite generation for `Cli-2`

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

The validated generation and repair workflow was run for all 20 required suites for `Cli-2`.

Configuration:

```text
Project: Cli
Defect: 2
Version: 2f
Generator: EvoSuite 1.1.0
Time budget per suite: 60 seconds
Suite seeds: 20262001 through 20262020
Target class: org.apache.commons.cli.PosixParser
```

Every suite:

- Was generated against the fixed version `Cli-2f`.
- Used a distinct seed.
- Targeted `org.apache.commons.cli.PosixParser`, the modified class reported by Defects4J.
- Was repaired using the Defects4J repair workflow.
- Had 0 uncompilable test classes.
- Had 0 uncompilable tests.
- Had 0 failing tests.
- Completed five consecutive fixed-version passes.

## Artifact location

The final Java sources are stored at:

```text
artifacts/Cli-2/test_suites/suite01/
artifacts/Cli-2/test_suites/suite02/
...
artifacts/Cli-2/test_suites/suite20/
```

The working archives and logs are stored separately under:

```text
artifacts/work/Cli-2/
```

The seed and validation manifest is:

```text
artifacts/Cli-2/manifest.csv
```

## Verification

The final `Cli-2` checks reported:

```text
Manifest records: 20
Validated suites: 20
Java source files: 40
```

All 20 records have status:

```text
passed-five-fixed-runs
```

## Not started yet

- EvoSuite suites for `Cli-3`, `Cli-4`, and `Cli-5`.
- Major mutation analysis.
- Final mutation output directories.
- Final assignment README.
- Final submission ZIP.

## Next part

Run the same workflow for `Cli-3`, using seeds `20263001` through `20263020` and target class `org.apache.commons.cli.TypeHandler`.

This one-suite smoke test is intentional: it verifies the command, target-class restriction, generated file format, and repair process before producing the full 100-suite dataset.

---

## Checkpoint 6: Complete `Cli-3` EvoSuite suite generation

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

Generated, repaired, and extracted 20 EvoSuite suites for the fixed version of
`Cli-3`, targeting the modified class:

```text
org.apache.commons.cli.TypeHandler
```

The suites use seeds `20263001` through `20263020` and a 60-second EvoSuite
budget per suite. Each final suite directory contains the repaired Java test
source and its generated scaffolding source.

## Validation correction

Several earlier `Cli-3` attempts were incorrectly marked as invalid. The
Defects4J repair summary fields:

```text
Number of uncompilable tests
Number of failing tests
```

count tests removed during repair; they do not mean that invalid tests remain
after repair. The helper script was corrected to use the repair command's
successful exit status, the repaired archive, and the completed repair
summary as the validation criteria. A nonzero removed-test count is therefore
compatible with a valid repaired suite.

The corrected workflow regenerated suite 9 and re-extracted the repaired
source. All 20 suites now contain Java sources.

## Artifact location

```text
artifacts/Cli-3/test_suites/suite01/
artifacts/Cli-3/test_suites/suite02/
...
artifacts/Cli-3/test_suites/suite20/
```

The generation and repair evidence is under:

```text
artifacts/work/Cli-3/
```

The normalized manifest is:

```text
artifacts/Cli-3/manifest.csv
```

It contains exactly one final row for each suite, with the recorded seed,
budget, archive path, repair status, and Java-file count.

## Verification

```text
Manifest records: 20
Suite directories: 20
Suite directories containing Java sources: 20
Java source files: 40
```

## Next part

Generate and validate 20 repaired EvoSuite suites for `Cli-4`, then repeat the
same workflow for `Cli-5`. After all 100 suites are complete, run Major with
the required operator set:

```text
AOR LOR SOR COR ROR ORU LVR STD
```

---

## Checkpoint 7: Complete EvoSuite dataset

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

Generated and repaired the remaining 40 EvoSuite suites:

- `Cli-4`, suites 1-20, targeting `org.apache.commons.cli.Parser`
- `Cli-5`, suites 1-20, targeting `org.apache.commons.cli.Util`

The seeds are recorded in the manifests as:

```text
Cli-4: 20264001 through 20264020
Cli-5: 20265001 through 20265020
```

The helper script was also strengthened so extraction failures or repaired
archives with no Java files are reported explicitly instead of being marked
valid.

## Final EvoSuite inventory

| Defect | Manifest records | Suite directories | Java source files |
|---|---:|---:|---:|
| `Cli-1` | 20 | 20 | 40 |
| `Cli-2` | 20 | 20 | 40 |
| `Cli-3` | 20 | 20 | 40 |
| `Cli-4` | 20 | 20 | 40 |
| `Cli-5` | 20 | 20 | 40 |
| **Total** | **100** | **100** | **200** |

Every manifest has exactly one record per suite number, and every final suite
directory contains Java source files. The source layout is:

```text
artifacts/Cli-<bug>/test_suites/suiteNN/
```

The corresponding generation archives, repair summaries, and logs remain
under:

```text
artifacts/work/Cli-<bug>/
```

## Next part

Run Major mutation analysis once for each of the 100 repaired suites. Each run
must use the fixed version of the corresponding defect, mutate only that
defect's modified class, and enable exactly:

```text
AOR LOR SOR COR ROR ORU LVR STD
```

The mutation logs, kill matrices, and summary output must be copied into a
stable per-suite directory immediately after each run.

---

## Checkpoint 8: Major mutation-analysis workflow

**Date:** 2026-10-11  
**Status:** In progress

## What was completed

One complete Major mutation-analysis run was performed for `Cli-1` suite 1
using the fixed version `1f`. The verified command was:

```bash
run_mutation.pl -p Cli \
  -d <suite-archive-directory> \
  -v 1f \
  -o artifacts/Cli-1/mutation/suite01
```

The run used Major's default mutation operators, which are exactly the
assignment-required set:

```text
AOR LOR SOR COR ROR ORU LVR STD
```

No `-A` option was supplied, so Defects4J restricted mutation to the classes
modified by the selected bug fix.

The run produced and preserved:

```text
mutation_log/Cli/evosuite/1f.mutants.log
mutation_log/Cli/evosuite/1f.1.kill.csv
mutation_log/Cli/evosuite/1f.1.summary.csv
mutation_log/Cli/evosuite/1f.1.testMap.csv
mutation_log/Cli/evosuite/1f.1.log
mutation_log/Cli/run_mutation.pl.log
mutation
```

The repeatable runner [run_major_all.sh](/Users/hitha/Documents/SEM-1/SE-520/HW2/run_major_all.sh)
now creates one input archive directory per suite. This is important because
`run_mutation.pl` analyzes every archive in its input directory; isolating the
archive prevents one run from duplicating or overwriting results for another
suite.

The runner is currently processing the remaining 99 suites sequentially. Each
result is written directly to:

```text
artifacts/Cli-<bug>/mutation/suiteNN/
```

## Next part

Wait for the 100-run batch to finish, verify that every suite has a mutant log,
kill matrix, and summary, then write the final assignment README and inspect
the submission ZIP contents.

---

## Checkpoint 9: Complete Major mutation analysis

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

Major mutation analysis was run once for every repaired EvoSuite suite:

- 20 suites for `Cli-1`
- 20 suites for `Cli-2`
- 20 suites for `Cli-3`
- 20 suites for `Cli-4`
- 20 suites for `Cli-5`

This is 100 independent mutation-analysis runs. Every run used the fixed
Defects4J version (`1f` through `5f`) and the default Major target behavior,
which restricts mutation to the classes modified by the corresponding bug fix.
The operator set was:

```text
AOR LOR SOR COR ROR ORU LVR STD
```

## Required output verification

Every suite has all three required result categories:

```text
<bug>f.mutants.log
<bug>f.<suite>.kill.csv
<bug>f.<suite>.summary.csv
```

The complete output count is:

```text
Mutant logs: 100
Kill matrices: 100
Summary files: 100
```

Additional Major test maps and detailed logs were also preserved under each
suite's `mutation_log` directory. Results are stored at:

```text
artifacts/Cli-<bug>/mutation/suiteNN/
```

The repeatable runner is:

```text
run_major_all.sh
```

## Next part

Write and review the final README, verify the complete submission tree, remove
or exclude temporary checkout/build artifacts, create the required ZIP, and
inspect the ZIP listing.

---

## Checkpoint 10: README and submission packaging

**Date:** 2026-10-11  
**Status:** Complete

## What was completed

Created [README.md](/Users/hitha/Documents/SEM-1/SE-520/HW2/README.md) with:

- Student identity, collaboration statement, and truthful AI-use disclosure.
- Mutation-testing purpose in 80 words.
- Coupling-effect explanation in 84 words.
- Selected project and five defect IDs.
- Fixed revisions, modified classes, seeds, and artifact locations.
- Bug/fix descriptions and Section 3.2 classifications.
- Tool versions, environment settings, reproduction commands, and required
  Major operators.
- Final artifact counts and verification details.

The two required short-answer sections were checked to remain below the
100-word limit.

The final ZIP will be named:

```text
srinivas_hitha.zip
```

It will contain the README, five manifests, 100 repaired test-suite
directories, and 100 mutation-result directories. Defects4J checkouts,
compiled classes, build directories, and working generation/repair logs are
excluded from the submission package.

## Final ZIP verification

The package was created and inspected as:

```text
srinivas_hitha.zip
```

Verified ZIP contents:

```text
Java source files: 200
Kill matrices: 100
Summary files: 100
Mutant logs: 100
Forbidden checkout/build/class entries: 0
```

The corrected ZIP contains 1,821 files and is approximately 928 KB.

## Assignment PDF re-audit

The assignment PDF was re-read directly after packaging. It confirms that the
requirement is one Defects4J project with five defects from that project, not
two projects. The ZIP was corrected to place `README.md` and the five
`Cli-<BugID>/` directories directly at the ZIP root rather than under an
extra `artifacts/` directory.

The corrected final ZIP audit passes:

```text
Top-level entries: README.md, Cli-1, Cli-2, Cli-3, Cli-4, Cli-5
Suite directories: 100
Java source files: 200
Kill matrices: 100
Summary files: 100
Mutant logs: 100
Checked-out/build/class entries: 0
```
