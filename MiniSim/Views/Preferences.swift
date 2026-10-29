//  MiniSim
//
//  Created by Oskar Kwaśniewski on 28/01/2023.
//

import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct Preferences: View {
    @State var menuImageSelected: String = "iphone"
    @State private var preferedTerminal: Terminal
    @State private var simslimVersion: String?
    @State private var isInstallingSimslim = false

    init() {
        let userPrefered = UserDefaults.standard.preferedTerminal
        if let terminal = Terminal(rawValue: userPrefered ?? Terminal.terminal.rawValue) {
            preferedTerminal = terminal
        } else {
            preferedTerminal = Terminal.terminal
        }
    }

    var body: some View {
        Settings.Container(contentWidth: 400) {
            Settings.Section(title: "Icon:") {
                Picker("", selection: $menuImageSelected) {
                    ForEach(MenuImage.allCases, id: \.self) { menuImage in
                        Image(nsImage: menuImage.image ?? NSImage())
                           .tag(menuImage.rawValue)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                .onChange(of: menuImageSelected) { _ in
                    UserDefaults.standard.menuImage = menuImageSelected
                }
                Text("The icon displayed in the Menu Bar.")
                    .descriptionText()
            }
            Settings.Section(title: "Preferred Terminal:") {
                  Picker("", selection: $preferedTerminal) {
                    let availableTerminal = Terminal.allCases.filter { $0.isAvailable() }
                    ForEach(availableTerminal, id: \.self) { terminal in
                      HStack {
                        Image(nsImage: terminal.getAppIcon() ?? NSImage())
                        Text(terminal.rawValue)
                      }
                      .tag(terminal.rawValue)
                    }
                  }
                  .onChange(of: preferedTerminal) { _ in
                      UserDefaults.standard.setValue(
                          preferedTerminal.rawValue, forKey: UserDefaults.Keys.preferedTerminal
                      )
                  }
                  Text("Users can choose their preferred terminal from the above supported terminal list")
                      .descriptionText()
            }
            Settings.Section(title: "Hotkey:") {
                KeyboardShortcuts.Recorder("", name: .toggleMiniSim)
                Text("Global shortcut to open the application \nDefault: ⌥⇧E")
                    .descriptionText()
            }
            Settings.Section(title: "simslim:") {
                HStack {
                    Image(systemName: simslimVersion == nil ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(simslimVersion == nil ? .red : .green)
                    Text(simslimVersion.map { "Installed (\($0))" } ?? "Not installed")
                }
                HStack {
                    Button("Check again") {
                        checkSimslim()
                    }
                    .disabled(isInstallingSimslim)
                    if simslimVersion == nil {
                        if Simslim.brewPath != nil {
                            Button("Install with Homebrew") {
                                installSimslim()
                            }
                            .disabled(isInstallingSimslim)
                        } else {
                            Button("Open install guide") {
                                if let url = URL(string: DeviceConstants.simslimRepositoryURL) {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }
                    }
                    if isInstallingSimslim {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                Text("Adds \"Launch slim\" to iOS simulators, turning off background \ndaemons a simulator doesn't need to use ~4x less memory.")
                    .descriptionText()
            }
            Settings.Section(title: "Cache:") {
                Button("Clear cache") {
                    resetDefaults()
                }
                Text("This clears data saved in cache. \nFor example: developer tool paths.")
                    .descriptionText()
            }
            Settings.Section(title: "") {
                Divider()
                LaunchAtLogin.Toggle("Launch at login")
            }
        }
        .frame(minWidth: 650, minHeight: 450)
        .onAppear {
            checkSimslim()
            MenuImage.allCases.forEach { image in
                if UserDefaults.standard.menuImage == image.rawValue {
                    menuImageSelected = image.rawValue
                }
            }
        }
    }

    func checkSimslim() {
        DispatchQueue.global(qos: .userInitiated).async {
            let version = Simslim.version()
            DispatchQueue.main.async {
                simslimVersion = version
            }
        }
    }

    func installSimslim() {
        isInstallingSimslim = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Simslim.installWithBrew()
                let version = Simslim.version()
                DispatchQueue.main.async {
                    simslimVersion = version
                    isInstallingSimslim = false
                }
                MiniSim.showSuccessMessage(title: "simslim installed", message: version ?? "")
            } catch {
                DispatchQueue.main.async {
                    isInstallingSimslim = false
                }
                NSAlert.showError(message: error.localizedDescription)
            }
        }
    }

    func resetDefaults() {
        let shouldReset = NSAlert.showQuestionDialog(
            title: "Are you sure?",
            message: "This will reset cache and quit the app."
        )
        if shouldReset {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
            NSApp.terminate(nil)
        }
    }
}
