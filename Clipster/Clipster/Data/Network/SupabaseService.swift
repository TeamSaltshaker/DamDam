import Foundation
import Supabase

final class SupabaseService {
    private let client: SupabaseClient

    init(url: URL, key: String) {
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }

    #if DEBUG
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
    #endif
}
