# Deployment producción (VPS Linux moderno)

## Comandos exactos
```bash
sudo apt update
sudo apt install -y git curl build-essential postgresql postgresql-contrib redis-server
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

sudo systemctl enable --now postgresql
sudo systemctl enable --now redis-server

sudo -u postgres psql -c "CREATE USER marketing WITH PASSWORD 'marketing';"
sudo -u postgres psql -c "CREATE DATABASE marketing_agents OWNER marketing;"

git clone https://github.com/webgrowdev/marketing-agents-private.git
cd marketing-agents-private
cp orchestrator/.env.example orchestrator/.env
cp dashboard/.env.example dashboard/.env
# editar .env con datos reales

./scripts/install.sh
./scripts/install_stack.sh
./scripts/sync_to_openclaw.sh --target-base ~/.openclaw
./scripts/start_stack.sh --prod
./scripts/verify_stack.sh
```

## Recomendación de procesos
Usar `systemd` o `pm2` para `orchestrator` y `dashboard`.
