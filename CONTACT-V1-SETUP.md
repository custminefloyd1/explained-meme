# Contact V1 — Resend and Supabase setup

Do not connect the main Contact navigation until the final inbox test succeeds.

## 1. Create the free Resend account

1. Open https://resend.com and create an account.
2. In Resend, open **Domains** and add `explained.meme`.
3. Resend will show DNS records. Add those exact records in Cloudflare DNS.
4. Wait until Resend marks the domain **Verified**.
5. Open **API Keys** and create a sending key named `explained-meme-contact`.
6. Copy the key once. Never paste it into HTML or GitHub.

## 2. Add Supabase secrets

In Supabase, open **Edge Functions → Secrets** and add:

- `RESEND_API_KEY` = the private Resend key beginning with `re_`
- `CONTACT_TO_EMAIL` = the real inbox where contact messages must arrive
- `CONTACT_FROM_EMAIL` = `Explained Meme <contact@explained.meme>`

Save the secrets. Do not share their values in screenshots or chat.

## 3. Install the private delivery log

1. In GitHub branch `codex/battle-arena-v6`, open `supabase/contact-v1.sql`.
2. Copy the complete SQL.
3. In Supabase **SQL Editor**, create a new query, paste it and select **Run**.
4. Expected result: `Success. No rows returned`.

The table stores request ID, anonymous sender ID, status, provider ID and timestamps. It does not store the visitor's name, address or message. Client roles have no direct access.

## 4. Deploy the Edge Function

1. In Supabase, open **Edge Functions**.
2. Create a function named exactly `contact-v1`.
3. Replace the editor contents with the complete contents of `supabase/functions/contact-v1/index.ts`.
4. Deploy the function.
5. In function settings, turn **Verify JWT with legacy secret OFF**. The function performs its own live token validation with `auth.getUser`, which avoids legacy-gateway incompatibility while still rejecting unauthenticated requests.

## 5. Test before navigation integration

1. Download a fresh branch ZIP.
2. Start the local server inside the `explained meme` folder.
3. Open `http://localhost:8000/contact.html`.
4. Submit a message using an inbox you can access.
5. The page must not show success unless Resend accepts it.
6. Confirm the message appears in Resend Logs.
7. Confirm it arrives at `CONTACT_TO_EMAIL`; check spam once.
8. Reply to it and confirm the reply targets the visitor email.

Only after all eight checks pass should the main Contact navigation redirect to `contact.html`.
