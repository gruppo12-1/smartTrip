//
//  ContentView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//
import SwiftUI
import MapKit
import AVFAudio
import BottomSheet

// Questa funzione richiede i risultati dell'interrogazione al database e restituisce un array di strutture UndiscoveredPlace  appositamente creare per contenere le informazioni necessarie a generare una annotazione sulla mappa
func mapMarker(fetchedCollectableItem: FetchedResults<CollectableItem>)->[UndiscoveredPlace]{
    var locationArray = [UndiscoveredPlace]()
    for elemento in fetchedCollectableItem {
            locationArray.append(UndiscoveredPlace(id: elemento.id ?? UUID(), lat: Double(elemento.latitude), long: Double(elemento.longitude)))
    }
    return locationArray
}


struct ContentView: View {
    
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
    
    public enum BottomSheetPosition: CGFloat, CaseIterable {
        case top = 0.4, middle = 0.3999, bottom = 0.17, hidden = 0
    }
    
    @FetchRequest<CollectableItem>(entity: CollectableItem.entity(), sortDescriptors: []) var collectableItem : FetchedResults<CollectableItem> //Interrogo il database per recuperare i collezionabil
    
    
    var body: some View {
        NavigationView{
            
            GeometryReader { geo in
                let hz = geo.frame(in: .global).height
                let vt = geo.frame(in: .global).width
                ZStack {
                
                    MapView(annotations: mapMarker(fetchedCollectableItem: collectableItem)).ignoresSafeArea()
                    
                    if hz < vt {
                        
                        
                        HStack(alignment: .center, content: {
                                Rectangle().opacity(0)
                                    .bottomSheet(
                                        bottomSheetPosition: $bottomSheetPosition,
                                        options: [
                                            .dragIndicatorColor(Color.red),
                                            .cornerRadius(25),
                                        ],
                                        headerContent:{BottomBar()})
                                {BodyContent()}
                                Rectangle().opacity(0)
                        })
                    } else {
                        
                        
                        HStack(alignment: .center, content: {
                                Rectangle().opacity(0)
                                    .bottomSheet(
                                        bottomSheetPosition: $bottomSheetPosition,
                                        options: [
                                            .dragIndicatorColor(Color.red),
                                            .cornerRadius(25),
                                        ],
                                        headerContent:{BottomBar()})
                                {BodyContent()}
                        })
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }.navigationViewStyle(.stack)
            .statusBar(hidden: true)
        
    }
    
}




struct BodyContent: View {
    
    var body: some View {
        Text("Contenuto del body")
        
    }
    
}




struct BottomBar: View{
    
    @State var showSheet: Bool = false
    
    var body: some View{
        HStack{
            NavigationLink(destination: CollectionView(), label: {Text("Inventario").padding(10)})
            Spacer()
            NavigationLink(destination: AccountView(), label: {Text("Profilo").padding(10)})
        }
    }
    
}

// Struttura realizzata ad hoc per contenere i risultati dell'interrogazione al database
struct UndiscoveredPlace: Identifiable{
    
    let id: UUID
    let location: CLLocationCoordinate2D
    
    init(id: UUID , lat: Double , long:Double ){
        self.id = id
        self.location = CLLocationCoordinate2D(latitude:lat,longitude:long)
    }
    
}

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var willMoveToInventory: Bool = false
    
    var annotations: [UndiscoveredPlace]
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: annotations){
            place in MapAnnotation(coordinate: place.location){
                 Image(systemName: "questionmark")  //Mostro un punto interrogativo
            }
        }
            .onAppear{
                viewModel.checkIfLocationManagerIsEnabled()
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
        ContentView().previewDevice("iPhone 11").environment(\.managedObjectContext, PersistanceController.preview.container.viewContext).previewInterfaceOrientation(.portrait)
    }
}
