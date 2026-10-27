---
name: security-best-practices
description: Guia completo de segurança para aplicações web, incluindo OWASP Top 10 e proteções
---

# Security Best Practices Skill

Use quando precisar implementar ou revisar segurança em aplicações.

## OWASP Top 10 (2021)

### A01: Broken Access Control
```typescript
// ❌ Ruim: Não verificar permissão
app.get('/api/admin/users', (req, res) => {
  // Qualquer um acessa
});

// ✅ Bom: Verificar permissão
app.get('/api/admin/users', 
  authenticate, 
  authorize('admin'),
  (req, res) => {
    // Só admins acessam
  }
);
```

### A02: Cryptographic Failures
```typescript
// ❌ Ruim: MD5
const hash = md5(password);

// ✅ Bom: bcrypt
const hash = await bcrypt.hash(password, 12);
```

### A03: Injection
```typescript
// ❌ Ruim: SQL Injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ Bom: Parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
```

### A04: Insecure Design
```typescript
// ❌ Ruim: Limitar no frontend
const maxTransfer = 10000; // Frontend limita

// ✅ Bom: Validar no backend
if (amount > MAX_TRANSFER) {
  throw new Error('Limit exceeded');
}
```

### A05: Security Misconfiguration
```typescript
// ❌ Ruim: Headers padrão
app.use(helmet()); // Sem configuração

// ✅ Bom: Headers configurados
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
    }
  }
}));
```

### A06: Vulnerable Components
```bash
# Verificar vulnerabilidades
npm audit
yarn audit
pip check
```

### A07: Authentication Failures
```typescript
// ❌ Ruim: Sem limite de tentativas
app.post('/login', async (req, res) => {
  // Pode tentar infinitamente
});

// ✅ Bom: Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // 5 tentativas
  message: 'Too many attempts'
});

app.post('/login', limiter, async (req, res) => {
  // Limitado a 5 tentativas
});
```

### A08: Data Integrity Failures
```typescript
// ❌ Ruim: Não verificar integridade
const data = JSON.parse(untrustedInput);

// ✅ Bom: Validar e sanitizar
const schema = z.object({
  name: z.string().max(100),
  email: z.string().email()
});
const data = schema.parse(untrustedInput);
```

### A09: Logging Failures
```typescript
// ❌ Ruim: Log sensível
console.log('User password:', password);

// ✅ Bom: Log seguro
logger.info('User login', { userId: user.id, ip: req.ip });
```

### A10: SSRF
```typescript
// ❌ Ruim: URL arbitrária
const response = await fetch(req.body.url);

// ✅ Bom: Whitelist
const allowedHosts = ['api.example.com'];
const url = new URL(req.body.url);
if (!allowedHosts.includes(url.hostname)) {
  throw new Error('Host not allowed');
}
```

## Proteções Essenciais

### XSS (Cross-Site Scripting)
```typescript
// Sanitizar output
import DOMPurify from 'dompurify';

const clean = DOMPurify.sanitize(userInput);
element.innerHTML = clean;
```

### CSRF (Cross-Site Request Forgery)
```typescript
// Token CSRF
app.use(csurf({ cookie: true }));

// No frontend
<input type="hidden" name="_csrf" value="{{csrfToken}}">
```

### Headers de Segurança
```typescript
// Helmet.js
app.use(helmet());

// Headers manuais
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000');
  next();
});
```

### Rate Limiting
```typescript
import rateLimit from 'express-rate-limit';

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', apiLimiter);
```

## Validação de Input

### Zod
```typescript
import { z } from 'zod';

const userSchema = z.object({
  name: z.string().min(2).max(100).trim(),
  email: z.string().email().toLowerCase(),
  age: z.number().int().min(0).max(150),
  password: z.string().min(8).regex(
    /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
    'Password must contain uppercase, lowercase and number'
  )
});

// Validar
const result = userSchema.safeParse(input);
if (!result.success) {
  return res.status(400).json({ errors: result.error.issues });
}
```

### Express Validator
```typescript
import { body, validationResult } from 'express-validator';

app.post('/users',
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
  }
);
```

## Autenticação Segura

### JWT
```typescript
import jwt from 'jsonwebtoken';

// Gerar token
const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET,
  { expiresIn: '1h' }
);

// Verificar token
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

### Refresh Tokens
```typescript
// Access token (curto prazo)
const accessToken = jwt.sign(
  { userId: user.id },
  SECRET,
  { expiresIn: '15m' }
);

// Refresh token (longo prazo)
const refreshToken = jwt.sign(
  { userId: user.id },
  REFRESH_SECRET,
  { expiresIn: '7d' }
);
```

## Criptografia

### Senhas
```typescript
// Hash
const hash = await bcrypt.hash(password, 12);

// Verificar
const isValid = await bcrypt.compare(password, hash);
```

### Dados Sensíveis
```typescript
import crypto from 'crypto';

// Criptografar
const cipher = crypto.createCipheriv(
  'aes-256-gcm',
  key,
  iv
);
let encrypted = cipher.update(data, 'utf8', 'hex');
encrypted += cipher.final('hex');

// Descriptografar
const decipher = crypto.createDecipheriv(
  'aes-256-gcm',
  key,
  iv
);
let decrypted = decipher.update(encrypted, 'hex', 'utf8');
decrypted += decipher.final('utf8');
```

## Checklist de Segurança

### Input
- [ ] Todos os inputs validados
- [ ] SQL parametrizado
- [ ] Output sanitizado

### Autenticação
- [ ] Senhas hasheadas (bcrypt)
- [ ] Tokens expiram
- [ ] Rate limiting implementado

### Autorização
- [ ] Verificação em todas as rotas
- [ ] Princípio do menor privilégio
- [ ] Logs de acesso

### Infraestrutura
- [ ] HTTPS habilitado
- [ ] Headers de segurança
- [ ] CORS configurado

### Dados
- [ ] Criptografia em trânsito
- [ ] Criptografia em repouso
- [ ] Backup seguro
