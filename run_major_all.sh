#!/usr/bin/env bash

set -u

cd "$(dirname "$0")"

export D4J="${D4J:-$PWD/defects4j-master}"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home}"
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:/opt/homebrew/opt/subversion/bin:$D4J/framework/bin:$PATH"
export TZ="${TZ:-America/Los_Angeles}"

ROOT="${1:-$PWD/artifacts}"

for bug in 1 2 3 4 5; do
    defect="Cli-$bug"
    input_root="$ROOT/work/$defect/mutation-input"
    mkdir -p "$input_root"

    for suite in $(seq 1 20); do
        suite_name=$(printf 'suite%02d' "$suite")
        input_dir="$input_root/$suite_name"
        archive="$input_dir/Cli-${bug}f-evosuite.$suite.tar.bz2"
        output_dir="$ROOT/$defect/mutation/$suite_name"
        result_dir="$output_dir/mutation_log/Cli/evosuite"
        mutant_log="$result_dir/${bug}f.mutants.log"
        kill_matrix="$result_dir/${bug}f.$suite.kill.csv"
        summary="$result_dir/${bug}f.$suite.summary.csv"

        if [[ -f "$mutant_log" && -f "$kill_matrix" && -f "$summary" ]]; then
            echo "[$defect $suite_name] already complete"
            continue
        fi

        mkdir -p "$input_dir"
        rm -f "$archive"
        tar -cjf "$archive" -C "$ROOT/$defect/test_suites/$suite_name" .
        mkdir -p "$output_dir"

        echo "[$defect $suite_name] running Major"
        if ! run_mutation.pl -p Cli -d "$input_dir" -v "${bug}f" -o "$output_dir" \
            > "$ROOT/work/$defect/major-$suite.log" 2>&1; then
            echo "[$defect $suite_name] Major failed; see $ROOT/work/$defect/major-$suite.log" >&2
            continue
        fi

        if [[ -f "$mutant_log" && -f "$kill_matrix" && -f "$summary" ]]; then
            echo "[$defect $suite_name] archived required outputs"
        else
            echo "[$defect $suite_name] missing required output; inspect $output_dir" >&2
        fi
    done
done
