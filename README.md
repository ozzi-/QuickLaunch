# QuickLaunch

Search your installed applications and launch them. Type, tap, done.

A Sailfish OS application.

## Origin

This project is based on **[QuickLaunch](https://gitlab.com/dracks/quicklaunchslx)** by
[Jaume Singla (dracks)](https://gitlab.com/dracks) — an application to search in your
currently installed applications and launch them, licensed under GPLv3.

## Why this fork exists

This repository is my personal fork of the original project. It is a fork in the
git sense: the code starts from the upstream history and carries my changes on top.
GitHub simply does not show the usual "forked from" badge because the original
lives on GitLab, not GitHub — so here it appears as a standalone repository.

I deliberately kept the original architecture (including the proper Sailfish
launch path via the `lipstick` `LauncherItem`) and only added the features I
was missing day to day:

- **Autofocus on open** — the search field is focused the moment the app opens,
  so you can start typing immediately without tapping it.
- **Clean state after launching** — launching an app resets the search field,
  so when you come back to QuickLaunch you always see the full list.
- **App-type filter (All / Sailfish / Android)** — a toggle above the list
  filters by app type. Android apps are detected by their `apkd-launcher` exec
  prefix; everything else is treated as native Sailfish. The filter applies
  to both the full list and search results.
- **Sailfish OS 5.2 build** — the build setup was adapted to the SFOS 5.2 SDK
  (Qt 5.6.3), so the app compiles cleanly for current devices. RPM is provided
  for `aarch64`.

## License

GPLv3 — see [LICENSE](LICENSE).
