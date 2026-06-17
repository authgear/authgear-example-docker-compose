# Running Authgear locally with Docker Compose

This is a demo of how you can run Authgear with Docker Compose locally.

> **WARNING: NOT FOR PRODUCTION USE**
>
> This setup is intended for local development and demonstration purposes only.
> It uses insecure default credentials and configuration that are **not suitable for production**.
> If you intend to deploy Authgear in production, you **must**:
> - Review and replace all environment variables and secrets in the `env` file
>   (e.g. database passwords, secret keys, JWT secrets)
> - Update all origins (e.g. allowed origins, redirect URIs, CORS settings) to match your actual domain

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
