import Foundation

protocol AuthServiceProtocol {
    func restoreSession() async -> StaffUser?
    func signInInteractively() async throws -> StaffUser
    func signOut() async
}
