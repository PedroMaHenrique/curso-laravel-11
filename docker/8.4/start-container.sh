#!/usr/bin/env bash
set -e

# ==============================================================================
# Start Container Script - Nimbus Base Tenant Single
# Autor: Paulo Rogério
# ==============================================================================
# Este script inicializa o ambiente Laravel com Octane e Vite dentro do Docker.
# Ele realiza:
#   - Verificação de permissões
#   - Ajuste de UID/GID
#   - Instalação de dependências
#   - Limpeza de processos antigos
#   - Exportação segura do .env
#   - Inicialização via supervisord
# ==============================================================================

log_info()    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn()    { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error()   { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# -----------------------------
# Verifica usuário supervisor
# -----------------------------
if [ "$SUPERVISOR_PHP_USER" != "root" ] && [ "$SUPERVISOR_PHP_USER" != "sail" ]; then
    log_error "SUPERVISOR_PHP_USER deve ser 'root' ou 'sail'."
    exit 1
fi

# -----------------------------
# Ajusta UID do sail
# -----------------------------
if [ -n "$WWWUSER" ]; then
    log_info "Ajustando UID do usuário 'sail' para $WWWUSER..."
    usermod -u $WWWUSER sail || log_warn "Falha ao ajustar UID do usuário sail."
fi

# -----------------------------
# Cria diretório global do Composer
# -----------------------------
log_info "Preparando diretório global do Composer..."
mkdir -p /.composer
chmod -R ugo+rw /.composer

# -----------------------------
# Ajusta permissões do projeto Laravel
# -----------------------------
log_info "Ajustando permissões do Laravel..."
chown -R sail:$WWWGROUP /var/www/html
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public
chown -R sail:sail /var/www/html/node_modules || true

# -----------------------------
# Limpa locks do Octane e processos antigos
# -----------------------------
log_info "Limpando processos e locks antigos..."
rm -f /var/www/html/storage/octane/*.lock || true
pkill -f "artisan octane:start" >/dev/null 2>&1 || true
pkill -f "vite" >/dev/null 2>&1 || true

# -----------------------------
# Instala dependências do Composer
# -----------------------------
if [ ! -d /var/www/html/vendor ]; then
    log_info "Instalando dependências do Composer..."
    gosu sail composer install --no-interaction --optimize-autoloader --no-dev
else
    log_info "Dependências do Composer já instaladas."
fi

# -----------------------------
# Instala dependências Node.js
# -----------------------------
cd /var/www/html
if [ ! -d node_modules ]; then
    log_info "Instalando dependências Node..."
    gosu sail npm install
else
    log_info "Dependências Node já instaladas."
fi

# -----------------------------
# Exporta variáveis do .env de forma segura
# -----------------------------
if [ -f /var/www/html/.env ]; then
    log_info "Exportando variáveis do .env..."
    set -a
    grep -v -E '^\s*#|^\s*$' /var/www/html/.env | sed 's/\r//g' > /tmp/env_vars
    . /tmp/env_vars
    set +a
fi

# -----------------------------
# Build frontend ou modo dev
# -----------------------------
if [ "$APP_ENV" = "production" ]; then
    log_info "Modo PRODUCTION detectado. Executando build do frontend..."
    gosu sail npm run build
else
    log_info "Modo LOCAL detectado. Vite será gerenciado via Supervisor."
fi

# -----------------------------
# Inicia o supervisord
# -----------------------------
log_success "Ambiente preparado com sucesso. Iniciando supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
