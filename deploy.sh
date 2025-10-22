#!/bin/bash

# ============================================================================
# Script de Deployment - Calculadora de Transfer
# ============================================================================
# Este script automatiza o processo de deployment da aplicação
# Uso: ./deploy.sh [ambiente]
# Ambientes: development, staging, production
# ============================================================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
AMBIENTE=${1:-production}
APP_NAME="transfer_calculator"
APP_DIR="/var/www/$APP_NAME"
BACKUP_DIR="/var/backups/$APP_NAME"
LOG_FILE="/var/log/$APP_NAME/deploy.log"

# Funções auxiliares
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Verificar se o script está sendo executado como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script deve ser executado como root"
        exit 1
    fi
}

# Criar diretórios necessários
create_directories() {
    log_info "Criando diretórios necessários..."
    mkdir -p "$APP_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "/var/log/$APP_NAME"
    log_success "Diretórios criados"
}

# Fazer backup da versão anterior
backup_current() {
    if [ -d "$APP_DIR/dist" ]; then
        log_info "Fazendo backup da versão anterior..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        cp -r "$APP_DIR" "$BACKUP_DIR/backup_$TIMESTAMP"
        log_success "Backup realizado em $BACKUP_DIR/backup_$TIMESTAMP"
    fi
}

# Parar a aplicação
stop_app() {
    log_info "Parando a aplicação..."
    if command -v pm2 &> /dev/null; then
        pm2 stop "$APP_NAME" 2>/dev/null || true
        log_success "Aplicação parada com PM2"
    else
        log_warning "PM2 não encontrado, pulando parada da aplicação"
    fi
}

# Instalar dependências
install_dependencies() {
    log_info "Instalando dependências..."
    cd "$APP_DIR"
    
    if [ -f "package-lock.json" ]; then
        npm ci --production
    else
        npm install --production
    fi
    
    log_success "Dependências instaladas"
}

# Gerar build de produção
build_app() {
    log_info "Gerando build de produção..."
    cd "$APP_DIR"
    npm run build
    log_success "Build gerado com sucesso"
}

# Iniciar a aplicação
start_app() {
    log_info "Iniciando a aplicação..."
    
    if command -v pm2 &> /dev/null; then
        pm2 start npm --name "$APP_NAME" -- start
        pm2 save
        log_success "Aplicação iniciada com PM2"
    else
        log_warning "PM2 não encontrado, iniciando com npm"
        npm start &
    fi
}

# Verificar saúde da aplicação
health_check() {
    log_info "Verificando saúde da aplicação..."
    sleep 3
    
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_success "Aplicação está respondendo corretamente"
        return 0
    else
        log_error "Aplicação não está respondendo"
        return 1
    fi
}

# Restaurar backup em caso de erro
rollback() {
    log_error "Deployment falhou, restaurando backup..."
    
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -1)
    if [ -n "$LATEST_BACKUP" ]; then
        rm -rf "$APP_DIR"
        cp -r "$BACKUP_DIR/$LATEST_BACKUP" "$APP_DIR"
        log_info "Backup restaurado: $LATEST_BACKUP"
        
        # Reiniciar aplicação com backup
        start_app
        log_success "Aplicação restaurada com sucesso"
    else
        log_error "Nenhum backup disponível para restauração"
        exit 1
    fi
}

# Exibir resumo do deployment
show_summary() {
    log_info "=========================================="
    log_info "Resumo do Deployment"
    log_info "=========================================="
    log_info "Aplicação: $APP_NAME"
    log_info "Ambiente: $AMBIENTE"
    log_info "Diretório: $APP_DIR"
    log_info "Data: $(date)"
    log_info "=========================================="
}

# Função principal
main() {
    log_info "Iniciando deployment para ambiente: $AMBIENTE"
    
    check_root
    create_directories
    show_summary
    
    # Executar etapas de deployment
    backup_current || { log_error "Falha ao fazer backup"; exit 1; }
    stop_app || true
    install_dependencies || { rollback; exit 1; }
    build_app || { rollback; exit 1; }
    start_app || { rollback; exit 1; }
    health_check || { rollback; exit 1; }
    
    log_success "Deployment concluído com sucesso!"
    log_info "Aplicação disponível em http://localhost:3000"
}

# Executar função principal
main "$@"

