import Foundation

protocol DeleteClipUseCase {
    func execute(id: UUID) async -> Result<Void, Error>
}
