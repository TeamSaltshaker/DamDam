import Foundation

protocol ExtractURLPasteboardUseCase {
    func execute() async -> URL?
}
