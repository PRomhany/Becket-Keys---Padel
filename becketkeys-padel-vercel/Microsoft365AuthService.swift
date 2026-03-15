import Foundation

final class Microsoft365AuthService: AuthServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let storageKey = "becketkeys.saved.user"

    func restoreSession() async -> StaffUser? {
        guard let data = userDefaults.data(forKey: storageKey),
              let user = try? JSONDecoder().decode(StaffUser.self, from: data) else {
            return nil
        }
        return user
    }

    func signInInteractively() async throws -> StaffUser {
        // Replace this temporary bridge with a real Microsoft 365 login using MSAL.
        // Suggested claims to request:
        // - profile
        // - openid
        // - email
        // Validate that the returned email ends with the school domain.
        throw AuthError.notConfigured
    }

    func signOut() async {
        userDefaults.removeObject(forKey: storageKey)
    }

    func saveUser(_ user: StaffUser) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: storageKey)
        }
    }
}

enum AuthError: LocalizedError {
    case notConfigured
    case invalidDomain

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Microsoft 365 sign-in is scaffolded but not connected yet. Add MSAL and your Azure app registration details in Microsoft365AuthService.swift."
        case .invalidDomain:
            return "Only Becket Keys School staff accounts can sign in."
        }
    }
}
