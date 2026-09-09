#!/bin/bash
# Test runner for Neovim configuration tests
# Run with: bash tests/test_runner.sh

echo "===== Running Neovim configuration tests ====="
echo ""

cd "$(dirname "$0")/.." || exit 1

# Use direct lua test runner (not plenary) because plenary doesn't properly
# support treesitter parsers in its sandboxed test environment
nvim --headless -u tests/minimal_init.lua -i NONE -n -c "luafile tests/run_tests.lua" || exit $?
nvim --headless -u NONE -i NONE -n -l tests/navigation_spec.lua || exit $?
nvim --headless -u NONE -i NONE -n -l tests/typescript_spec.lua

exit $?
