# 🚀 Guia Rápido de Instalação

## Opção 1: Instalação Rápida (Node.js)

```bash
# 1. Clonar ou copiar os arquivos
cd /var/www/transfer_calculator

# 2. Instalar dependências
npm install --production

# 3. Gerar build
npm run build

# 4. Iniciar
npm start
```

A aplicação estará disponível em `http://localhost:3000`

## Opção 2: Instalação com Docker (Recomendado)

```bash
# 1. Navegar até o diretório
cd /var/www/transfer_calculator

# 2. Construir a imagem Docker
docker build -t transfer_calculator:latest .

# 3. Executar o container
docker run -d \
  --name transfer_calculator \
  -p 3000:3000 \
  --restart unless-stopped \
  transfer_calculator:latest
```

Ou com docker-compose:

```bash
# 1. Executar
docker-compose up -d

# 2. Verificar status
docker-compose ps

# 3. Ver logs
docker-compose logs -f transfer_calculator
```

## Opção 3: Usar Script de Deployment Automático

```bash
# 1. Dar permissão de execução
chmod +x deploy.sh

# 2. Executar deployment
sudo ./deploy.sh production
```

## Verificar se está funcionando

```bash
# Teste a aplicação
curl http://localhost:3000

# Ou abra no navegador
# http://seu-dominio.com
```

## Configurar com Nginx (Proxy Reverso)

```nginx
server {
    listen 80;
    server_name seu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Depois:

```bash
sudo systemctl restart nginx
```

## Gerenciar com PM2

```bash
# Instalar PM2
npm install -g pm2

# Iniciar
pm2 start npm --name "transfer_calculator" -- start

# Salvar configuração
pm2 save

# Autostart no boot
pm2 startup
```

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Porta 3000 em uso | `lsof -i :3000` e `kill -9 [PID]` |
| Módulos não encontrados | `rm -rf node_modules && npm install` |
| Build falha | Verificar Node.js versão: `node --version` |
| Docker não encontra porta | Verificar firewall: `sudo ufw allow 3000` |

## Próximos Passos

1. Ler `DEPLOYMENT.md` para configuração completa
2. Configurar HTTPS/SSL com Let's Encrypt
3. Configurar monitoramento e logs
4. Configurar backups automáticos
5. Testar a aplicação completamente

---

**Precisa de ajuda?** Consulte `DEPLOYMENT.md` para documentação completa.

