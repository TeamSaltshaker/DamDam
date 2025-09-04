import Foundation

protocol ExtractURLFromPasteboardUseCase {
    func execute() async -> Result<URL, PasteboardError>
}
