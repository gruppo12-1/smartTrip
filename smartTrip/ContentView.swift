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

// Questa funzione richiede i risultati dell'interrogazione al database e restituisce un array di strutture UndiscoveredPlace appositamente creare per contenere le informazioni necessarie a generare una annotazione sulla mappa e contenenti l'item recuperato dal database

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
    
    @StateObject private var viewModel = MapViewModel()
    
    @State private  var bottomSheetPosition: BottomSheetPosition = .bottom
    @State private  var bottomSheetPositionH: BottomSheetPositionH = .bottomh
    
    public enum BottomSheetPosition: CGFloat, CaseIterable {
        case top = 0.4, middle = 0.3999, bottom = 0.14, hidden = 0
    }
    
    public enum BottomSheetPositionH: CGFloat, CaseIterable {
        case toph = 0.8, middleh = 0.7999, bottomh = 0.27, hiddenh = 0
    }
    
    @FetchRequest<CollectableItem>(entity: CollectableItem.entity(), sortDescriptors: []) var collectableItem : FetchedResults<CollectableItem> //Interrogo il database per recuperare i collezionabil
    
    @State private var annotations = mapMarker()
    
    var body: some View {
        NavigationView{
            GeometryReader { geo in
                let screenHeight = geo.frame(in: .global).height
                let screenWidth = geo.frame(in: .global).width
                ZStack {
                    MapView(annotations: $annotations , context: viewContext, mapViewModel: viewModel).ignoresSafeArea()
                    if screenHeight < screenWidth { //layout orizzontale
                        HStack(alignment: .center, content: {
                                Rectangle().opacity(0)
                                    .bottomSheet(
                                        bottomSheetPosition: $bottomSheetPositionH,
                                        options: [
                                            .dragIndicatorColor(Color.red),
                                            .cornerRadius(25),
                                        ],
                                        headerContent:{BottomBar()})
                            {BodyContent(annotations: $annotations, viewModel: viewModel)}
                                Rectangle().opacity(0)
                        })
                    } else { //layout verticale
                        HStack(alignment: .center, content: {
                                Rectangle().opacity(0)
                                    .bottomSheet(
                                        bottomSheetPosition: $bottomSheetPosition,
                                        options: [
                                            .dragIndicatorColor(Color.red),
                                            .cornerRadius(25),
                                        ],
                                        headerContent:{BottomBar()})
                            {BodyContent(annotations: $annotations, viewModel: viewModel)}
                        })
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

func createView(element: UndiscoveredPlace, viewModel: MapViewModel) -> some View {
    return VStack{
        Text("\(element.item.name ?? "Senza nome")")
            .font(.title3)
            .scaledToFit()
        Image(systemName: "questionmark")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 70, height: 70, alignment:  .center)
        Text("\(Double(( MKMapPoint(viewModel.locationManager?.location!.coordinate ?? CLLocationCoordinate2D.init(latitude: 0, longitude: 0) ).distance(to: MKMapPoint(element.location)))/1000), specifier: "%.2f") Km")
        /*
         La riga sopra sembra funzionare ma è da tenere d'occhio, in teoria non uscità mai la CLLocation(0,0) perchè l'elemento viene computato ma poi eliminato dalla view immediatamente
         */
    }.foregroundColor(Color.blue)
}

struct BodyContent: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel : MapViewModel
    
    @Binding var annotations : [UndiscoveredPlace]
    
    @State var tap = false
    
    init(annotations: Binding<[UndiscoveredPlace]>, viewModel : MapViewModel){
        
        self._annotations = annotations
        self.viewModel = viewModel
    }

    var body: some View {
        
        ScrollView(Axis.Set.horizontal, showsIndicators: true){
            HStack (spacing: 10){
               
                ForEach(annotations , id: \.id){ element in
                    Button(action:{
                        
                    }){
                        GeometryReader{ geometry in
                                createView(element: element, viewModel: viewModel).onTapGesture {
                                    print("Hanno toccato \(element.item.name ?? "Errore nel tocco")") //Funzionaaaaa associa il tocco ad ogni elemento
                                    viewModel.region = MKCoordinateRegion(center: element.location, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0) // Sposto la mappa sull'elemento desiderato
                                }
                                .frame(width:geometry.size.width, height: geometry.size.height)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue).shadow(radius: 40))
                                .rotation3DEffect(Angle(degrees: (Double(geometry.frame(in: .global).minX)) / -10), axis: (x:20.0, y:50.0, z:20.0))
                        }
                        .frame(width: 150, height: 160)
                        .padding(10)
                    }

                }
            }
        }.padding(20)
    }
}

struct BottomBar: View{
    
    @State var showSheet: Bool = false
    
    var body: some View{
        HStack{
            NavigationLink(destination: CollectionView(), label: {
                    VStack{
                        Image(systemName: "folder.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        Text("Collection")
                    }
                })
            Spacer()
            NavigationLink(destination: AccountView(), label: {
                    VStack{
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        Text("Settings")
                    }
                })
        }
    }
    
}

// Struttura realizzata ad hoc per contenere i risultati dell'interrogazione al database
struct UndiscoveredPlace: Identifiable , Hashable {
    
    static func == (lhs: UndiscoveredPlace, rhs: UndiscoveredPlace) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
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
    
    @ObservedObject private var viewModel : MapViewModel
    
    @State private var willMoveToInventory: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var showingSheet : Bool = false
    
    @Binding var annotations: [UndiscoveredPlace]
    
    let context : NSManagedObjectContext
    
    @State var placeDiscovered : UndiscoveredPlace?

    @State private var selectedPlace: UndiscoveredPlace?
    
    @State private var didTap: Bool = false
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    init(annotations:Binding<[UndiscoveredPlace]> , context: NSManagedObjectContext , mapViewModel: MapViewModel){
        self.context = context
        self._annotations = annotations
        viewModel = mapViewModel
        
    }
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region,interactionModes: MapInteractionModes.all, showsUserLocation: true, userTrackingMode: $userTrackingMode,annotationItems: annotations){
            place in MapAnnotation(coordinate: place.location){
                AnnotationView()
                    .shadow(radius: 10)
                    .onTapGesture {
                        selectedPlace = place
                        didTap.toggle()
                    }
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
//                        print("Ho Raccolto un oggetto \(placeDiscovered?.item.name)")
                    }
                    
            }
            .alert(isPresented: $showingSheet) {
                Alert(title: Text("\(placeDiscovered!.item.name  ?? "Unknown item")"), message: Text("Clicca sul tuo inventario per ottenere maggiori informazioni"), dismissButton: Alert.Button.default(Text("Ok")))
                    
            }
        
            
            
    }
}

//SheetView che viene visualizzata all'atto dello sblocco

struct SheetView: View{
    
    let element : CollectableItem?
    
    init(elementoScoperto: CollectableItem){
        self.element = elementoScoperto
    }
    
    var body : some View{
        VStack{
        Text("Hai sbloccato un nuovo item!!!")
//            Image(uiImage: UIImage(data: element.item.previewImage!)!).frame(width: 30, height: 30, alignment: .center)
            Text("\(element!.name ?? "Ogetto senza nome")")
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
    
    // Distance è il raggio in metri per lo sblocco dell'obbiettivo
    func isNearTheItem(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Bool{
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
