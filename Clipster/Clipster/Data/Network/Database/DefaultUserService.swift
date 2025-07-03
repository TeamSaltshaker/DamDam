import Foundation
import Supabase

final class DefaultUserService: UserService {
    private let client: SupabaseClient
    private let mapper: DomainMapper

    init(
        client: SupabaseClient,
        mapper: DomainMapper,
    ) {
        self.client = client
        self.mapper = mapper
    }

    func fetchUser(by id: UUID) async -> Result<User?, Error> {
        do {
            let dtoList: [UserDTO] = try await client
                .from("Users")
                .select()
                .eq("id", value: id)
                .execute()
                .value
            guard let dto = dtoList.first else {
                return .success(nil)
            }
            let user = mapper.user(from: dto)
            print("\(Self.self): ✅ Fetch Success. id: \(user.id), nickname: \(user.nickname)")
            return .success(user)
        } catch {
            print("\(Self.self): ❌ Fetch Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func insertUser(with id: UUID) async -> Result<User, Error> {
        do {
            let dto = UserDTO(
                id: id,
                nickname: "김담담",
                createdAt: Date.now,
                updatedAt: Date.now,
                deletedAt: nil,
            )
            let insertedDTO: UserDTO = try await client
                .from("Users")
                .insert(dto)
                .select()
                .single()
                .execute()
                .value
            let insertedUser = mapper.user(from: insertedDTO)
            print("\(Self.self): ✅ Insert Success. id: \(insertedUser.id)")
            return .success((insertedUser))
        } catch {
            print("\(Self.self): ❌ Insert Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func updateNickname(_ nickname: String) async -> Result<User, Error> {
        do {
            guard let id = client.auth.currentUser?.id else {
                print("\(Self.self): ❌ Failed to update nickname. Not logged in.")
                return .failure(AuthError.notLoggedIn)
            }
            let updatedUserDTO: UserDTO = try await client
                .from("Users")
                .update(["nickname": nickname])
                .eq("id", value: id)
                .select()
                .single()
                .execute()
                .value
            let updatedUser = mapper.user(from: updatedUserDTO)
            print("\(Self.self): ✅ Update Success. id: \(updatedUser.id), nickname: \(updatedUser.nickname)")
            return .success(updatedUser)
        } catch {
            print("\(Self.self): ❌ Update Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
