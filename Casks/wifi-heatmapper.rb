cask "wifi-heatmapper" do
  arch arm: "aarch64", intel: "x64"

  # version and sha256 are rewritten by .github/workflows/update.yml from the
  # latest published release. Checksums of all zeros (ending in 0 or 1) are
  # placeholders: there is no release yet.
  version "0.6.0"
  sha256 arm:   "293f31a4939a12131cc049cd84ddbd382406861f1e9d2ace5d242d0c1f458898",
         intel: "abda6b04989c0de91a68f9afb6638026771955c6ef6bf0ec41314054dc3b96d0"

  url "https://github.com/hnykda/wifi-heatmapper/releases/download/v#{version}/WiFi.Heatmapper_#{version}_#{arch}.dmg",
      verified: "github.com/hnykda/wifi-heatmapper/"
  name "WiFi Heatmapper"
  desc "Measure Wi-Fi signal and throughput and draw heat maps on a floor plan"
  homepage "https://github.com/hnykda/wifi-heatmapper"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "iperf3"
  depends_on :macos

  app "WiFi Heatmapper.app"

  zap trash: [
    "~/Library/Application Support/com.github.hnykda.wifi-heatmapper",
    "~/Library/Caches/com.github.hnykda.wifi-heatmapper",
    "~/Library/HTTPStorages/com.github.hnykda.wifi-heatmapper",
    "~/Library/Logs/com.github.hnykda.wifi-heatmapper",
    "~/Library/Preferences/com.github.hnykda.wifi-heatmapper.plist",
    "~/Library/Saved Application State/com.github.hnykda.wifi-heatmapper.savedState",
    "~/Library/WebKit/com.github.hnykda.wifi-heatmapper",
  ]

  caveats <<~EOS
    WiFi Heatmapper is not signed or notarized by Apple, so macOS blocks it
    the first time you open it, and again after each upgrade. To open it:

      1. Open WiFi Heatmapper. When macOS says it cannot verify the app,
         click Done.
      2. Go to System Settings > Privacy & Security, scroll down and click
         Open Anyway.

    Or, if you trust this build, remove the quarantine flag yourself:

      xattr -dr com.apple.quarantine "#{appdir}/WiFi Heatmapper.app"

    Your surveys and floor plans are kept in
      ~/Library/Application Support/com.github.hnykda.wifi-heatmapper/data
    `brew uninstall --zap --cask wifi-heatmapper` deletes them.
  EOS
end
