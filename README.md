# CS 520 Homework 2: Mutation-Testing Artifacts

## Identity and collaboration

- **Student:** Hitha Srinivas
- **Collaborators:** Worked alone.
- **AI tools:** Copilot SDK in VS Code was used to understand the homework and
  research paper, troubleshoot Defects4J/EvoSuite/Major setup, write the
  repeatable shell scripts, and verify artifact counts and output files. The
  generated artifacts were executed and checked locally with Defects4J,
  EvoSuite, and Major.

## Purpose of mutation testing

Mutation testing creates many program versions containing small artificial
faults called mutants. A test kills a mutant when it detects the mutant's
changed behavior. The mutation score, calculated from killed mutants divided
by considered mutants, is a proxy for test-suite effectiveness. It helps
evaluate tests when real faults are difficult to enumerate. Mutation testing
is not a guarantee: a mutant is only an approximation of a real fault, and
some real faults may not be represented by the chosen operators.

## Coupling effect

The coupling effect is the empirical assumption that tests able to detect
representative simple faults, such as mutation operators create, will also
detect more complex real faults coupled to them. Mutation analysis relies on
this relationship when it uses mutant detection as evidence of test quality.
The coupling effect is not universal: some real faults require a stronger or
different operator, or have no suitable mutant representation. Therefore a
high mutation score is useful evidence, not proof that every real defect will
be detected.

## Selected project and defects

The selected project is **Apache Commons CLI (`Cli`)**, which is not one of
the paper's projects (`Chart`, `Closure`, `Math`, `Time`, or `Lang`).

| Defect | Bug report | Fixed revision | Modified class | EvoSuite seed range |
|---|---|---|---|---|
| `Cli-1` | `CLI-13` | `b0e1b80b6d4a10a9c9f46539bc4c7a3cce55886e` | `org.apache.commons.cli.CommandLine` | `20261001`-`20261020` |
| `Cli-2` | `CLI-51` | `2ff9573ffb08dd52ec3a55a49f2d77a1e94efbdf` | `org.apache.commons.cli.PosixParser` | `20262001`-`20262020` |
| `Cli-3` | `CLI-1` | `d35f2fa7a06457469a617677eeb4c1dc21484006` | `org.apache.commons.cli.TypeHandler` | `20263001`-`20263020` |
| `Cli-4` | `CLI-1` | `f78959477b207bf710049aa35730ef7659f0a1b9` | `org.apache.commons.cli.Parser` | `20264001`-`20264020` |
| `Cli-5` | `CLI-133` | `3880640ee6268a2ecb2912e1ae896153dc2229e5` | `org.apache.commons.cli.Util` | `20265001`-`20265020` |

Each defect has 20 distinct seeds. The exact seed, budget, archive path, and
repair status are recorded in the corresponding `manifest.csv`.

The complete seed lists are:

```text
Cli-1: 20261001 20261002 20261003 20261004 20261005 20261006 20261007 20261008 20261009 20261010 20261011 20261012 20261013 20261014 20261015 20261016 20261017 20261018 20261019 20261020
Cli-2: 20262001 20262002 20262003 20262004 20262005 20262006 20262007 20262008 20262009 20262010 20262011 20262012 20262013 20262014 20262015 20262016 20262017 20262018 20262019 20262020
Cli-3: 20263001 20263002 20263003 20263004 20263005 20263006 20263007 20263008 20263009 20263010 20263011 20263012 20263013 20263014 20263015 20263016 20263017 20263018 20263019 20263020
Cli-4: 20264001 20264002 20264003 20264004 20264005 20264006 20264007 20264008 20264009 20264010 20264011 20264012 20264013 20264014 20264015 20264016 20264017 20264018 20264019 20264020
Cli-5: 20265001 20265002 20265003 20265004 20265005 20265006 20265007 20265008 20265009 20265010 20265011 20265012 20265013 20265014 20265015 20265016 20265017 20265018 20265019 20265020
```

## Bug and fix descriptions

These classifications use the three explanations from Section 3.2 of the
paper: strengthening an existing operator, adding a new operator, or having
no suitable operator/inherent limitation.

### `Cli-1` (`CLI-13`)

The defect is in `CommandLine`: the CLI-13 regression test requires an option
argument to be retrievable through both its short name (`d`) and long name
(`debug`), and requires both names to be recognized. The fix stores option
objects and resolves either name consistently, adding the corresponding option
equality/hash behavior. **Category:** no suitable operator or inherent
limitation, because the fault is an API/state-semantics change rather than a
simple arithmetic, logical, relational, constant, or statement transformation.

