# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

## Project Overview

**fims-dev-environment** — Docker Compose stack that provides the local development infrastructure for FIMS. It runs:

- **PostgreSQL 15** — primary database
- **Ory Kratos v1.1.0** — identity provider (authentication, user management)
- **Ory Oathkeeper v0.40.7** — zero-trust API gateway (authentication proxy)

This repo contains **no application source code** — only Docker Compose config, service configs, and helper scripts.

## Services & Ports

| Service | Port | Description |
|---------|------|-------------|
| Postgres | 5432 | Primary database (`postgres` db, user `postgres`, password `test`) |
| Kratos (admin) | 4434 | Identity API admin endpoint |
| Oathkeeper (proxy) | 4455 | All traffic routes through here |

The Oathkeeper gateway at port **4455** is the single entry point for all frontend and API calls. Access rules are defined in `ory-oathkeeper/access-rules.json`.

## Essential Commands

```bash
# Start all services
docker compose up --build

# Start in background
docker compose up -d --build

# Stop services
docker compose down

# View logs
docker compose logs -f

# View logs for a specific service
docker compose logs -f kratos
```

## User Management Scripts

Located in `scripts/`:

```bash
# Create a new user (prompts for email + password)
./scripts/user_creation.sh

# Invite a user (sends invitation email)
./scripts/user_invitation.sh

# List all registered users
./scripts/user_list.sh
```

## Configuration Files

```
ory-kratos/
├── kratos.yml             # Kratos configuration (flows, session, courier)
└── identity.schema.json   # Identity schema (user fields)

ory-oathkeeper/
├── oathkeeper.yml         # Oathkeeper service config
├── access-rules.json      # Route-level authentication rules
└── id_token.jwks.json     # JWT signing keys

postgres/
└── init.sql               # Database initialization (schemas, users)
```

## Key Decisions

- Kratos `DSN` uses a dedicated `fims-db` Postgres user (not the root `postgres` user)
- Oathkeeper is configured as a forward-auth proxy; all routes require a valid Kratos session unless explicitly public
- `kratos-migrate` service runs schema migrations before `kratos` starts (depends_on chain)
- `host.docker.internal:host-gateway` extra_hosts entry enables containers to reach the host machine (needed for backend running outside Docker)

## Modifying Access Rules

Edit `ory-oathkeeper/access-rules.json` to:
- Add new public (no-auth) routes
- Add new authenticated routes that forward to the backend
- Change which paths require authentication

After editing, restart Oathkeeper: `docker compose restart oathkeeper`
