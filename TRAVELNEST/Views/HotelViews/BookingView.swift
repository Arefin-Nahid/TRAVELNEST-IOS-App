import SwiftUI
import FirebaseAuth

struct BookingView: View {
    let hotel: Hotel
    @Environment(\.dismiss) var dismiss
    @StateObject private var bookingViewModel = BookingViewModel()
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date().addingTimeInterval(86400)
    @State private var numberOfGuests = 2
    @State private var showingConfirmation = false
    @State private var isProcessing = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Booking Details")) {
                    DatePicker("Check-in", selection: $checkInDate, displayedComponents: .date)
                    DatePicker("Check-out", selection: $checkOutDate, displayedComponents: .date)
                    Stepper("Number of Guests: \(numberOfGuests)", value: $numberOfGuests, in: 1...10)
                }
                
                Section(header: Text("Price Details")) {
                    HStack {
                        Text("Price per night")
                        Spacer()
                        Text("$\(String(format: "%.2f", hotel.price))")
                    }
                    
                    HStack {
                        Text("Number of nights")
                        Spacer()
                        Text("\(numberOfNights)")
                    }
                    
                    HStack {
                        Text("Total Price")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", totalPrice))")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    Button {
                        confirmBooking()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Confirm Booking")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(isProcessing)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Book \(hotel.name)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .alert("Booking Confirmed", isPresented: $showingConfirmation) {
                Button("OK") {
                    NotificationCenter.default.post(name: .bookingUpdated, object: nil)
                    dismiss()
                }
            } message: {
                Text("Your booking has been confirmed for \(numberOfNights) nights at \(hotel.name)")
            }
        }
    }
    
    private func confirmBooking() {
        isProcessing = true
        
        Task {
            do {
                let booking = Booking(
                    id: UUID().uuidString,
                    userId: Auth.auth().currentUser?.uid ?? "",
                    hotelId: hotel.id,
                    hotelName: hotel.name,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    numberOfGuests: numberOfGuests,
                    totalPrice: totalPrice,
                    status: .confirmed,
                    createdAt: Date()
                )
                
                try await FirebaseManager.shared.saveBooking(booking)
                NotificationCenter.default.post(name: .bookingUpdated, object: nil)
                
                await MainActor.run {
                    isProcessing = false
                    showingConfirmation = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private var numberOfNights: Int {
        Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 0
    }
    
    private var totalPrice: Double {
        hotel.price * Double(numberOfNights)
    }
}

extension Notification.Name {
    static let bookingUpdated = Notification.Name("bookingUpdated")
} 