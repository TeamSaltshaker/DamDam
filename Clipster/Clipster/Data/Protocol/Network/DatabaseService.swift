import Foundation

protocol DatabaseService {
    func dummyFetchFolders() async -> [FolderDTO]?
    func dummyDownloadScreenshot() async -> Data?
}
