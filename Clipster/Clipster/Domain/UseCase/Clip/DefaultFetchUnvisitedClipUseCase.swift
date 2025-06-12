final class DefaultFetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase {
    private let clipRepository: ClipRepository

     init(clipRepository: ClipRepository) {
         self.clipRepository = clipRepository
     }

    func execute() async -> Result<[Clip], Error> {
        await clipRepository.fetchUnvisitedClips()
            .map { clips in
                clips.sorted { $0.createdAt > $1.createdAt }
            }
            .mapError { $0 as Error }
    }
}
