SHELL := /usr/bin/env bash

.PHONY: verify sync backup tree import-snapshots resolve-conflicts install-stack start-stack verify-stack

verify:
	./scripts/verify.sh

sync:
	./scripts/sync_to_openclaw.sh --target-base $${OPENCLAW_BASE:-$$HOME/.openclaw}

backup:
	./scripts/backup.sh --out-dir $${BACKUP_DIR:-./backups} --target $${BACKUP_TARGET:-repo}

install-stack:
	./scripts/install_stack.sh

start-stack:
	./scripts/start_stack.sh

verify-stack:
	./scripts/verify_stack.sh

import-snapshots:
	./scripts/import_upstream_snapshots.sh --help

tree:
	@if command -v tree >/dev/null 2>&1; then \
		tree -a -I '.git|backups|*.tar.gz|node_modules|dist|.next'; \
	else \
		find . -mindepth 1 -not -path './.git*' -not -path './backups*' | sort; \
	fi

resolve-conflicts:
	./scripts/resolve_pr_conflicts.sh --ours
