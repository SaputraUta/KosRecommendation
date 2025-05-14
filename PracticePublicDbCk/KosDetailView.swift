//
//  KosDetailView.swift
//  PracticePublicDbCk
//
//  Created by Saputra on 13/05/25.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct KosDetailView: View {
    @Environment(KosRecommendationViewModel.self) var model
    @State private var showEditSheet = false
    @State private var mapRegion: MapCameraPosition = .automatic
    let kos: KosRecommendation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(kos.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(kos.datePosted.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ulasan")
                        .font(.headline)
                    Text(kos.review)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                
                if let location = kos.location?.coordinate {
                    let point = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lokasi")
                            .font(.headline)
                        
                        Map(position: $mapRegion) {
                            Annotation("Lokasi Kos", coordinate: point) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title)
                            }
                        }
                        .onAppear {
                            mapRegion = .region(MKCoordinateRegion(
                                center: point,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        }
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            openInMaps(coordinate: location)
                        } label: {
                            Label("Lihat di Apple Maps", systemImage: "map")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.top, 4)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lokasi")
                            .font(.headline)
                        Text("Lokasi tidak tersedia")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detail Kos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            FormKosRecommendationView(editingKos: kos)
        }
    }
    
    private func openInMaps(coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = kos.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}


#Preview {
    let sampleKos = KosRecommendation(
        name: "Kos Asri Kuta", review: "Tempatnya nyaman dan strategis dekat pantai Kuta.", location: CLLocation(latitude: -8.719083, longitude: 115.1699)
    )
    NavigationStack {
        KosDetailView(kos: sampleKos).environment(KosRecommendationViewModel())
    }
}
