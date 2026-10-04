# hnykda/tap

Homebrew casks for apps by [@hnykda](https://github.com/hnykda).

| Cask | App |
|---|---|
| `wifi-heatmapper` | [WiFi Heatmapper](https://github.com/hnykda/wifi-heatmapper): measure Wi-Fi signal and throughput and draw heat maps on a floor plan |

## Install

```sh
brew install --cask hnykda/tap/wifi-heatmapper
```

This taps the repository, trusts only this cask (Homebrew asks for explicit
trust of non-official taps since 6.0) and installs
[iperf3](https://formulae.brew.sh/formula/iperf3), which the app uses for
throughput tests.

If you'd rather type the short name later, trust the cask once:

```sh
brew tap hnykda/tap
brew trust --cask hnykda/tap/wifi-heatmapper
brew install --cask wifi-heatmapper
```

## Opening the app the first time

WiFi Heatmapper is not signed with an Apple Developer ID or notarized, so
macOS blocks it the first time you open it:

1. Open WiFi Heatmapper. When macOS says it cannot verify the app, click
   **Done**.
2. Go to **System Settings → Privacy & Security**, scroll down and click
   **Open Anyway**.

Or, if you trust the build, remove the quarantine flag yourself:

```sh
xattr -dr com.apple.quarantine "/Applications/WiFi Heatmapper.app"
```

Each new version is a new build, so expect to do this again after an
upgrade. (Homebrew carries your approval over only when the new build is
signed by the same identity, which an unsigned app can't prove.)

### Why the cask doesn't do this for you

A cask could strip the quarantine flag in a `postflight` step, and some
third-party taps do. This one doesn't, on purpose:

- Homebrew marks cask downloads as quarantined so that macOS Gatekeeper still
  checks them. Its own docs say it won't "normalise a security bypass", the
  `--no-quarantine` option is gone (deprecated in late 2025, removed since),
  and official casks must pass Gatekeeper.
- Stripping the flag silently would mean every future build, or anything
  that ends up at the download URL, runs without you ever being asked.
- The checksum in the cask proves you got the file the tap expected, not
  who built it. The one-time "Open Anyway" is the honest place for that
  decision, and it is yours to make.

When the app is signed and notarized, these steps go away.

## Upgrade

```sh
brew update
brew upgrade --cask wifi-heatmapper
```

## Uninstall

```sh
brew uninstall --cask wifi-heatmapper
```

That removes the app and keeps your surveys and floor plans. To delete them
too, along with logs, caches, web view data and preferences:

```sh
brew uninstall --cask --zap wifi-heatmapper
```

The data lives in
`~/Library/Application Support/com.github.hnykda.wifi-heatmapper`; copy its
`data` folder first if you want to keep your surveys. `--zap` does not remove
iperf3 (`brew uninstall iperf3`) or the Location permission you may have
granted (System Settings → Privacy & Security → Location Services).

## How the casks stay up to date

[`.github/workflows/update.yml`](.github/workflows/update.yml) runs every day,
on demand (Actions → Update casks → Run workflow) and when a release workflow
sends it a `repository_dispatch`. For each cask it:

1. asks GitHub for the project's latest release. Drafts and prereleases are
   never picked; with no release yet it stops without changing anything;
2. stops if the cask already has that version (and real checksums);
3. checks the release has a file for every architecture;
4. runs `brew bump-cask-pr --write-only`, which downloads each file and
   writes the new version and checksums;
5. runs `brew style` and `brew audit --cask --online --strict`;
6. commits `<cask> <version>` to `main`.

It uses only this repository's `GITHUB_TOKEN`; no secrets are needed.
[`.github/workflows/check.yml`](.github/workflows/check.yml) runs `brew style`
and `brew audit` on every change to `Casks/`.

### Updating right after a release (optional)

The daily run means a new release reaches Homebrew within a day. To make it
immediate, the project's release workflow can notify this tap. That needs a
token that can write to this repository, because a workflow's own
`GITHUB_TOKEN` can't trigger workflows in another repository:

1. Create a fine-grained personal access token with access to
   `hnykda/homebrew-tap` only and the **Contents: read and write**
   permission.
2. Add it to the project repository as an Actions secret named
   `HOMEBREW_TAP_TOKEN`.
3. Add a step that runs after the release is published, skipped when the
   secret isn't set:

   ```yaml
   on:
     release:
       types: [published]

   jobs:
     homebrew:
       runs-on: ubuntu-latest
       steps:
         - name: Tell the Homebrew tap about the release
           env:
             GH_TOKEN: ${{ secrets.HOMEBREW_TAP_TOKEN }}
           if: env.GH_TOKEN != ''
           run: gh api repos/hnykda/homebrew-tap/dispatches -f event_type=release-published
   ```

It must run on `release: published`, not on the tag: releases start as
drafts, and the update workflow ignores drafts.

## Adding another cask

1. Add `Casks/<token>.rb`. `brew create --cask <url> --set-name <token>`
   gives a starting point; see the
   [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) and
   [`Casks/wifi-heatmapper.rb`](Casks/wifi-heatmapper.rb).
2. Add a row to the matrix in `.github/workflows/update.yml` with the cask
   token, the GitHub repository and the release file names (`{version}`
   stands for the version).
3. Check it locally:

   ```sh
   brew tap hnykda/tap "$PWD"   # or work in "$(brew --repository hnykda/tap)"
   brew style Casks/<token>.rb
   brew audit --cask --strict --online hnykda/tap/<token>
   brew install --cask hnykda/tap/<token>
   ```

4. Add it to the table at the top of this file.
