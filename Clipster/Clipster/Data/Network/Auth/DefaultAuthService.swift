import Foundation
import Supabase

final class DefaultAuthService: AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func loginWithApple(token: String) async {
        let credentials = OpenIDConnectCredentials(provider: .apple, idToken: token)

        do {
            let response = try await client.auth.signInWithIdToken(credentials: credentials)

            print("id: \(response.user.id)")
            print("createdAt: \(response.user.createdAt)")
        } catch {
            print("error: \(error.localizedDescription)")
        }
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
