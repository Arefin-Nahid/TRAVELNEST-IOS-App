import SwiftUI

struct HotelDetailView: View {
    let hotel: Hotel
    @State private var showingBooking = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Carousel
                TabView(selection: $selectedImageIndex) {
                    ForEach(hotel.images.indices, id: \.self) { index in
                        Image(hotel.images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .tag(index)
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack(alignment: .leading, spacing: 15) {
                    // Hotel Info
                    HStack {
                        Text(hotel.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", hotel.price))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    // Location
                    HStack {
                        Image(systemName: "location.fill")
                        Text(hotel.location)
                    }
                    .foregroundColor(.gray)
                    
                    // Rating and Reviews
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(hotel.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Text("(\(hotel.reviews) Reviews)")
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(hotel.description)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Amenities
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Amenities")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(hotel.amenities, id: \.self) { amenity in
                                HStack {
                                    Image(systemName: amenityIcon(for: amenity))
                                        .foregroundColor(.blue)
                                    Text(amenity)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Policies
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hotel Policies")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        PolicyRow(icon: "clock.fill", title: "Check-in", detail: "2:00 PM - 12:00 AM")
                        PolicyRow(icon: "clock", title: "Check-out", detail: "11:00 AM")
                        PolicyRow(icon: "creditcard.fill", title: "Payment", detail: "Secure online payment")
                    }
                    
                    // Book Now Button
                    Button(action: {
                        showingBooking = true
                    }) {
                        Text("Book Now")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingBooking) {
            BookingView(hotel: hotel)
        }
    }
    
    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case let x where x.contains("wifi"): return "wifi"
        case let x where x.contains("pool"): return "figure.pool.swim"
        case let x where x.contains("gym"): return "dumbbell.fill"
        case let x where x.contains("spa"): return "sparkles"
        case let x where x.contains("restaurant"): return "fork.knife"
        case let x where x.contains("bar"): return "wineglass.fill"
        case let x where x.contains("parking"): return "car.fill"
        default: return "checkmark.circle.fill"
        }
    }
}

struct PolicyRow: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(detail)
                .foregroundColor(.gray)
        }
    }
} 