import Foundation

protocol ExtractURLFromPasteboardUseCase {
    func execute() async -> URL?
}
