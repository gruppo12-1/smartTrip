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
import CoreData

// Questa funzione richiede i risultati dell'interrogazione al database e restituisce un array di strutture UndiscoveredPlace  appositamente creare per contenere le informazioni necessarie a generare una annotazione sulla mappa e contenenti l'item recuperato dal database

func mapMarker()->[UndiscoveredPlace]{
    let context = PersistanceController.preview.container.viewContext
    let req = NSFetchRequest<CollectableItem>(entityName: "CollectableItem") //Richiedo items al database
    let res = try! context.fetch(req)
    
    var locationArray = [UndiscoveredPlace]()
    
    for elemento in res {
        locationArray.append(UndiscoveredPlace(item: elemento))
    }
    return locationArray
}


struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
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
                
                    MapView(annotations: mapMarker() , context: viewContext).ignoresSafeArea()
                    
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
    
    let id : UUID
    let location: CLLocationCoordinate2D
    let item: CollectableItem
    
    init(item: CollectableItem ){
        self.id = item.id ?? UUID()
        self.location = CLLocationCoordinate2D(latitude:Double(item.latitude),longitude:Double(item.longitude))
        self.item = item
    }
    
}

struct MapView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MapViewModel()
    @State private var willMoveToInventory: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var showingSheet : Bool = false
    
    @State var annotations: [UndiscoveredPlace]
    let context : NSManagedObjectContext
    @State var placeDiscovered : UndiscoveredPlace?
    
    init(annotations:[UndiscoveredPlace] , context: NSManagedObjectContext){
        self.context = context
        _annotations = State(initialValue: annotations)
    }
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: annotations){
            place in MapAnnotation(coordinate: place.location){
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
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
                let returned  = viewModel.checkLocation(locations: annotations , context: context)
                    if returned > -1 {
                      placeDiscovered = annotations.remove(at: returned)
                      showingSheet.toggle()
                    print("Ho Raccolto un oggetto")
                    
                }
            }
            .sheet(isPresented: $showingSheet){
                SheetView(elementoScoperto: placeDiscovered!)
            }
    }
}

//SheetView che viene visualizzata all'atto dello sblocco

struct SheetView: View{
    
    let element : UndiscoveredPlace
    
    init(elementoScoperto: UndiscoveredPlace){
        self.element = elementoScoperto
    }
    
    var body : some View{
        VStack{
        Text("Hai sbloccato un nuovo item!!!")
//            Image(uiImage: UIImage(data: element.item.previewImage!)!).frame(width: 30, height: 30, alignment: .center)
            Text("\(element.item.name ?? "Ogetto senza nome")")
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
//        print(locations)
    }
    
    func checkLocation(locations: [UndiscoveredPlace] , context: NSManagedObjectContext)-> Int{
        if locationManager?.authorizationStatus == .authorizedAlways || locationManager?.authorizationStatus == .authorizedWhenInUse{
            var i = 0
            for location in locations {
                if(self.isNearTheItem(location1: self.locationManager!.location!.coordinate, location2: location.location)){ // Tende a crashare se non si hanno i permessi
                    // Sono vicino all'oggetto, devo sbloccarlo
                    print("Sto girando qui")
                    let collectedItem = CollectedItem(context: context)
                    collectedItem.id = location.id
                    collectedItem.dateCollected = Date.now
                    collectedItem.item = queryForId(locationId:location.id , context: context)
                    do {
                        try context.save()
                        print("Collectable item saved")
                    } catch {
                        print(error.localizedDescription)
                    }
                 return i
                }
                i = i+1
            }
        }
        return -1
    }
    
 
    
    func queryForId( locationId: UUID, context: NSManagedObjectContext)-> CollectableItem?{
        let req = NSFetchRequest<CollectableItem>(entityName: "CollectableItem") //Richiedo items al database
        req.predicate = NSPredicate(format: "id == %@", locationId as CVarArg)
        let res = try! context.fetch(req)
        return res.first
        
    }
    
    func isNearTheItem(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Bool{
        // cambiare epsilon in base alla precisione che si desidera
        /*
        let epsilon : CGFloat = 0.1
        return (fabs(location1.latitude - location2.latitude) <= epsilon && fabs(location1.longitude - location2.longitude) <= epsilon)
         */
        let distance = 50.0
        let tmp = MKMapPoint(location1)
        if ( tmp.distance(to: MKMapPoint(location2)) < distance) {
            return true
        }
        return false
    }

    
}

    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice("iPhone 11").environment(\.managedObjectContext, PersistanceController.preview.container.viewContext).previewInterfaceOrientation(.portrait)
    }
}
