import Foundation

protocol ExtractURLUseCase {
    func execute() async -> Result<URL, PasteboardError>
}
