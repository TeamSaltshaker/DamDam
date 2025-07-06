import Foundation

protocol FolderService {
    func fetchFolder(by id: UUID) async -> Result<FolderDTO, DatabaseError>
    func fetchAllFolders() async -> Result<[FolderDTO], DatabaseError>
    func fetchTopLevelFolders() async -> Result<[FolderDTO], DatabaseError>
    func insertFolder(_ dto: FolderDTO) async -> Result<FolderDTO, DatabaseError>
    func updateFolder(_ dto: FolderDTO) async -> Result<FolderDTO, DatabaseError>
    func deleteFolder(_ dto: FolderDTO) async -> Result<FolderDTO, DatabaseError>
}
