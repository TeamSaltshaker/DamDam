import Foundation

final class MockItemProvider: NSItemProvider {
    private let _registeredTypeIdentifiers: [String]
    private let itemToLoad: NSSecureCoding?
    private let errorToThrow: Error?

    init(
        item: NSSecureCoding?,
        error: Error? = nil,
        typeIdentifiers: [
            String] = []
    ) {
        self.itemToLoad = item
        self.errorToThrow = error
        self._registeredTypeIdentifiers = typeIdentifiers
        super.init(item: nil, typeIdentifier: nil)
    }

    override var registeredTypeIdentifiers: [String] {
        return _registeredTypeIdentifiers
    }

    override func loadItem(
        forTypeIdentifier typeIdentifier: String,
        options: [AnyHashable : Any]? = nil,
        completionHandler: NSItemProvider.CompletionHandler? = nil
    ) {
        if let error = errorToThrow {
            completionHandler?(nil, error)
        } else {
            completionHandler?(itemToLoad, nil)
        }
    }
}

class MockExtensionItem: NSExtensionItem {
    private var _mockAttachments: [NSItemProvider]?

    override var attachments: [NSItemProvider]? {
        get {
            return _mockAttachments
        }
        set {
            _mockAttachments = newValue
        }
    }

    init(attachments: [NSItemProvider]?) {
        self._mockAttachments = attachments
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
