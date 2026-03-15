import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var bookingViewModel: BookingViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Admin overview") {
                    LabeledContent("Courts", value: "\(SchoolConfig.numberOfCourts)")
                    LabeledContent("Advance booking window", value: "\(SchoolConfig.maxAdvanceBookingDays) days")
                    LabeledContent("Email domain", value: SchoolConfig.allowedEmailSuffixes.joined(separator: ", "))
                }

                Section("Today") {
                    ForEach(bookingViewModel.bookings) { booking in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Court \(booking.courtNumber) · \(booking.slotLabel)")
                                .font(.headline)
                            Text(booking.staffName)
                            Text(booking.staffEmail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Admin")
        }
    }
}
