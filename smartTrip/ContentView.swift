//
//  ContentView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//
import SwiftUI
import MapKit
import CoreLocation
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
            .navigationTitle("Map")
            .navigationBarHidden(true)
        }.navigationViewStyle(.stack)
//            .statusBar(hidden: true)
        
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
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MapViewModel()
    @State private var willMoveToInventory: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var annotations: [UndiscoveredPlace]
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: annotations){
            place in MapAnnotation(coordinate: place.location){
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 20, height: 30, alignment: .center)
                    .foregroundColor(Color.blue)
                    .frame(width: 50, height: 50)
                    .background(colorScheme == .dark ? Color.init(white: 0.1) : Color.init(white: 0.9))
                    .clipShape(Circle())
                    .overlay(Circle().stroke())
            }
        }
            .onAppear{
                viewModel.checkIfLocationManagerIsEnabled()
            }
            .onReceive(timer){ _ in
                viewModel.checkLocation(locations: annotations)
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
            locationManager!.allowsBackgroundLocationUpdates = true
            locationManager!.showsBackgroundLocationIndicator = true
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
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func checkLocation(locations: [UndiscoveredPlace]){
        if locationManager?.authorizationStatus == .authorizedAlways || locationManager?.authorizationStatus == .authorizedWhenInUse{
            print("ok")
            ForEach(locations){ location in
                if(self.isNearTheItem(location1: self.locationManager!.location!.coordinate, location2: location.location)){
                    // implementare il confronto della posizione dell'utente con quella dei markers
                }
            }
        }
    }
    
    func isNearTheItem(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Bool{
        // cambiare epsilon in base alla precisione che si desidera
        let epsilon : CGFloat = 2.0
        return (fabs(location1.latitude - location2.latitude) <= epsilon && fabs(location1.longitude - location2.longitude) <= epsilon)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice("iPhone 11").environment(\.managedObjectContext, PersistanceController.preview.container.viewContext).previewInterfaceOrientation(.portrait)
    }
}
