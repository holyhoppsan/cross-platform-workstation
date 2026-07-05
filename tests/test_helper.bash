#!/usr/bin/env bash
set -u

tests=0
failures=0

assert_eq() {
  tests=$((tests + 1))
  if [ "$1" != "$2" ]; then
    printf 'not ok %d - %s (expected <%s>, got <%s>)\n' "$tests" "$3" "$1" "$2"
    failures=$((failures + 1))
  else
    printf 'ok %d - %s\n' "$tests" "$3"
  fi
}

assert_contains() {
  tests=$((tests + 1))
  case "$1" in
    *"$2"*) printf 'ok %d - %s\n' "$tests" "$3" ;;
    *)
      printf 'not ok %d - %s (missing <%s>)\n' "$tests" "$3" "$2"
      failures=$((failures + 1))
      ;;
  esac
}

finish_tests() {
  printf '1..%d\n' "$tests"
  [ "$failures" -eq 0 ]
}

