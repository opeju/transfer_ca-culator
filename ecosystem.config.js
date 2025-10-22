// ============================================================================
// Configuração PM2 - Calculadora de Transfer
// ============================================================================
// Uso: pm2 start ecosystem.config.js
// Documentação: https://pm2.keymetrics.io/docs/usage/application-declaration/

module.exports = {
  apps: [
    {
      // ====================================================================
      // Informações da Aplicação
      // ====================================================================
      name: 'transfer_calculator',
      script: './dist/index.js',
      cwd: '/var/www/transfer_calculator',

      // ====================================================================
      // Instâncias e Modo
      // ====================================================================
      instances: 'max',           // Usar todos os cores disponíveis
      exec_mode: 'cluster',       // Modo cluster para melhor performance
      
      // ====================================================================
      // Variáveis de Ambiente
      // ====================================================================
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        DEBUG: false
      },

      // ====================================================================
      // Configurações de Processo
      // ====================================================================
      watch: false,               // Não recarregar em mudanças de arquivo
      ignore_watch: ['node_modules', 'logs', 'dist'],
      max_memory_restart: '500M', // Reiniciar se usar mais de 500MB
      
      // ====================================================================
      // Logs
      // ====================================================================
      error_file: '/var/log/pm2/transfer_calculator_error.log',
      out_file: '/var/log/pm2/transfer_calculator_out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      
      // ====================================================================
      // Reinicialização
      // ====================================================================
      autorestart: true,          // Reiniciar automaticamente se falhar
      max_restarts: 10,           // Máximo de reinicializações
      min_uptime: '10s',          // Tempo mínimo antes de considerar "failed"
      
      // ====================================================================
      // Graceful Shutdown
      // ====================================================================
      kill_timeout: 5000,         // Tempo para graceful shutdown
      listen_timeout: 3000,       // Tempo para escutar porta
      
      // ====================================================================
      // Merge Logs
      // ====================================================================
      merge_logs: true,
      
      // ====================================================================
      // Atributos Customizados
      // ====================================================================
      instance_var: 'INSTANCE_ID',
    }
  ],

  // ========================================================================
  // Configurações de Deploy (opcional)
  // ========================================================================
  deploy: {
    production: {
      user: 'ubuntu',
      host: 'seu-servidor.com',
      ref: 'origin/main',
      repo: 'git@github.com:seu-usuario/transfer_calculator.git',
      path: '/var/www/transfer_calculator',
      'post-deploy': 'npm install --production && npm run build && pm2 reload ecosystem.config.js --env production'
    },
    staging: {
      user: 'ubuntu',
      host: 'seu-servidor-staging.com',
      ref: 'origin/develop',
      repo: 'git@github.com:seu-usuario/transfer_calculator.git',
      path: '/var/www/transfer_calculator',
      'post-deploy': 'npm install && npm run build && pm2 reload ecosystem.config.js --env staging'
    }
  }
};

// ============================================================================
// Comandos Úteis
// ============================================================================
// 
// Iniciar:
//   pm2 start ecosystem.config.js
//
// Parar:
//   pm2 stop transfer_calculator
//
// Reiniciar:
//   pm2 restart transfer_calculator
//
// Recarregar (zero-downtime):
//   pm2 reload transfer_calculator
//
// Ver logs:
//   pm2 logs transfer_calculator
//
// Ver status:
//   pm2 status
//
// Salvar configuração:
//   pm2 save
//
// Autostart no boot:
//   pm2 startup
//   pm2 save
//
// Monitoramento em tempo real:
//   pm2 monit
//
// Deletar processo:
//   pm2 delete transfer_calculator
//
// ============================================================================

