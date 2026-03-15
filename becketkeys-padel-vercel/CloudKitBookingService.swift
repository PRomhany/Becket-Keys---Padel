import Foundation
import CloudKit

final class CloudKitBookingService: BookingServiceProtocol {
    private let database = CKContainer.default().publicCloudDatabase

    func fetchBookings(for day: Date) async throws -> [Booking] {
        let start = day.startOfDayLocal
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start

        let predicate = NSPredicate(
            format: "startDate >= %@ AND startDate < %@",
            start as NSDate,
            end as NSDate
        )

        let query = CKQuery(recordType: Booking.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

        let records = try await database.records(matching: query)
        return records.matchResults.compactMap { _, result in
            switch result {
            case .success(let record):
                return Booking(record: record)
            case .failure:
                return nil
            }
        }
        .sorted {
            if $0.startDate == $1.startDate {
                return $0.courtNumber < $1.courtNumber
            }
            return $0.startDate < $1.startDate
        }
    }

    func saveBooking(courtNumber: Int, startDate: Date, staff: StaffUser) async throws {
        let booking = Booking(
            id: startDate.bookingRecordID(forCourt: courtNumber),
            courtNumber: courtNumber,
            startDate: startDate,
            endDate: startDate.addingMinutes(SchoolConfig.slotLengthMinutes),
            staffName: staff.name,
            staffEmail: staff.email,
            createdAt: Date()
        )
        _ = try await database.save(booking.asRecord())
    }

    func deleteBooking(_ booking: Booking) async throws {
        _ = try await database.deleteRecord(withID: CKRecord.ID(recordName: booking.id))
    }
}
