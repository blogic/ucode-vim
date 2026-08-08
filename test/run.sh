#!/bin/sh
# Run the ucode-vim tests.
#
#   test/run.sh                 check every fixture under test/cases
#   test/run.sh --dump FILE     print FILE's syntax group map, to author a .exp
#   test/run.sh --smoke DIR     assert no error group fires on real code in DIR
#
# The default run does two things:
#
#   1. asks a real vim what syntax group it assigns at each asserted position,
#      and compares that against the .exp file beside each fixture
#   2. asks ucode itself to compile every fixture not marked "invalid", so that
#      the fixtures cannot drift into testing code the language would reject
#
# Exits non-zero if either step fails.

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

vim_args=""
for arg in "$@"; do
	vim_args="${vim_args:+$vim_args,}'$arg'"
done

# -es keeps vim off the terminal; -u NONE keeps the user's vimrc out of the
# result, so a pass means the plugin alone is responsible.
run_vim() {
	vim -es -u NONE -N \
		--cmd "let g:ucode_test_args = [$vim_args]" \
		-S "$repo/test/runner.vim" \
		</dev/null
}

parse_check() {
	if ! command -v ucode >/dev/null 2>&1; then
		echo "ucode not on PATH, skipping the parse check" >&2
		return 0
	fi

	rc=0
	for fixture in "$repo"/test/cases/*.uc "$repo"/test/cases/*.ut; do
		[ -e "$fixture" ] || continue

		exp="${fixture%.*}.exp"
		if [ -f "$exp" ] && grep -q '^invalid' "$exp"; then
			continue
		fi

		case "$fixture" in
		*.ut) mode="-T" ;;
		*)    mode="-R" ;;
		esac

		if ! ucode "$mode" -c -o /dev/null "$fixture" 2>&1; then
			echo "FAIL $(basename "$fixture"): ucode rejects this fixture" >&2
			rc=1
		fi
	done
	return $rc
}

case "${1:-}" in
--dump|--smoke)
	run_vim
	exit $?
	;;
esac

run_vim
parse_check
