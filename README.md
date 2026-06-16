# Running Authgear locally with Docker Compose

This is a demo of how you can run Authgear with Docker Compose locally.
This setup is NOT intended for production use.

## First time setup

### Step 1: Start the dependent services

```sh
docker compose up -d postgres redis minio
```

### Step 2: Run database migrations

```sh
docker compose run --rm -it authgear authgear database migrate up
docker compose run --rm -it authgear authgear audit database migrate up
docker compose run --rm -it authgear authgear images database migrate up
docker compose run --rm -it authgear-portal authgear-portal database migrate up
```

### Step 3: Create object store buckets

Run this command to enter the container.

```sh
docker compose exec -it minio bash
```

Inside the container, do these

```sh
mc alias set local http://localhost:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
mc mb local/images
mc mb local/userexport
```

Press CTRL-D to exit the container

### Step 4: Start Authgear

```sh
docker compose up
```

### Step 5: Create the project configuration for "accounts"

```sh
docker compose run --rm --workdir "/work" -v "$PWD/accounts:/work" authgear authgear init --interactive=false \
  --purpose=portal \
  --for-helm-chart=true \
  --app-id="accounts" \
  --public-origin="http://localhost:3100" \
  --portal-origin="http://localhost:8010" \
  --portal-client-id=portal \
  --phone-otp-mode=sms \
  --disable-email-verification=true \
  --search-implementation=postgresql \
  -o /work
```

### Step 6: Create the project "accounts"

```sh
docker compose run --rm --workdir "/work" -v "$PWD/accounts:/work" authgear-portal authgear-portal internal configsource create /work
docker compose run --rm authgear-portal authgear-portal internal domain create-default --default-domain-suffix "localhost"
```

### Step 7: Create your account in project "accounts"

> [!IMPORTANT]
> The email used in this step is `user@example.com` while the password is `secretpassword`.
> Feel free to adjust the email or the password.

```sh
docker compose exec authgear authgear internal admin-api invoke \
  --app-id accounts \
  --endpoint "http://127.0.0.1:3002" \
  --host "localhost:3100" \
  --query '
    mutation createUser($email: String!, $password: String!) {
      createUser(input: {
        definition: {
          loginID: {
            key: "email"
            value: $email
          }
        }
        password: $password
      }) {
        user {
          id
        }
      }
    }
  ' \
  --variables-json '{"email":"user@example.com","password":"secretpassword"}'
```

It should output something like

```
{"data":{"createUser":{"user":{"id":"VXNlcjoyMDhkYWFkYy0wZmM4LTQ1Y2MtODQwNS01ODIzNTVmYTI0ZWU"}}}}
```

Take note of the user node ID.

### Step 8: Decode the user node ID

> [!IMPORTANT]
> The literal user node ID used here is NOT intended for copy-and-paste directly.
> You have to replace it with the user node ID you obtained in the previous step.

```sh
echo "VXNlcjoyMDhkYWFkYy0wZmM4LTQ1Y2MtODQwNS01ODIzNTVmYTI0ZWU" | basenc --base64url --decode
```

It should output something like

```
User:208daadc-0fc8-45cc-8405-582355fa24ee
```

Take note of the user raw ID.

### Step 9: Grant yourself access to the project "accounts"

> [!IMPORTANT]
> The literal user raw ID used here is NOT intended for copy-and-paste directly.
> You have to replace it with the user raw ID you obtained in the previous step.

```sh
docker compose run --rm authgear-portal authgear-portal internal collaborator add --app-id accounts --user-id 208daadc-0fc8-45cc-8405-582355fa24ee --role owner
```

### Step 10: Visit the portal

Visit `http://localhost:8010` and sign in with your account created in a previous step.

## Non-first time setup

You need not go through the steps again if you shut down server, and want to restart.

You just run

```sh
docker compose up
```
