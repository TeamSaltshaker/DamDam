import Foundation
import Supabase

final class DefaultUserService: UserService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchUser(by id: UUID) async -> Result<UserDTO?, Error> {
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
            print("\(Self.self): ✅ Fetch Success. id: \(dto.id), nickname: \(dto.nickname)")
            return .success(dto)
        } catch {
            print("\(Self.self): ❌ Fetch Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func insertUser(with id: UUID) async -> Result<UserDTO, Error> {
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
            print("\(Self.self): ✅ Insert Success. id: \(insertedDTO.id)")
            return .success((insertedDTO))
        } catch {
            print("\(Self.self): ❌ Insert Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func updateNickname(_ nickname: String) async -> Result<UserDTO, Error> {
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
            print("\(Self.self): ✅ Update Success. id: \(updatedUserDTO.id), nickname: \(updatedUserDTO.nickname)")
            return .success(updatedUserDTO)
        } catch {
            print("\(Self.self): ❌ Update Failed. \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
