import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            BookingHomeView()
                .tabItem {
                    Label("Book", systemImage: "calendar.badge.plus")
                }

            MyBookingsView()
                .tabItem {
                    Label("My Bookings", systemImage: "person.crop.rectangle")
                }

            if authViewModel.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "gearshape.2")
                    }
            }
        }
    }
}
