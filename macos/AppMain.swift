import AppKit
import SafariServices

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 320),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "IHateShorts"
        window.titlebarAppearsTransparent = true

        let contentView = NSView(frame: window.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]
        window.contentView = contentView

        let titleLabel = NSTextField(labelWithString: "IHateShorts for Safari")
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 240, width: 400, height: 28)
        contentView.addSubview(titleLabel)

        let descLabel = NSTextField(wrappingLabelWithString: "Easily block YouTube Shorts from your feed and sidebar navigation.")
        descLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        descLabel.textColor = .secondaryLabelColor
        descLabel.alignment = .center
        descLabel.frame = NSRect(x: 30, y: 195, width: 380, height: 36)
        contentView.addSubview(descLabel)

        let stepsBox = NSBox(frame: NSRect(x: 30, y: 80, width: 380, height: 100))
        stepsBox.title = "How to enable:"
        stepsBox.titleFont = NSFont.systemFont(ofSize: 11, weight: .semibold)

        let stepsText = NSTextField(wrappingLabelWithString: "1. Click the button below to open Safari Extensions.\n2. Check the box next to IHateShorts.\n3. Refresh any YouTube tab to hide all Shorts.")
        stepsText.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        stepsText.textColor = .labelColor
        stepsText.frame = NSRect(x: 15, y: 10, width: 350, height: 65)
        stepsBox.contentView?.addSubview(stepsText)
        contentView.addSubview(stepsBox)

        let openButton = NSButton(title: "Open Safari Settings…", target: self, action: #selector(openSafariSettings))
        openButton.bezelStyle = .rounded
        openButton.isHighlighted = true
        openButton.frame = NSRect(x: 130, y: 25, width: 180, height: 32)
        contentView.addSubview(openButton)

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openSafariSettings() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.anshtyagi.IHateShorts.Extension") { error in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Open Safari Settings"
                    alert.informativeText = "Please open Safari > Settings > Extensions and enable IHateShorts."
                    alert.runModal()
                }
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
