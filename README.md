# Running Authgear locally with Docker Compose

This is a demo of how you can run Authgear with Docker Compose locally.
This setup is NOT intended for production use.

## First time setup

### Step 1: Start Authgear

Migrations and bucket creation run automatically on startup.

```sh
docker compose up
```

### Step 2: Run first-time setup

```sh
./setup.sh
```

This creates the project config, uploads it, creates an admin user (`user@example.com` / `secretpassword`),
and grants portal access. Override credentials via env vars if needed:

```sh
ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=yourpassword ./setup.sh
```

### Step 3: Visit the portal

Visit `http://localhost:8010` and sign in with your admin account.

## Non-first time setup

You need not go through the steps again if you shut down server, and want to restart.

You just run

```sh
docker compose up
```
