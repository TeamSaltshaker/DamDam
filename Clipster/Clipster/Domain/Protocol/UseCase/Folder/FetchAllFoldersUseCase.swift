import Foundation

protocol FetchAllFoldersUseCase {
    func execute() async -> Result<[Folder], Error>
}
