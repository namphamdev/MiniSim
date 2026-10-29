import Foundation

enum DeviceConstants {
  static let deviceBootedError = "Unable to boot device in current state: Booted"
  static let derivedDataLocation = "~/Library/Developer/Xcode/DerivedData"
  // GUI apps don't inherit the shell PATH, so look for simslim where Homebrew and `go install` put it.
  static let simslimSearchPaths = [
    "/opt/homebrew/bin/simslim",
    "/usr/local/bin/simslim",
    "~/go/bin/simslim"
  ]
  static let brewSearchPaths = [
    "/opt/homebrew/bin/brew",
    "/usr/local/bin/brew"
  ]
  static let simslimBrewFormula = "mobai-app/tap/simslim"
  static let simslimRepositoryURL = "https://github.com/MobAI-App/simslim"

  enum ProcessPaths: String {
    case xcrun = "/usr/bin/xcrun"
    case xcodeSelect = "/usr/bin/xcode-select"
  }

  enum BundleURL: String {
    case emulator = "qemu-system-aarch64"
    case simulator = "Simulator.app"
  }
}
