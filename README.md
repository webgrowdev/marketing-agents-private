# marketing-agents-private

Repositorio privado curado para operar agentes de marketing en OpenClaw con control total de cambios, trazabilidad y aislamiento por agente.

## Por qué existe
- Evitar dependencia directa de upstream en producción.
- Mantener una base estable y auditada para operación en VPS.
- Permitir customizaciones internas sin perder trazabilidad.

## Filosofía de curación
1. Importar solo lo necesario.
2. Adaptar a formato interno consistente.
3. Documentar gaps con placeholders explícitos.
4. No ocultar incertidumbre de verificación upstream.

## Estructura
- `agents/`: 8 agentes listos para OpenClaw.
- `skills/`: skills curadas y placeholders.
- `shared/`: contexto común reusable.
- `scripts/`: install, verify, sync y backup.
- `docs/`: arquitectura, seguridad, mantenimiento y fuentes.

## Agentes incluidos
`seo-content`, `cro`, `content-copy`, `paid-measurement`, `growth-retention`, `sales-gtm`, `strategy`, `motion-pro`.

## Placeholders
Ver `docs/placeholders.md` para skills no verificables/importables durante la auditoría.

## Instalación
```bash
./scripts/install.sh
```

## Verificación
```bash
./scripts/verify.sh
```

## Sincronización a OpenClaw
```bash
./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
```

## Mantenimiento
Ver `docs/maintenance.md`.

## Política de importación desde upstream
- Se audita en entorno controlado.
- Se adapta localmente con atribución explícita.
- Producción consume solo este repo privado.
