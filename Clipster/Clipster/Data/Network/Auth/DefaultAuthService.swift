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

    func login(loginType: LoginType, token: String) async -> Result<UUID, Error> {
        let provider: OpenIDConnectCredentials.Provider
        switch loginType {
        case .apple:
            provider = .apple
        case .google:
            provider = .google
        }
        let credentials = OpenIDConnectCredentials(provider: provider, idToken: token)

        do {
            let response = try await client.auth.signInWithIdToken(credentials: credentials)
            print("\(Self.self): ✅ Login success. Provider: \(loginType.title), UID: \(response.user.id)")
            return .success(response.user.id)
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
        do {
            let result = try await client.functions
                .invoke(
                    "delete-user",
                    options: FunctionInvokeOptions()
                ) { _, response in
                    response.statusCode
                }
            guard result == 200 else {
                print("\(Self.self): ❌ Withdraw Failed")
                return .failure(AuthError.withdrawFailed)
            }
            return await logout()
        } catch {
            print("\(Self.self): ❌ Withdraw Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
