import Foundation

protocol FetchAllClipsUseCase {
    func execute() async -> Result<[Clip], Error>
}
