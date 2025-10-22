# 🚀 Guia de Deployment - Calculadora de Transfer

## Visão Geral

A Calculadora de Transfer é uma aplicação web moderna construída com **React 19**, **TypeScript** e **Tailwind CSS**. Este guia fornece instruções completas para lançar a aplicação no seu servidor.

## 📋 Requisitos do Sistema

Antes de começar, certifique-se de que seu servidor atende aos seguintes requisitos:

| Requisito | Versão Mínima | Notas |
|-----------|---------------|-------|
| Node.js | 18.0.0 | Recomendado: 20.0.0 ou superior |
| npm ou yarn | 9.0.0+ | pnpm também é suportado |
| Espaço em disco | 500 MB | Para dependências e build |
| Memória RAM | 1 GB | Recomendado para build |

## 📦 O que está incluído no build

O build de produção gera os seguintes arquivos:

```
dist/
├── public/                          # Arquivos estáticos
│   ├── index.html                  # Arquivo HTML principal
│   └── assets/
│       ├── index-[hash].css        # CSS minificado
│       └── index-[hash].js         # JavaScript minificado
├── index.js                        # Servidor Node.js (se aplicável)
└── [outros arquivos]               # Dependências compiladas
```

## 🔧 Opção 1: Deployment em Servidor Node.js

### Passo 1: Preparar o servidor

```bash
# Instalar Node.js (se não estiver instalado)
# Para Ubuntu/Debian:
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalação
node --version
npm --version
```

### Passo 2: Clonar ou copiar os arquivos

```bash
# Opção A: Se você tem acesso ao repositório Git
git clone [seu-repositorio] /var/www/transfer_calculator
cd /var/www/transfer_calculator

# Opção B: Se você tem os arquivos locais
scp -r /caminho/local/transfer_calculator user@seu-servidor:/var/www/
cd /var/www/transfer_calculator
```

### Passo 3: Instalar dependências

```bash
# Instalar dependências de produção
npm install --production

# Ou com yarn
yarn install --production

# Ou com pnpm
pnpm install --prod
```

### Passo 4: Gerar build de produção

```bash
# Gerar o build otimizado
npm run build

# Verificar se a pasta 'dist' foi criada
ls -la dist/
```

### Passo 5: Iniciar a aplicação

```bash
# Opção A: Iniciar diretamente
npm start

# Opção B: Usar um gerenciador de processos (recomendado)
npm install -g pm2
pm2 start npm --name "transfer_calculator" -- start
pm2 save
pm2 startup
```

## 🌐 Opção 2: Deployment em Servidor Web Estático (Nginx/Apache)

Se você prefere servir a aplicação como um site estático, siga estas instruções:

### Passo 1: Copiar arquivos estáticos

```bash
# Copiar apenas os arquivos estáticos para o servidor web
scp -r dist/public/* user@seu-servidor:/var/www/html/transfer_calculator/
```

### Passo 2: Configurar Nginx

```nginx
server {
    listen 80;
    server_name seu-dominio.com;

    root /var/www/html/transfer_calculator;
    index index.html;

    # Servir arquivos estáticos com cache
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Redirecionar todas as rotas para index.html (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Habilitar GZIP
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
```

### Passo 3: Configurar Apache

```apache
<Directory /var/www/html/transfer_calculator>
    Options -MultiViews
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.html [QSA,L]
</Directory>

# Cache para arquivos estáticos
<FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
    Header set Cache-Control "public, max-age=31536000, immutable"
</FilesMatch>

# Habilitar GZIP
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>
```

## 🔒 Configurações de Segurança

### HTTPS (SSL/TLS)

```bash
# Usar Let's Encrypt com Certbot (recomendado)
sudo apt-get install certbot python3-certbot-nginx
sudo certbot certonly --nginx -d seu-dominio.com

# Configurar renovação automática
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### Headers de Segurança (Nginx)

```nginx
# Adicionar ao bloco server do Nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

## 📊 Monitoramento e Logs

### Com PM2

```bash
# Ver status dos processos
pm2 status

# Ver logs em tempo real
pm2 logs transfer_calculator

# Reiniciar a aplicação
pm2 restart transfer_calculator

# Parar a aplicação
pm2 stop transfer_calculator
```

### Logs do Nginx

```bash
# Acessar logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 🚨 Troubleshooting

### Problema: "Port already in use"

```bash
# Encontrar o processo usando a porta
lsof -i :3000

# Matar o processo
kill -9 [PID]
```

### Problema: "Cannot find module"

```bash
# Limpar cache e reinstalar
rm -rf node_modules package-lock.json
npm install --production
npm run build
```

### Problema: Aplicação não responde

```bash
# Verificar logs
pm2 logs transfer_calculator

# Reiniciar
pm2 restart transfer_calculator

# Verificar recursos do servidor
top
df -h
```

## 📈 Otimizações de Performance

### 1. Habilitar Compressão GZIP

Já configurado nos exemplos de Nginx/Apache acima.

### 2. Usar CDN

Considere usar um CDN (Cloudflare, AWS CloudFront) para servir os arquivos estáticos.

### 3. Cache do Navegador

Os arquivos com hash (assets) já têm cache de 1 ano configurado.

### 4. Monitoramento de Performance

```bash
# Usar ferramentas como:
# - Google PageSpeed Insights
# - GTmetrix
# - Lighthouse (Chrome DevTools)
```

## 🔄 Atualizações

Para atualizar a aplicação:

```bash
# 1. Parar a aplicação
pm2 stop transfer_calculator

# 2. Atualizar código
cd /var/www/transfer_calculator
git pull origin main  # Se estiver usando Git

# 3. Instalar novas dependências (se houver)
npm install --production

# 4. Gerar novo build
npm run build

# 5. Reiniciar
pm2 start transfer_calculator
```

## 📞 Suporte e Recursos

- **Documentação React**: https://react.dev
- **Documentação Vite**: https://vitejs.dev
- **Documentação Node.js**: https://nodejs.org/docs
- **Documentação Nginx**: https://nginx.org/en/docs
- **PM2 Documentation**: https://pm2.keymetrics.io

## ✅ Checklist de Deployment

- [ ] Node.js instalado e verificado
- [ ] Dependências instaladas (`npm install`)
- [ ] Build gerado com sucesso (`npm run build`)
- [ ] Arquivos copiados para o servidor
- [ ] Servidor web configurado (Nginx/Apache)
- [ ] HTTPS/SSL configurado
- [ ] Headers de segurança adicionados
- [ ] Logs configurados
- [ ] Monitoramento ativo
- [ ] Teste de funcionalidade completo
- [ ] Backup configurado

---

**Última atualização**: Outubro 2025
**Versão da Aplicação**: 1.0.0

