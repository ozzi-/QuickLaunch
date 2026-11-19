# Publishing to Chum (SailfishOS community repository)

QuickLaunch is published to **Chum** under the package name
**`harbour-quick-launch-ozzi`** (the original name `harbour-quick-launch`
is already taken there by the upstream v1.0 package of Jaume Singla).

Everything is built **from source on the official Sailfish OS OBS**
(`build.sailfishos.org`), for all supported architectures and SFOS releases.
This folder contains the OBS pipeline:

- `_service` — fetches the repo source at a pinned git tag (v1.7.0) and
  produces the `Source0` tarball the spec expects.
- `../rpm/harbour-quick-launch-ozzi.spec` — the packaging (identical to the
  one used for local/SDK builds; the spec also carries the Chum listing
  metadata via the `%if 0%{?_chum}` block).

## One-time setup (account + home project)

1. Create a free account on <https://build.sailfishos.org> (if account
   creation is approval-gated, ask on `#sailfishos` IRC or the forum —
   maintainers like `lbt`/`piggz`/`rinigus` handle it).
2. You then have a home project: `home:<username>`.

## Initial submission

1. In your home project, **create a new package** named exactly
   `harbour-quick-launch-ozzi`.
2. Add two files to the package:
   - `harbour-quick-launch-ozzi.spec` (upload
     `rpm/harbour-quick-launch-ozzi.spec` from this repo),
   - `_service` (upload `obs/_service` from this repo).
3. Wait for the build to go green (it builds against `sailfishos:latest`,
   i.e. the current SFOS release, for armv7hl + aarch64).
   - CLI alternative to watching: `osc brl home:<username> harbour-quick-launch-ozzi`.
4. On the package page, use **“Submit package”** with target project
   **`sailfishos:chum:testing`** (target package: `harbour-quick-launch-ozzi`).
5. A Chum maintainer reviews the test submission and promotes it to
   **`sailfishos:chum`**. From then on the app is installable via the
   **Chum GUI** (or by adding the Chum repository manually).

## Releasing a new version (repeat per release)

1. In this repo: bump `VERSION` in `harbour-quick-launch-ozzi.pro` +
   `Version:` in the spec, push, tag (`git tag v1.8.0 && git push --tags`).
2. Update `rev=` in `obs/_service` to the new tag, push.
3. On OBS: reload/re-trigger the build in `home:<username>` (or in
   `sailfishos:chum:testing` once you have been granted maintainer there),
   then “Submit package” to `sailfishos:chum:testing` again.
4. Maintainer promotes to `sailfishos:chum`.

## Checks Chum maintainers apply (per their checklist)

- `_service` pins a specific git tag/commit — ✅ (no webhooks).
- License in the spec is open source and matches the repo license — ✅ GPLv3.
- No binary blobs submitted (only source + spec) — ✅.
- Must not replace Jolla-provided system packages — ✅ (plain app).
