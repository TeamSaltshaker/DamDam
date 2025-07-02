import Foundation
import Supabase

final class DefaultAuthService: AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func loginWithApple(token: String) async -> Result<Void, Error> {
        let credentials = OpenIDConnectCredentials(provider: .apple, idToken: token)

        do {
            let response = try await client.auth.signInWithIdToken(credentials: credentials)
            print("\(Self.self): ✅ Login Success. UID: \(response.user.id)")
            return .success(())
        } catch {
            print("\(Self.self): ❌ \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
