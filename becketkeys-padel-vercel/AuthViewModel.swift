import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: StaffUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = Microsoft365AuthService()

    func restoreSessionIfPossible() async {
        isLoading = true
        currentUser = await authService.restoreSession()
        isLoading = false
    }

    func signInForPreview(name: String, email: String) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard SchoolConfig.isAllowedStaffEmail(cleanedEmail) else {
            errorMessage = AuthError.invalidDomain.errorDescription
            return
        }

        let user = StaffUser(
            id: UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: cleanedEmail,
            isAdmin: SchoolConfig.isAdminEmail(cleanedEmail)
        )
        authService.saveUser(user)
        currentUser = user
        errorMessage = nil
    }

    func startMicrosoftSignIn() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await authService.signInInteractively()
            guard SchoolConfig.isAllowedStaffEmail(user.email) else {
                throw AuthError.invalidDomain
            }
            authService.saveUser(user)
            currentUser = user
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func signOut() async {
        await authService.signOut()
        currentUser = nil
    }
}
