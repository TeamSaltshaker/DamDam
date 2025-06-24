import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    private var client: SupabaseClient?

    private init() {
        let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        let key = Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String ?? ""

        if let url = URL(string: urlString) {
            client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        } else {
            print("\(Self.self): ❌ Invalid URL")
        }
    }

    #if DEBUG
    func dummyFetchFolders() async -> [FolderDTO]? {
        try? await client?
            .from("Folders")
            .select()
            .execute()
            .value
    }

    func dummyDownloadScreenshot() async -> Data? {
        try? await client?
            .storage
            .from("screenshots")
            .download(path: "testuser/testimage.png")
    }
    #endif
}
