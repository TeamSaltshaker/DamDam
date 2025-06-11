import Foundation

protocol UpdateClipUseCase {
    func execute(clip: Clip) async -> Result<Void, Error>
}
