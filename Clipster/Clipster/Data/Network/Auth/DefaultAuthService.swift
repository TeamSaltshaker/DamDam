import Foundation
import Supabase

final class DefaultAuthService: AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func currentUserID() -> UUID? {
        client.auth.currentUser?.id
    }

    func loginWithApple(token: String) async -> Result<Void, Error> {
        let credentials = OpenIDConnectCredentials(provider: .apple, idToken: token)

        do {
            let response = try await client.auth.signInWithIdToken(credentials: credentials)
            print("\(Self.self): ✅ Login success. UID: \(response.user.id)")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Login With Apple Failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func logout() async -> Result<Void, Error> {
        do {
            try await client.auth.signOut()
            print("\(Self.self): ✅ Logout success")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Logout Failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func withdraw() async -> Result<Void, Error> {
        guard let user = client.auth.currentUser else {
            print("\(Self.self): ❌ Withdraw Failed. Not Logged In.")
            return .failure(AuthError.notLoggedIn)
        }

        do {
            try await client.auth.admin.deleteUser(id: user.id)
            print("\(Self.self): ✅ Withdraw success")
            return .success(())
        } catch {
            print("\(Self.self): ❌ Withdraw Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
