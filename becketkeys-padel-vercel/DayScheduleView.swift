import SwiftUI

struct DayScheduleView: View {
    @EnvironmentObject private var bookingViewModel: BookingViewModel

    var body: some View {
        List {
            ForEach(bookingViewModel.slots, id: \.self) { slot in
                Section(slot.slotTimeString) {
                    ForEach(1...SchoolConfig.numberOfCourts, id: \.self) { court in
                        row(for: court, slot: slot)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if bookingViewModel.isLoading {
                ProgressView("Loading bookings…")
            }
        }
    }

    @ViewBuilder
    private func row(for court: Int, slot: Date) -> some View {
        if let booking = bookingViewModel.booking(for: court, slotStart: slot) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Court \(court)")
                        .font(.headline)
                    Text(booking.staffName)
                        .foregroundStyle(.secondary)
                    Text(booking.sessionTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Cancel", role: .destructive) {
                    Task { await bookingViewModel.cancel(booking) }
                }
                .buttonStyle(.bordered)
            }
        } else {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Court \(court)")
                        .font(.headline)
                    Text("Available")
                        .foregroundStyle(.green)
                }
                Spacer()
                Button("Book") {
                    Task { await bookingViewModel.book(courtNumber: court, slotStart: slot) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!bookingViewModel.canBook(slot, on: court))
            }
        }
    }
}
