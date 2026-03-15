import SwiftUI

struct BookingHomeView: View {
    @EnvironmentObject private var bookingViewModel: BookingViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                bookingHeader
                DayScheduleView()
            }
            .navigationTitle(SchoolConfig.appTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Today") {
                            bookingViewModel.goToToday()
                        }
                        Button("Sign out", role: .destructive) {
                            Task { await authViewModel.signOut() }
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .task(id: bookingViewModel.selectedDate) {
                await bookingViewModel.loadBookings()
            }
            .alert("Update", isPresented: Binding(
                get: { bookingViewModel.successMessage != nil },
                set: { if !$0 { bookingViewModel.successMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(bookingViewModel.successMessage ?? "")
            }
            .alert("Issue", isPresented: Binding(
                get: { bookingViewModel.errorMessage != nil },
                set: { if !$0 { bookingViewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(bookingViewModel.errorMessage ?? "")
            }
        }
    }

    private var bookingHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    bookingViewModel.moveDay(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                VStack(spacing: 4) {
                    Text(bookingViewModel.selectedDate.displayDayString)
                        .font(.headline)
                    Text(authViewModel.currentUser?.name ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    bookingViewModel.moveDay(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }

            HStack(spacing: 12) {
                sessionChip(title: "Morning", subtitle: "7:00–8:00", systemImage: "sun.max")
                sessionChip(title: "After school", subtitle: "15:30–17:00", systemImage: "sunset")
            }
        }
        .padding()
    }

    private func sessionChip(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
