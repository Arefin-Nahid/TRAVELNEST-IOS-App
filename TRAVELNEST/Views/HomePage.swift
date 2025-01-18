import SwiftUI

struct HomePage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var hotelViewModel = HotelViewModel()
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    var filteredHotels: [Hotel] {
        let hotels = hotelViewModel.allHotels
        
        // First filter by category
        let categoryFiltered = selectedCategory == "All" 
            ? hotels 
            : hotels.filter { $0.category == selectedCategory }
        
        // Then filter by search text
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter { hotel in
            hotel.name.localizedCaseInsensitiveContains(searchText) ||
            hotel.location.localizedCaseInsensitiveContains(searchText) ||
            hotel.description.localizedCaseInsensitiveContains(searchText) ||
            hotel.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomNavigationBar(searchText: $searchText)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if searchText.isEmpty {
                            FeaturedHotelsSection(hotelViewModel: hotelViewModel)
                            RecommendedHotelsSection(hotelViewModel: hotelViewModel)
                            CategoriesSection(selectedCategory: $selectedCategory)
                        }
                        
                        PopularHotelsSection(hotelViewModel: hotelViewModel, hotels: filteredHotels)
                        
                        if searchText.isEmpty {
                            SpecialOffersSection(hotelViewModel: hotelViewModel)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Custom Navigation Bar
struct CustomNavigationBar: View {
    @Binding var searchText: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingProfile = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    showingProfile = true
                }) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Hello,")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(authViewModel.currentUser?.fullName ?? "Guest")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search Hotels", text: $searchText)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 5)
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}

// Featured Hotels Section
struct FeaturedHotelsSection: View {
    @ObservedObject var hotelViewModel: HotelViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Featured Hotels")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if hotelViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if hotelViewModel.featuredHotels.isEmpty {
                Text("No featured hotels available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(hotelViewModel.featuredHotels) { hotel in
                            FeaturedHotelCard(hotel: hotel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// Featured Hotel Card
struct FeaturedHotelCard: View {
    let hotel: Hotel
    @State private var showingBooking = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Image section
            if let firstImage = hotel.images.first {
                Image(firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 200)
                    .cornerRadius(15)
            } else {
                Image("hotel_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 200)
                    .cornerRadius(15)
            }
            
            // Hotel Details
            VStack(alignment: .leading, spacing: 5) {
                Text(hotel.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                    Text(hotel.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(hotel.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    Text("(\(hotel.reviews) Reviews)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("$\(String(format: "%.2f", hotel.price))/night")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Button(action: {
                    showingBooking = true
                }) {
                    Text("Book Now")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .sheet(isPresented: $showingBooking) {
            BookingView(hotel: hotel)
        }
    }
}

// Categories Section
struct CategoriesSection: View {
    let categories = ["All", "Luxury", "Business", "Resort", "Beach"]
    @Binding var selectedCategory: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(category == selectedCategory ? Color.blue : Color.gray.opacity(0.1))
                                .foregroundColor(category == selectedCategory ? .white : .black)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Popular Hotels Section
struct PopularHotelsSection: View {
    @ObservedObject var hotelViewModel: HotelViewModel
    let hotels: [Hotel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Popular Hotels")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if hotelViewModel.isLoading {
                ProgressView()
            } else {
                VStack(spacing: 15) {
                    ForEach(hotels) { hotel in
                        PopularHotelCard(hotel: hotel)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Popular Hotel Card
struct PopularHotelCard: View {
    let hotel: Hotel
    @State private var isExpanded = false
    @State private var showingBooking = false
    
    var body: some View {
        VStack {
            // Main Card Content
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 15) {
                    Image(hotel.images.first ?? "hotel_placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(hotel.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.gray)
                            Text(hotel.location)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(hotel.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Text("$\(String(format: "%.2f", hotel.price))/night")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Details
            if isExpanded {
                VStack(alignment: .leading, spacing: 15) {
                    // Image Carousel
                    TabView {
                        ForEach(hotel.images, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(height: 200)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    // Description
                    Text("About")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(hotel.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Amenities
                    Text("Amenities")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(hotel.amenities, id: \.self) { amenity in
                            HStack {
                                Image(systemName: amenityIcon(for: amenity))
                                    .foregroundColor(.blue)
                                Text(amenity)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
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
                }
                .padding(.top)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
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

// Special Offers Section
struct SpecialOffersSection: View {
    @ObservedObject var hotelViewModel: HotelViewModel
    
    var specialOffers: [SpecialOffer] {
        hotelViewModel.featuredHotels.prefix(3).enumerated().map { index, hotel in
            SpecialOffer(
                id: UUID().uuidString,
                title: "Special Offer \(index + 1)",
                description: "Get \((index + 1) * 10)% off on \(hotel.name)",
                image: hotel.images.first ?? "hotel_placeholder",
                hotel: hotel,
                discount: (index + 1) * 10
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Special Offers")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(specialOffers, id: \.id) { offer in
                        SpecialOfferCard(offer: offer)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Special Offer Card
struct SpecialOfferCard: View {
    @State private var showingBooking = false
    let offer: SpecialOffer
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(offer.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 150)
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(offer.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showingBooking = true
                }) {
                    Text("Book Now")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .sheet(isPresented: $showingBooking) {
            BookingView(hotel: offer.hotel)
        }
    }
}

// Recommended Hotels Section
struct RecommendedHotelsSection: View {
    @ObservedObject var hotelViewModel: HotelViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recommended For You")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if hotelViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if hotelViewModel.recommendedHotels.isEmpty {
                Text("No recommendations available yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(hotelViewModel.recommendedHotels) { hotel in
                            RecommendedHotelCard(hotel: hotel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// Recommended Hotel Card
struct RecommendedHotelCard: View {
    let hotel: Hotel
    @State private var showingBooking = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Image
            if let firstImage = hotel.images.first {
                Image(firstImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 150)
                    .cornerRadius(15)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(hotel.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                    Text(hotel.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(hotel.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text("$\(String(format: "%.2f", hotel.price))/night")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Button(action: {
                    showingBooking = true
                }) {
                    Text("Book Now")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(10)
        }
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .sheet(isPresented: $showingBooking) {
            BookingView(hotel: hotel)
        }
    }
}

struct SpecialOffer {
    let id: String
    let title: String
    let description: String
    let image: String
    let hotel: Hotel
    let discount: Int
} 
