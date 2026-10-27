---
name: testing-strategies
description: Guia para estratégias de testes unitários, integração e E2E com múltiplos frameworks
---

# Testing Strategies Skill

Use quando precisar criar, configurar ou executar testes em qualquer framework.

## Pirâmide de Testes

```
        /\
       /  \        E2E (poucos, lentos)
      /    \
     /------\      Integração (média quantidade)
    /        \
   /----------\    Unitários (muitos, rápidos)
```

## Testes Unitários

### Jest (JavaScript/TypeScript)
```typescript
// math.test.ts
describe('Math', () => {
  it('should add two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });

  it('should throw on invalid input', () => {
    expect(() => add(NaN, 1)).toThrow('Invalid input');
  });
});
```

### PyTest (Python)
```python
# test_math.py
def test_add():
    assert add(1, 2) == 3

def test_add_invalid():
    with pytest.raises(ValueError):
        add("a", 1)
```

### Go Testing
```go
// math_test.go
func TestAdd(t *testing.T) {
    result := Add(1, 2)
    if result != 3 {
        t.Errorf("Add(1, 2) = %d; want 3", result)
    }
}
```

## Testes de Integração

### API Tests (Supertest)
```typescript
// users.test.ts
describe('Users API', () => {
  it('should create a user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'john@example.com' })
      .expect(201);

    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe('John');
  });

  it('should return 400 for invalid data', async () => {
    await request(app)
      .post('/api/users')
      .send({ name: '' })
      .expect(400);
  });
});
```

### Database Tests
```typescript
// user.repository.test.ts
describe('UserRepository', () => {
  beforeAll(async () => {
    await db.migrate.latest();
  });

  afterAll(async () => {
    await db.destroy();
  });

  beforeEach(async () => {
    await db('users').truncate();
  });

  it('should insert and retrieve user', async () => {
    const user = await repo.create({ name: 'John' });
    const found = await repo.findById(user.id);
    
    expect(found).toMatchObject({ name: 'John' });
  });
});
```

## Testes E2E

### Playwright
```typescript
// login.spec.ts
test('user can login', async ({ page }) => {
  await page.goto('/login');
  
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="submit"]');
  
  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('h1')).toContainText('Welcome');
});
```

### Cypress
```typescript
// login.cy.js
describe('Login', () => {
  it('should login successfully', () => {
    cy.visit('/login');
    cy.get('[data-testid="email"]').type('user@example.com');
    cy.get('[data-testid="password"]').type('password123');
    cy.get('[data-testid="submit"]').click();
    
    cy.url().should('include', '/dashboard');
    cy.get('h1').should('contain', 'Welcome');
  });
});
```

## Mocks e Stubs

### Jest Mocks
```typescript
// Mock de serviço externo
jest.mock('./email.service', () => ({
  sendEmail: jest.fn().mockResolvedValue({ success: true })
}));

// Mock de repositório
const mockRepo = {
  findById: jest.fn(),
  create: jest.fn()
};
```

### Factory Boy (Python)
```python
# factories.py
import factory
from models import User

class UserFactory(factory.Factory):
    class Meta:
        model = User
    
    name = factory.Faker('name')
    email = factory.Faker('email')
    password = factory.PostGenerationMethodCall('set_password', 'test123')
```

## Coverage

### Configuração Jest
```json
// jest.config.js
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    }
  },
  "coveragePathIgnorePatterns": [
    "/node_modules/",
    "/test/"
  ]
}
```

### Comando
```bash
# Gerar relatório
npm test -- --coverage

# Abrir relatório HTML
open coverage/lcov-report/index.html
```

## Test Data

### Fixtures
```typescript
// fixtures/users.ts
export const validUser = {
  name: 'John Doe',
  email: 'john@example.com',
  password: 'Password123!'
};

export const invalidUsers = [
  { name: '', email: 'test@example.com' },
  { name: 'John', email: 'invalid-email' },
  { name: 'John', email: 'john@example.com', password: '123' }
];
```

### Seeds
```typescript
// seeds/test/users.ts
export async function seed(knex: Knex) {
  await knex('users').del();
  await knex('users').insert([
    { name: 'Admin', email: 'admin@example.com', role: 'admin' },
    { name: 'User', email: 'user@example.com', role: 'user' }
  ]);
}
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install
        run: npm ci
        
      - name: Lint
        run: npm run lint
        
      - name: Test
        run: npm test
        
      - name: Coverage
        run: npm run test:coverage
```

## Best Practices

### Naming
```typescript
// ❌ Ruim
it('works', () => {});
it('test user', () => {});

// ✅ Bom
it('should return user when valid ID provided', () => {});
it('should throw NotFoundError when user does not exist', () => {});
```

### AAA Pattern
```typescript
it('should calculate total', () => {
  // Arrange
  const items = [{ price: 10 }, { price: 20 }];
  
  // Act
  const total = calculateTotal(items);
  
  // Assert
  expect(total).toBe(30);
});
```

### Test Isolation
```typescript
beforeEach(async () => {
  // Reset database
  await db.truncate();
  
  // Reset mocks
  jest.clearAllMocks();
});
```

## Comandos Úteis

```bash
# Jest
npm test
npm test -- --watch
npm test -- --coverage

# PyTest
pytest
pytest -v
pytest --cov=.

# Go
go test ./...
go test -v ./...
go test -cover ./...

# Playwright
npx playwright test
npx playwright test --ui
```
