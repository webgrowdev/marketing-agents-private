SHELL := /usr/bin/env bash

.PHONY: verify sync backup tree import-snapshots resolve-conflicts

verify:
	./scripts/verify.sh

sync:
	./scripts/sync_to_openclaw.sh --target-base $${OPENCLAW_BASE:-$$HOME/.openclaw}

backup:
	./scripts/backup.sh --out-dir $${BACKUP_DIR:-./backups} --target $${BACKUP_TARGET:-repo}

import-snapshots:
	./scripts/import_upstream_snapshots.sh --help

tree:
	@if command -v tree >/dev/null 2>&1; then \
		tree -a -I '.git|backups|*.tar.gz'; \
	else \
		find . -mindepth 1 -not -path './.git*' -not -path './backups*' | sort; \
	fi

resolve-conflicts:
	./scripts/resolve_pr_conflicts.sh --ours
