import Foundation
import Supabase

final class DefaultDatabaseService: DatabaseService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func dummyFetchFolders() async -> [FolderDTO]? {
        try? await client
            .from("Folders")
            .select()
            .execute()
            .value
    }

    func dummyDownloadScreenshot() async -> Data? {
        try? await client
            .storage
            .from("screenshots")
            .download(path: "testuser/testimage.png")
    }
}
