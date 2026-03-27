SHELL := /usr/bin/env bash

.PHONY: verify sync backup tree

verify:
	./scripts/verify.sh

sync:
	./scripts/sync_to_openclaw.sh --target-base $${OPENCLAW_BASE:-$$HOME/.openclaw}

backup:
	./scripts/backup.sh --out-dir $${BACKUP_DIR:-./backups} --target $${BACKUP_TARGET:-repo}

tree:
	@if command -v tree >/dev/null 2>&1; then \
		tree -a -I '.git|backups|*.tar.gz'; \
	else \
		find . -mindepth 1 -not -path './.git*' -not -path './backups*' | sort; \
	fi
