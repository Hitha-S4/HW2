#!/usr/bin/env bash

set -u

cd "$(dirname "$0")"

export D4J="${D4J:-$PWD/defects4j-master}"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home}"
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:/opt/homebrew/opt/subversion/bin:$D4J/framework/bin:$PATH"
export TZ="${TZ:-America/Los_Angeles}"

PROJECT="${1:?project is required}"
BUG_ID="${2:?bug id is required}"
START_SUITE="${3:-1}"
END_SUITE="${4:-20}"
BUDGET="${5:-60}"
SEED_BASE="${6:-20261000}"
ROOT="${7:-$PWD/artifacts}"

WORK="$ROOT/work/$PROJECT-$BUG_ID"
GENERATED="$WORK/generated"
REPAIR="$WORK/repair"
SUBMISSION="$ROOT/$PROJECT-$BUG_ID"
MANIFEST="$SUBMISSION/manifest.csv"

mkdir -p "$GENERATED" "$REPAIR" "$SUBMISSION/test_suites"

if [[ ! -f "$MANIFEST" ]]; then
    printf 'project,bug_id,suite,seed,budget,archive,repair_status,java_files\n' > "$MANIFEST"
fi

for suite in $(seq "$START_SUITE" "$END_SUITE"); do
    suite_name=$(printf 'suite%02d' "$suite")
    seed=$((SEED_BASE + suite))
    generation_dir="$GENERATED/$PROJECT/evosuite/$suite"
    archive="$generation_dir/$PROJECT-${BUG_ID}f-evosuite.$suite.tar.bz2"
    suite_repair="$REPAIR/$suite_name"
    repair_archive="$suite_repair/$PROJECT-${BUG_ID}f-evosuite.$suite.tar.bz2"
    suite_submission="$SUBMISSION/test_suites/$suite_name"

    if [[ -d "$suite_submission" ]] && find "$suite_submission" -type f -name '*.java' -print -quit | grep -q .; then
        printf '%s,%s,%s,%s,%s,%s,%s,%s\n' "$PROJECT" "$BUG_ID" "$suite" "$seed" "$BUDGET" "$archive" "already-present" "$(find "$suite_submission" -type f -name '*.java' | wc -l | tr -d ' ')" >> "$MANIFEST"
        continue
    fi

    rm -rf "$generation_dir" "$suite_submission"
    mkdir -p "$generation_dir" "$suite_submission"

    echo "[$PROJECT-$BUG_ID suite $suite] generating with seed $seed"
    if ! gen_tests.pl -g evosuite -p "$PROJECT" -v "${BUG_ID}f" -n "$suite" \
        -o "$GENERATED" -b "$BUDGET" -s "$seed" > "$WORK/generate-$suite.log" 2>&1; then
        echo "[$PROJECT-$BUG_ID suite $suite] generation failed; see $WORK/generate-$suite.log" >&2
        printf '%s,%s,%s,%s,%s,%s,%s,%s\n' "$PROJECT" "$BUG_ID" "$suite" "$seed" "$BUDGET" "$archive" "generation-failed" "0" >> "$MANIFEST"
        continue
    fi

    rm -rf "$suite_repair"
    mkdir -p "$suite_repair"
    cp "$archive" "$repair_archive"

    echo "[$PROJECT-$BUG_ID suite $suite] repairing"
    if ! "$D4J/framework/util/fix_test_suite.pl" -p "$PROJECT" -d "$suite_repair" \
        -v "${BUG_ID}f" -s evosuite > "$WORK/repair-$suite.log" 2>&1; then
        echo "[$PROJECT-$BUG_ID suite $suite] repair command failed; see $WORK/repair-$suite.log" >&2
        printf '%s,%s,%s,%s,%s,%s,%s,%s\n' "$PROJECT" "$BUG_ID" "$suite" "$seed" "$BUDGET" "$archive" "repair-command-failed" "0" >> "$MANIFEST"
        continue
    fi

    if [[ -f "$suite_repair/fix_test_suite.summary.log" ]] &&
        [[ -f "$repair_archive" ]] &&
        grep -q 'Number of uncompilable test classes:' "$suite_repair/fix_test_suite.summary.log" &&
        grep -q 'Number of uncompilable tests:' "$suite_repair/fix_test_suite.summary.log" &&
        grep -q 'Number of failing tests:' "$suite_repair/fix_test_suite.summary.log"; then
        if tar -xjf "$repair_archive" -C "$suite_submission"; then
            java_files=$(find "$suite_submission" -type f -name '*.java' | wc -l | tr -d ' ')
        else
            java_files=0
        fi
        if [[ "$java_files" -gt 0 ]]; then
            status="passed-five-fixed-runs"
            echo "[$PROJECT-$BUG_ID suite $suite] validated with $java_files Java files"
        else
            status="repair-extraction-failed"
            echo "[$PROJECT-$BUG_ID suite $suite] repaired archive contained no Java files" >&2
        fi
    else
        java_files=0
        status="repair-validation-failed"
        echo "[$PROJECT-$BUG_ID suite $suite] repair validation failed; see $WORK/repair-$suite.log" >&2
    fi

    printf '%s,%s,%s,%s,%s,%s,%s,%s\n' "$PROJECT" "$BUG_ID" "$suite" "$seed" "$BUDGET" "$archive" "$status" "$java_files" >> "$MANIFEST"
done

echo "Completed $PROJECT-$BUG_ID suites $START_SUITE-$END_SUITE"
echo "Manifest: $MANIFEST"
