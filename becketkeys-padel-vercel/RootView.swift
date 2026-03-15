import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var bookingViewModel: BookingViewModel

    var body: some View {
        Group {
            if let _ = authViewModel.currentUser {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .task(id: authViewModel.currentUser?.id) {
            if authViewModel.currentUser != nil {
                await bookingViewModel.loadBookings()
            }
        }
    }
}
