//
//  FormKosRecommendationView.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 12/05/25.
//

import SwiftUI
import MapKit

struct FormKosRecommendationView: View {
    @Environment(KosRecommendationViewModel.self) var model
    @State private var kosName = ""
    @State private var review = ""
    @State private var mapRegion = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.719083, longitude: 115.1699), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        Form {
            Section("Informasi Kos") {
                TextField("Nama Kos", text: $kosName)
                TextField("Review", text: $review)
            }
            
            Section("Lokasi Kos") {
                MapReader { proxy in
                    Map(initialPosition: mapRegion) {
                        if let selected = selectedLocation {
                            Annotation("Lokasi Kos", coordinate: selected) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title)
                            }
                        }
                    }
                    .onTapGesture { location in
                        if let coord = proxy.convert(location, from: .local) {
                            selectedLocation = coord
                        }
                    }
                    .frame(height: 250)
                }
                
                if let selected = selectedLocation {
                    Text("Lokasi dipilih: \(selected.latitude), \(selected.longitude)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Tekan pada peta untuk pilih lokasi")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                if isLoading {
                    ProgressView()
                }
                
                if let errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                }
                
                Button(action: {
                    Task {
                        await submit()
                    }
                }) {
                    Text("Simpan")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            kosName.isEmpty || review.isEmpty || selectedLocation == nil ?
                            LinearGradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                }
                .padding(.vertical, 5)
                .disabled(kosName.isEmpty || review.isEmpty || selectedLocation == nil)            }
            .navigationTitle("Tambah Review Kos")
        }
        
    }
    
    func submit() async {
        isLoading = true
        errorMessage = nil
        
        let location = selectedLocation.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let kos = KosRecommendation(name: kosName, review: review, location: location)
        
        do {
            try await model.addKosRecommendation(kosItem: kos)
            kosName = ""
            review = ""
            selectedLocation = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    FormKosRecommendationView().environment(KosRecommendationViewModel())
}
