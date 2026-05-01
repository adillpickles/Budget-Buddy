# BudgetBuddy

BudgetBuddy is a money-tracking app that helps people keep track of what they earn and spend. Users can enter daily expenses, sort them into categories like food, transportation, and entertainment, and get a clear view of their spending habits. The goal is to make managing money less stressful and easier to understand, especially for beginners.

Built for college students, young adults, and anyone looking to build better spending habits.

## Tech Stack

- **Frontend:** Next.js, React
- **Database:** Supabase (PostgreSQL)
- **CI/CD:** GitHub Actions

## Getting Started

Make sure you have [Node.js](https://nodejs.org/) and [Git](https://git-scm.com/) installed.

**1. Clone the repo**
```bash
git clone https://github.com/Shafin-Rehman/product-proposal.git
cd product-proposal
```

**2. Install dependencies**
```bash
cd nextjs
npm install
```

**3. Set up environment variables**

Create a `.env.local` file in the `nextjs/` folder and add the server-side environment variables used by the app:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
DATABASE_URL=your_database_connection_string
```

`NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are not enough for the current implementation because the API routes and shared server code read `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `DATABASE_URL`.

**4. Start the app**
```bash
npm run dev
```

**5. Verify the production build**
```bash
npm run build
```


## CI/CD Pipeline

This project uses GitHub Actions pipelines that trigger automatically on pull requests and pushes to main:

- **App CI** - installs dependencies, seeds the test user when secrets are available, runs tests, checks coverage, builds the app, and runs Playwright.
- **DB Migrations** - dry-runs Supabase migrations on pull requests and applies them on pushes to main.
- **Terraform Infrastructure** - runs secret-free Terraform fmt, backendless init, and validate checks on pull requests; trusted pushes to main run remote-state plan and apply using HCP Terraform.
- **Deploy to Vercel** - builds a prebuilt production artifact with Vercel CLI and deploys it after App CI succeeds on main.

See [Session 11 Cloud Deployment and Infrastructure as Code](docs/cloud-deployment.md) for the public cloud, Terraform state, fork-safe workflow behavior, Supabase redirect setup, secret setup, and validation plan.

## Testing

### Where tests should be added

Add API route tests in:

```
nextjs/__tests__/
```

Use one test file per feature or route group. Example:

- `auth.test.js` — signup and login routes

Tests target the actual Next.js App Router route handler logic. External dependencies are mocked with `jest.mock()` so no real DB connection is needed.

### How to run tests

Tests must be run from inside the `nextjs` directory:

```bash
cd nextjs
npm test -- --coverage
```

This runs all test files in `nextjs/__tests__/` and generates a coverage report at:

```
nextjs/coverage/lcov-report/index.html
```

### Helpful links

- [Jest docs](https://jestjs.io/docs/getting-started)
- [Next.js testing guide (App Router)](https://nextjs.org/docs/app/building-your-application/testing/jest)

## Features

- Add and categorize daily expenses
- Track monthly income
- Set monthly budgets
- View total spending and financial summary
- Budget threshold alerts when spending limit is reached
