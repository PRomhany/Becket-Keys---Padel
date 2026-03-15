import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject private var bookingViewModel: BookingViewModel

    var body: some View {
        NavigationStack {
            List {
                if bookingViewModel.bookingsForUser(on: bookingViewModel.selectedDate).isEmpty {
                    ContentUnavailableView(
                        "No bookings for this day",
                        systemImage: "calendar",
                        description: Text("Choose a day in the Book tab and reserve a court.")
                    )
                } else {
                    ForEach(bookingViewModel.bookingsForUser(on: bookingViewModel.selectedDate)) { booking in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Court \(booking.courtNumber)")
                                .font(.headline)
                            Text(booking.slotLabel)
                            Text(booking.selectedDayLine)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Bookings")
        }
    }
}

private extension Booking {
    var selectedDayLine: String {
        startDate.displayDayString
    }
}
