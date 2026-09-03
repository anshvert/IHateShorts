import Foundation
import SafariServices

/**
 * Safari extension handler for communication between native app and web extension.
 */
@objc(SafariWebExtensionHandler)
public class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    public func beginRequest(with context: NSExtensionContext) {
        let item = NSExtensionItem()
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
