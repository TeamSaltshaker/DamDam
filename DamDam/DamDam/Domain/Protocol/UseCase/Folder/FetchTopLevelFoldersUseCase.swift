import Foundation

protocol FetchTopLevelFoldersUseCase {
    func execute() async -> Result<[Folder], Error>
}
