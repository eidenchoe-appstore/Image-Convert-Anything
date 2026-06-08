import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct ImgConvertAnythingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ConversionStore()

    var body: some Scene {
        WindowGroup("Image Convert Anything") {
            ContentView(store: store)
                .frame(minWidth: 760, minHeight: 560)
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add Input...") {
                    store.presentInputPanel()
                }
                .keyboardShortcut("o", modifiers: [.command])

                Button("Choose Output Folder...") {
                    store.presentOutputPanel()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])

                Button("Open Settings...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: [.command])
            }

            CommandGroup(after: .saveItem) {
                Button("Convert") {
                    store.startConversion()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(!store.canConvert)

                Button("Cancel") {
                    store.cancelConversion()
                }
                .keyboardShortcut(".", modifiers: [.command])
                .disabled(!store.isConverting)
            }
        }

        Settings {
            SettingsView(store: store)
        }
    }
}
