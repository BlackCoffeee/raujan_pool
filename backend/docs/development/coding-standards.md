# Coding Standards

## PHP Standards

### PSR-12 Compliance
- Follow PSR-12 coding standard
- Use Laravel Pint for automatic formatting

### Naming Conventions
- Classes: PascalCase (e.g., `UserController`)
- Methods: camelCase (e.g., `getUserProfile`)
- Variables: camelCase (e.g., `$userName`)
- Constants: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### Code Organization
- One class per file
- Use meaningful names
- Keep methods small and focused
- Use type hints and return types

## Laravel Conventions

### Controllers
- Use resource controllers when possible
- Keep controllers thin
- Move business logic to services

### Models
- Use Eloquent relationships
- Define fillable properties
- Use accessors and mutators when needed

### Database
- Use migrations for schema changes
- Use seeders for test data
- Use factories for test data generation

## Testing Standards

### Test Structure
- Use Pest for testing
- Follow AAA pattern (Arrange, Act, Assert)
- Use descriptive test names
- Keep tests independent

### Coverage
- Maintain >80% test coverage
- Test both happy path and edge cases
- Use mocks for external dependencies
