# {{PROJECT_NAME}}

Next.js 15 + Tailwind + shadcn/ui starter.

## Setup

```bash
cd {{PROJECT_NAME}}
pnpm install
```

## Development

```bash
pnpm dev          # Start dev server at http://localhost:3000
pnpm test         # Run Vitest
pnpm lint         # Run ESLint
pnpm build        # Production build
```

## Adding shadcn components

```bash
# Add the shadcn CLI on first use
pnpm dlx shadcn@latest init

# Add a component
pnpm dlx shadcn@latest add button
```

## Larder integration

```bash
larder list --cat api      # see what's available
larder use api/<name>      # add as dep (Python) or call from API route
```
