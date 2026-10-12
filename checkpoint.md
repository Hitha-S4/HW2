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

This one-suite smoke test is intentional: it verifies the command, target-class restriction, generated file format, and repair process before producing the full 100-suite dataset.
