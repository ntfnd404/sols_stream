.DEFAULT_GOAL := help

.PHONY: help install-hooks

# ============================================
# Help
# ============================================
help:
	@echo "╔══════════════════════════════════════════════╗"
	@echo "║ Project: sols.stream                         ║"
	@echo "╠══════════════════════════════════════════════╣"
	@echo "║ Setup:                                       ║"
	@echo "║   make install-hooks - Install git hooks     ║"
	@echo "╚══════════════════════════════════════════════╝"

# ============================================
# Setup
# ============================================
install-hooks:
	@cp .claude/hooks/git-pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git pre-commit hook installed."
