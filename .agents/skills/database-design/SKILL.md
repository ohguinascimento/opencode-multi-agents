---
name: database-design
description: Guia para modelagem de banco de dados, schema design e otimizações de performance
---

# Database Design Skill

Use quando precisar criar, revisar ou otimizar banco de dados.

## Modelagem Relacional

### Entidades e Relacionamentos
```
┌─────────────┐       ┌─────────────┐
│   users     │       │   orders    │
├─────────────┤       ├─────────────┤
│ id (PK)     │──┐    │ id (PK)     │
│ name        │  │    │ user_id (FK)│
│ email       │  └───>│ total       │
│ created_at  │       │ status      │
└─────────────┘       └─────────────┘
```

### Tipos de Relacionamento
| Tipo | Exemplo | Chave Estrangeira |
|------|---------|-------------------|
| 1:1 | User ↔ Profile | Em qualquer tabela |
| 1:N | User ↔ Orders | Na tabela "filha" |
| M:N | Users ↔ Roles | Tabela de junção |

## SQL Padrão

### Criar Tabela
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Índices
```sql
-- Índice simples
CREATE INDEX idx_users_email ON users(email);

-- Índice composto
CREATE INDEX idx_users_status_created ON users(status, created_at);

-- Índice parcial
CREATE INDEX idx_users_active ON users(email) WHERE status = 'active';
```

### Migrations
```sql
-- V001__create_users.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- V002__add_user_status.sql
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
```

## Otimizações

### Queries N+1
```sql
-- ❌ Ruim: N+1 queries
SELECT * FROM orders;
-- Para cada order:
SELECT * FROM users WHERE id = order.user_id;

-- ✅ Bom: JOIN
SELECT o.*, u.name, u.email
FROM orders o
JOIN users u ON u.id = o.user_id;
```

### Cursor Pagination
```sql
-- ❌ Ruim: OFFSET (lento em grandes volumes)
SELECT * FROM users ORDER BY id LIMIT 10 OFFSET 1000;

-- ✅ Bom: Cursor
SELECT * FROM users 
WHERE id > 'last_id' 
ORDER BY id 
LIMIT 10;
```

### Partitioning
```sql
-- Partition por data
CREATE TABLE orders (
  id UUID,
  created_at DATE,
  total DECIMAL
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024 PARTITION OF orders
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

## NoSQL (MongoDB)

### Schema
```javascript
const userSchema = new Schema({
  name: { type: String, required: true, maxlength: 100 },
  email: { type: String, required: true, unique: true },
  profile: {
    bio: String,
    avatar: String
  },
  tags: [String],
  createdAt: { type: Date, default: Date.now }
});
```

### Indexes
```javascript
// Single field
userSchema.index({ email: 1 });

// Compound
userSchema.index({ status: 1, createdAt: -1 });

// Text search
userSchema.index({ name: 'text', email: 'text' });
```

## Boas Práticas

### Nomes
- Tabelas: plural, snake_case (`users`, `order_items`)
- Colunas: snake_case (`created_at`, `user_id`)
- Índices: `idx_{table}_{columns}`

### Constraints
```sql
-- Primary Key
id UUID PRIMARY KEY DEFAULT gen_random_uuid();

-- Foreign Key
CONSTRAINT fk_orders_user 
  FOREIGN KEY (user_id) 
  REFERENCES users(id) 
  ON DELETE CASCADE;

-- Check
CONSTRAINT chk_orders_status 
  CHECK (status IN ('pending', 'paid', 'shipped'));
```

### Soft Delete
```sql
-- Adicionar coluna
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP NULL;

-- Filtrar por padrão
CREATE VIEW active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;
```

## Performance

### Explain Analyze
```sql
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';
```

### Statisticas
```sql
-- Atualizar estatísticas
ANALYZE users;

-- Ver tamanho das tabelas
SELECT pg_size_pretty(pg_total_relation_size('users'));
```
