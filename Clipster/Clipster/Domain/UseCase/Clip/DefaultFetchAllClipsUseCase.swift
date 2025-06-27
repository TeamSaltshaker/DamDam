import Foundation

final class DefaultFetchAllClipsUseCase: FetchAllClipsUseCase {
    private let clipRepository: ClipRepository

    init(clipRepository: ClipRepository) {
        self.clipRepository = clipRepository
    }

    func execute() async -> Result<[Clip], Error> {
        .success([])
    }
}