### `Cli-2` (`CLI-51`)

The defect is in `PosixParser`: when the `-t` option expects an argument,
`-something` must be accepted as that argument instead of being split and
reported as an unrecognized option. The fix preserves the complete token as
the argument and stops splitting it into short-option characters.
**Category:** mutation operator needs strengthening, because the behavior
depends on context-sensitive parsing and control flow rather than an ordinary
local operator replacement.

### `Cli-3` (`CLI-1`)

The defect is in `TypeHandler` and affects conversion of a numeric option
value; the regression test checks conversion of the number `4.5`. The fix
corrects the numeric type handling/conversion path. **Category:** no suitable
operator or inherent limitation. The fault concerns conversion behavior and
numeric semantics rather than a local mutation of an operator, literal, or
statement.

### `Cli-4` (`CLI-1`)

The defect is in `Parser` and produces incomplete error messages for missing
required options: the expected messages include `Missing required option(s):`
but the faulty output omits that prefix. The fix restores the required-option
message construction. **Category:** mutation operator needs strengthening.
The fault is in string construction and reporting logic; the default operators
do not directly model the relevant message-building change.

### `Cli-5` (`CLI-133`)

The defect is in `Util`: the CLI-133 regression test calls `hasOption(null)`,
which reaches `stripLeadingHyphens(null)` and causes a `NullPointerException`
instead of returning false. The fix adds a null guard before stripping
hyphens. **Category:** mutation operator needs strengthening, because this is
a defensive precondition/null-handling change not reliably represented by the
default local mutation operators.

## Environment and versions

- OS: macOS `26.6.2`
- Java used for all Defects4J, EvoSuite, and Major commands: OpenJDK 11.0.32.1
- Defects4J: 3.0.1
- EvoSuite: 1.1.0
- Major: 3.0.1
- Time zone: `America/Los_Angeles`

The Java 11 `JAVA_HOME`, Defects4J `D4J`, and user Perl `PERL5LIB` settings are
configured in both experiment scripts. The fixed-version test suites for all
five selected defects compiled and passed before suite generation.

## Reproduction commands

From this directory:

```bash
export D4J="$PWD/defects4j-master"
export JAVA_HOME=/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:/opt/homebrew/opt/subversion/bin:$D4J/framework/bin:$PATH"
export TZ=America/Los_Angeles
```

Generate and repair one complete 20-suite batch:

```bash
./generate_and_repair_evOSuite.sh Cli 1 1 20 60 20261000 artifacts
```

The corresponding seed bases are `20262000`, `20263000`, `20264000`, and
`20265000` for `Cli-2` through `Cli-5`. The command uses a 60-second budget
per EvoSuite suite and the fixed version (`<bug-id>f`). The repair workflow is
Defects4J's `fix_test_suite.pl`, including the five consecutive fixed-version
passes.

The underlying commands used by the generation script for one suite are:

```bash
gen_tests.pl -g evosuite -p Cli -v 1f -n 1 \
  -o artifacts/work/Cli-1/generated -b 60 -s 20261001

fix_test_suite.pl -p Cli \
  -d artifacts/work/Cli-1/repair/suite01 \
  -v 1f -s evosuite
```

The same commands were repeated for each defect and suite with the
corresponding fixed version, suite number, output directory, and recorded
seed.

Run Major for all 100 suites:

```bash
./run_major_all.sh artifacts
```

The underlying per-suite invocation is:

```bash
run_mutation.pl -p Cli \
  -d <one-suite-archive-directory> \
  -v <bug-id>f \
  -o artifacts/Cli-<bug-id>/mutation/suiteNN
```

Major uses the required default operators:

```text
AOR LOR SOR COR ROR ORU LVR STD
```

No `-A` option is passed; therefore mutation is restricted to the
bug-fix-modified class list.

## Artifact layout and verification

The workspace uses an `artifacts/` directory while the submitted ZIP places
the five defect directories directly at its root, as required by the
assignment:

```text
README.md
Cli-1/
  manifest.csv
  test_suites/suite01/ ... suite20/
  mutation/suite01/ ... suite20/
Cli-2/
Cli-3/
Cli-4/
Cli-5/
```

The final inventory is:

- 5 defects
- 20 repaired EvoSuite suites per defect
- 100 suites total
- 200 Java source files total
- 100 Major mutant logs
- 100 Major kill matrices
- 100 Major summary files

Each mutation suite also preserves Major's test map and detailed logs under
`mutation/suiteNN/mutation_log/`. Checked-out Defects4J projects are not part
of the submission artifact directories.
