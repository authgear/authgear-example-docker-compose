#!/bin/sh
set -e

ADMIN_EMAIL="${ADMIN_EMAIL:-user@example.com}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-secretpassword}"

echo "==> Generating project config..."
docker compose run --rm --workdir "/work" -v "$PWD/accounts:/work" authgear authgear init --interactive=false \
  --purpose=portal \
  --for-helm-chart=true \
  --app-id="accounts" \
  --public-origin="http://accounts.localhost:3100" \
  --portal-origin="http://localhost:8010" \
  --portal-client-id=portal \
  --phone-otp-mode=sms \
  --disable-email-verification=true \
  --search-implementation=postgresql \
  -o /work

echo "==> Uploading project config..."
docker compose run --rm --workdir "/work" -v "$PWD/accounts:/work" authgear-portal authgear-portal internal configsource create /work
docker compose run --rm authgear-portal authgear-portal internal domain create-default --default-domain-suffix ".localhost"

echo "==> Creating admin user ($ADMIN_EMAIL)..."
OUTPUT=$(docker compose run --rm authgear authgear internal admin-api invoke \
  --app-id accounts \
  --endpoint "http://authgear:3002" \
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
  --variables-json "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")

USER_RAW_ID=$(echo "$OUTPUT" | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
node_id = data['data']['createUser']['user']['id']
decoded = base64.urlsafe_b64decode(node_id + '=' * (-len(node_id) % 4)).decode()
print(decoded.split(':', 1)[1])
")

echo "==> Granting portal access..."
docker compose run --rm authgear-portal authgear-portal internal collaborator add \
  --app-id accounts \
  --user-id "$USER_RAW_ID" \
  --role owner

echo ""
echo "Done! Visit http://localhost:8010 and sign in with:"
echo "  Email:    $ADMIN_EMAIL"
echo "  Password: $ADMIN_PASSWORD"
