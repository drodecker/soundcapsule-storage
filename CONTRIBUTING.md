# Contributing to SoundCapsule Storage

Thank you for your interest in contributing to SoundCapsule Storage!

## Development Setup

### Prerequisites
- Node.js 20+
- MySQL 8.0
- Docker (optional, for containerized development)

### Quick Start

1. **Clone the repository:**
```bash
git clone <repository-url>
cd soundcapsule-storage
```

2. **Run setup script:**
```bash
# Linux/Mac
chmod +x setup.sh
./setup.sh

# Windows PowerShell
.\setup.ps1
```

3. **Or manually:**
```bash
cp .env.example .env
npm install
npm run prisma:generate
npm run prisma:migrate
npm run build
npm run start:dev
```

## Project Structure

```
soundcapsule-storage/
├── src/
│   ├── auth/              # JWT authentication & JWKS
│   │   ├── decorators/    # Custom decorators
│   │   ├── guards/        # Auth guards
│   │   └── strategies/    # Passport strategies
│   ├── files/             # File management
│   │   ├── dto/           # Data transfer objects
│   │   ├── files.controller.ts
│   │   ├── files.service.ts
│   │   ├── files.module.ts
│   │   └── s3.service.ts
│   ├── prisma/            # Prisma ORM
│   │   ├── prisma.service.ts
│   │   └── prisma.module.ts
│   ├── app.module.ts
│   └── main.ts
├── prisma/
│   ├── migrations/        # Database migrations
│   └── schema.prisma      # Database schema
├── test/                  # E2E tests
└── dist/                  # Compiled output
```

## Code Style

We use Prettier and ESLint for code formatting:

```bash
# Format code
npm run format

# Lint code
npm run lint
```

### Coding Guidelines

1. **TypeScript Best Practices:**
   - Use strict typing, avoid `any`
   - Use interfaces for object shapes
   - Leverage NestJS decorators

2. **Naming Conventions:**
   - Classes: PascalCase (e.g., `FilesService`)
   - Functions/Variables: camelCase (e.g., `createUploadUrl`)
   - Constants: UPPER_SNAKE_CASE (e.g., `MAX_FILE_SIZE`)
   - Files: kebab-case (e.g., `files.controller.ts`)

3. **Module Organization:**
   - One feature per module
   - Keep controllers thin, logic in services
   - DTOs for validation
   - Separate concerns (auth, storage, business logic)

## Making Changes

### Creating a New Feature

1. **Create a new branch:**
```bash
git checkout -b feature/your-feature-name
```

2. **Make your changes**

3. **Add tests** (see Testing section)

4. **Commit with descriptive messages:**
```bash
git commit -m "feat: add file size validation"
git commit -m "fix: resolve S3 connection timeout"
git commit -m "docs: update API documentation"
```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Formatting, missing semicolons, etc.
- `refactor:` Code restructuring without behavior change
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

### Database Migrations

When changing the database schema:

1. **Update `prisma/schema.prisma`**

2. **Create migration:**
```bash
npm run prisma:migrate -- --name descriptive_name
```

3. **Test migration:**
```bash
# Reset database and re-run all migrations
npm run prisma:migrate reset
```

4. **Commit both schema and migration files**

## Testing

### Running Tests

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Writing Tests

Example unit test:
```typescript
describe('FilesService', () => {
  it('should create upload URL', async () => {
    // Arrange
    const dto = { fileName: 'test.m4a', contentType: 'audio/m4a', durationSeconds: 60 };
    
    // Act
    const result = await service.createUploadUrl(dto, 'user-123');
    
    // Assert
    expect(result.uploadUrl).toBeDefined();
    expect(result.fileKey).toMatch(/^[0-9a-f-]{36}$/);
  });
});
```

## Docker Development

### Local Development with Docker

```bash
# Start services with hot reload
docker-compose -f docker-compose.dev.yml up

# View logs
docker-compose -f docker-compose.dev.yml logs -f storage-dev

# Stop services
docker-compose -f docker-compose.dev.yml down
```

### Production Build

```bash
# Build production image
docker build -t soundcapsule-storage:latest .

# Test production image
docker run -p 4002:4002 --env-file .env soundcapsule-storage:latest
```

## API Changes

When adding/modifying API endpoints:

1. **Update controller** with proper decorators
2. **Create/update DTOs** with validation
3. **Add tests** for new endpoints
4. **Update API documentation** in `API_TESTING.md`
5. **Update README.md** if needed

Example:
```typescript
@Post('upload-url')
@HttpCode(HttpStatus.OK)
async createUploadUrl(
  @Body() dto: CreateUploadUrlDto,
  @CurrentUser() user: CurrentUserData,
) {
  return this.filesService.createUploadUrl(dto, user.userId);
}
```

## Documentation

### When to Update Documentation

- Adding/changing API endpoints → `API_TESTING.md`
- Deployment changes → `DEPLOYMENT.md`
- General features → `README.md`
- Code explanations → Inline comments

### Documentation Style

- Use clear, concise language
- Include code examples
- Add troubleshooting tips
- Keep it up-to-date

## Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Ensure all tests pass:** `npm test`
4. **Ensure build succeeds:** `npm run build`
5. **Create pull request** with description:
   - What changed
   - Why it changed
   - How to test it

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How to test these changes

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Build passes
- [ ] No linting errors
```

## Performance Considerations

- **Database queries:** Use indexes, avoid N+1 queries
- **S3 operations:** Use pre-signed URLs, avoid proxying data
- **Caching:** Consider caching JWKS, metadata
- **Connection pooling:** Prisma handles this automatically

## Security Guidelines

1. **Never commit secrets** - use environment variables
2. **Validate all inputs** - use DTOs with class-validator
3. **Sanitize file names** - prevent path traversal
4. **Use HTTPS** in production
5. **Keep dependencies updated**

```bash
# Check for security vulnerabilities
npm audit

# Fix automatically
npm audit fix
```

## Getting Help

- **Questions:** Open a GitHub Discussion
- **Bugs:** Open a GitHub Issue with reproduction steps
- **Security issues:** Email security@soundcapsule.com (do not open public issue)

## Code Review Process

All submissions require review:

1. Automated checks must pass (tests, linting)
2. At least one maintainer approval
3. Address review feedback
4. Squash commits if requested

## Release Process

Maintainers only:

1. Update version in `package.json`
2. Update `CHANGELOG.md`
3. Create release tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. Build and push Docker image

## License

By contributing, you agree that your contributions will be licensed under the project's license.
