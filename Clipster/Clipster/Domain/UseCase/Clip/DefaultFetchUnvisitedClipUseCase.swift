final class DefaultFetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase {
    private let clipRepository: ClipRepository

     init(clipRepository: ClipRepository) {
         self.clipRepository = clipRepository
     }

    func execute() async -> Result<[Clip], Error> {
        clipRepository.fetchUnvisitedClips().mapError { $0 as Error }
    }
}
