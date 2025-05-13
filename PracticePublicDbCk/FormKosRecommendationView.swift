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
    @Environment(\.dismiss) var dismiss
    
    var editingKos: KosRecommendation? = nil
    
    @State private var kosName = ""
    @State private var review = ""
    @State private var mapRegion = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -8.719083, longitude: 115.1699), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var isEditing: Bool { editingKos != nil }
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Informasi Kos")) {
                    TextField("Nama Kos", text: $kosName)
                        .autocapitalization(.words)
                    
                    TextField("Review", text: $review, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section(header: Text("Lokasi Kos")) {
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
                        .frame(height: 250)
                        .cornerRadius(10)
                        .onTapGesture { location in
                            if let coord = proxy.convert(location, from: .local) {
                                selectedLocation = coord
                            }
                        }
                    }
                    
                    if let selected = selectedLocation {
                        Text("Lokasi dipilih: \(selected.latitude), \(selected.longitude)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tekan pada peta untuk memilih lokasi")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        Task { await submit() }
                    }) {
                        Text(isEditing ? "Perbarui" : "Simpan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                kosName.isEmpty || review.isEmpty || selectedLocation == nil
                                ? Color.gray.opacity(0.5)
                                : Color.blue
                            )
                            .cornerRadius(10)
                    }
                    .disabled(kosName.isEmpty || review.isEmpty || selectedLocation == nil)
                    
                    if let errorMessage {
                        Text("Gagal menyimpan: \(errorMessage)")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Review Kos" : "Tambah Review Kos")
            .onAppear {
                if let kos = editingKos {
                    kosName = kos.name
                    review = kos.review
                    if let location = kos.location?.coordinate {
                        selectedLocation = location
                        mapRegion = .region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                    }
                }
            }
            
            if isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView(isEditing ? "Memperbarui..." : "Menyimpan...")
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
            }
        }
    }
    
    func submit() async {
        isLoading = true
        errorMessage = nil
        
        let location = selectedLocation.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let kos: KosRecommendation
        
        if let editingKos {
            kos = KosRecommendation(
                id: editingKos.id,
                name: kosName,
                review: review,
                location: location
            )
        } else {
            kos = KosRecommendation(
                name: kosName,
                review: review,
                location: location
            )
        }
        
        do {
            if isEditing {
                try await model.updateRecommendation(kosItem: kos)
            } else {
                try await model.addKosRecommendation(kosItem: kos)
            }
            kosName = ""
            review = ""
            selectedLocation = nil
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}


#Preview {
    FormKosRecommendationView().environment(KosRecommendationViewModel())
}
