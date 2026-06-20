# AGENTS.md

## Purpose

AI harness wrapper for fims-dev-environment.

## Shared Harness References

- ../.github/instructions/shared-core.instructions.md
- ../.github/instructions/infra-devstack.instructions.md
- ../.github/instructions/testing-harness.instructions.md

## Repo-Specific Commands

- docker compose up --build
- docker compose up -d --build
- docker compose down
- docker compose logs -f

## Repo-Specific Rules

- Treat Oathkeeper as the gateway entrypoint.
- Keep Kratos/Oathkeeper/Postgres wiring explicit and documented.
