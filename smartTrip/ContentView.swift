//
//  ContentView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import MapKit
import AVFAudio

struct ContentView: View {
    var body: some View {
        MapView()
    }
}

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var willMoveToInventory: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                    .onAppear{
                        viewModel.checkIfLocationManagerIsEnabled()
                    }
                HStack{
                    NavigationLink(destination: CollectionView(), label: {Text("Inventario").padding(10)})
                    Spacer()
                    NavigationLink(destination: AccountView(), label: {Text("Profilo").padding(10)})
                }
            }.navigationBarHidden(true)
        }
    }
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.70024528747822,longitude: 14.707543253794043),span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationManagerIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        }else{
            // alert to turn on location manager
        }
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // alert
            print("Your location is restrict likely due to parental controls.")
        case .denied:
            // alert
            print("You have denied this app location. Go into settings to change it")
        case .authorizedAlways,  .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 40.70024528747822,longitude: 14.707543253794043), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
    }
}
