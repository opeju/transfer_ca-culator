# ============================================================================
# Dockerfile - Calculadora de Transfer
# ============================================================================
# Build em múltiplos estágios para otimizar tamanho da imagem

# Estágio 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./
COPY pnpm-lock.yaml* ./

# Instalar dependências
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile

# Copiar código-fonte
COPY . .

# Gerar build de produção
RUN pnpm run build

# Estágio 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Instalar dumb-init para melhor gerenciamento de processos
RUN apk add --no-cache dumb-init

# Copiar apenas os arquivos necessários do build anterior
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Criar usuário não-root por segurança
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Usar dumb-init para melhor gerenciamento de sinais
ENTRYPOINT ["dumb-init", "--"]

# Comando padrão
CMD ["npm", "start"]

