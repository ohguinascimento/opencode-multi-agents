---
name: api-design
description: Guia para design de APIs REST e GraphQL, incluindo padrões, boas práticas e exemplos
---

# API Design Skill

Use quando precisar criar, revisar ou documentar APIs REST ou GraphQL.

## Padrões REST

### Estrutura de URLs
```
GET    /api/v1/users          # Listar todos
GET    /api/v1/users/:id      # Buscar um
POST   /api/v1/users          # Criar
PUT    /api/v1/users/:id      # Atualizar completo
PATCH  /api/v1/users/:id      # Atualizar parcial
DELETE /api/v1/users/:id      # Remover
```

### Status Codes
| Code | Uso |
|------|-----|
| 200 | Sucesso |
| 201 | Criado |
| 204 | Sem conteúdo (delete) |
| 400 | Bad request |
| 401 | Não autenticado |
| 403 | Não autorizado |
| 404 | Não encontrado |
| 409 | Conflito |
| 422 | Validação |
| 500 | Erro interno |

### Response Format
```json
{
  "success": true,
  "data": {},
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100
  }
}
```

### Error Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email inválido",
    "details": {
      "field": "email",
      "value": "invalid"
    }
  }
}
```

## Boas Práticas

### Versionamento
- Use `/api/v1/`, `/api/v2/`
- Nunca quebre versões antigas
- Documente mudanças

### Paginação
```
GET /api/v1/users?page=1&limit=10
GET /api/v1/users?offset=0&limit=10
```

### Filtros
```
GET /api/v1/users?status=active
GET /api/v1/users?created_at_gte=2024-01-01
GET /api/v1/users?search=john
```

### Ordenação
```
GET /api/v1/users?sort=created_at:desc
GET /api/v1/users?sort=name:asc
```

## Autenticação

### JWT
```http
Authorization: Bearer <token>
```

### OAuth2
```http
Authorization: Bearer <access_token>
```

### API Key
```http
X-API-Key: <api_key>
```

## GraphQL Schema
```graphql
type User {
  id: ID!
  name: String!
  email: String!
  createdAt: DateTime!
}

type Query {
  users(limit: Int, offset: Int): [User!]!
  user(id: ID!): User
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}
```

## Validação

### Request Body
```typescript
const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).max(128),
});
```

### Path Parameters
```typescript
const getUserSchema = z.object({
  id: z.string().uuid(),
});
```

### Query Parameters
```typescript
const listUsersSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
});
```
