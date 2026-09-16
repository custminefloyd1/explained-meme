# Explained meme import pipeline

This branch stages the 90 approved text records without publishing unlicensed images.

## What is implemented

- `data/explained-memes-approved.json` is the reviewed content manifest.
- `supabase/explained-memes-staging.sql` creates a private staging table and upserts all 90 records.
- Visitor roles receive no permissions on the staging table.
- A database constraint blocks `published` status unless the origin is verified and an image URL, credit and `cleared_editorial` rights status are present.
- Existing `public.memes`, battle voting and database permissions are untouched.

## Run the validation

```bash
node --test tests/explained-memes-import.test.mjs
```

## Apply staging

Run `supabase/explained-memes-staging.sql` in the Supabase SQL editor. Expected result: `Success. No rows returned`.

This only creates private drafts. It does **not** make the records visible on the website.

## Required before publication

For each candidate:

1. obtain an editorially usable image;
2. store the image in controlled storage rather than hotlinking;
3. record the image credit and rights basis;
4. set `image_rights_status = 'cleared_editorial'`;
5. review the final page context;
6. deliberately promote the record to `public.memes`.

Do not reuse these images in Screensaver, downloads, merchandise, standalone galleries or advertising without separate permission.
