```markdown
# devin_workbench Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches you the core development patterns and conventions used in the `devin_workbench` TypeScript codebase. You'll learn about file naming, import/export styles, commit message formatting, and how to work with tests. This guide is designed to help you quickly contribute code that matches the project's established style.

## Coding Conventions

### File Naming
- **Pattern:** PascalCase  
  Example:  
  ```plaintext
  MyComponent.ts
  UserService.ts
  ```

### Import Style
- **Pattern:** Relative imports  
  Example:  
  ```typescript
  import { UserService } from './UserService';
  ```

### Export Style
- **Pattern:** Named exports  
  Example:  
  ```typescript
  // In UserService.ts
  export function getUser() { ... }
  
  // In another file
  import { getUser } from './UserService';
  ```

### Commit Messages
- **Pattern:** Conventional commits with "feat" prefix  
  Example:  
  ```
  feat: add user authentication module
  ```

## Workflows

### Creating a New Feature
**Trigger:** When adding new functionality  
**Command:** `/new-feature`

1. Create a new file using PascalCase (e.g., `NewFeature.ts`).
2. Use relative imports to include dependencies.
3. Export your functions or classes using named exports.
4. Write a commit message starting with `feat:` and a short description.
5. If applicable, add or update a test file matching `*.test.*`.

### Writing Tests
**Trigger:** When testing new or existing code  
**Command:** `/write-test`

1. Create a test file named after the module, using the pattern `ModuleName.test.ts`.
2. Place your test logic in this file.
3. Follow the same import/export conventions as production code.

## Testing Patterns

- **Framework:** Not explicitly detected; use standard TypeScript test patterns.
- **File Naming:** Test files use the `*.test.*` pattern, e.g., `UserService.test.ts`.
- **Example:**
  ```typescript
  import { getUser } from './UserService';

  test('should fetch user', () => {
    expect(getUser()).toBeDefined();
  });
  ```

## Commands
| Command        | Purpose                                 |
|----------------|-----------------------------------------|
| /new-feature   | Scaffold a new feature module           |
| /write-test    | Create a new test file for a module     |
```
