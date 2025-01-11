import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var bookingViewModel = BookingViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text(authViewModel.currentUser?.fullName ?? "Guest")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authViewModel.currentUser?.email ?? "")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Booking History
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Booking History")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if bookingViewModel.isLoading {
                                ProgressView()
                            }
                        }
                        .padding(.horizontal)
                        
                        if bookingViewModel.userBookings.isEmpty && !bookingViewModel.isLoading {
                            Text("No bookings yet")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(bookingViewModel.userBookings) { booking in
                                    BookingHistoryCard(booking: booking)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .onAppear {
                Task {
                    await bookingViewModel.loadUserBookings()
                }
            }
            .refreshable {
                Task {
                    await bookingViewModel.loadUserBookings()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .bookingUpdated)) { _ in
                Task {
                    await bookingViewModel.loadUserBookings()
                }
            }
        }
    }
}

struct BookingHistoryCard: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(booking.hotelName)
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Label(formatDate(booking.checkInDate),
                      systemImage: "calendar")
                Text("→")
                Label(formatDate(booking.checkOutDate),
                      systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            HStack {
                Label("\(booking.numberOfGuests) Guests", systemImage: "person.2")
                Spacer()
                Text("$\(String(format: "%.2f", booking.totalPrice))")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Text(booking.status.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .confirmed: return .green
        case .pending: return .orange
        case .completed: return .blue
        case .cancelled: return .red
        }
    }
} 
