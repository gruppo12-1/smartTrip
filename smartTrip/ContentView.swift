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
    @State var showSheet: Bool = false
    
    var drag: some Gesture{
        
        DragGesture()
        .onEnded{ _ in
            showSheet.toggle()
        }
        .onChanged{_ in
            
            showSheet.toggle()
            
        }
            
        
        
    }
    
    
    var body: some View {
        VStack{
            MapView()
            Divider()
            BottomBar().gesture(drag).halfSheet(showSheet: $showSheet){
                Text("Prova").ignoresSafeArea()
            } onEnd:{
            print("Dismissed")
            }.onTapGesture {
                print("Tappato")
            }
        }
    }
}

struct BottomBar: View{
   
    @State var showSheet: Bool = false
    
    var body: some View{
        HStack{
            Button("Bottone 1"){
               print("You Clicked me")
            }
            
            Spacer()
           
            Button("Bottone 1"){
               print("You Clicked me")
            }
           
        }.padding()
        
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

// Estensione di view per avere la modalità
extension View{
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping()->SheetView, onEnd: @escaping ()->())->some View{
        return self.background{
            HalfSheetHelper(sheetView: sheetView(),showSheet: showSheet, onEnd: onEnd)
        }
    }
    
}

struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable{
    
    var sheetView: SheetView
    @Binding var showSheet: Bool
    var onEnd: ()->()
    
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if showSheet{
            let sheetController = CustomHostingController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        }
        else{
                uiViewController.dismiss(animated: true)
            }
        
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate{
        
        var parent: HalfSheetHelper
        init(parent: HalfSheetHelper){
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
    }
}

class CustomHostingController<Content: View>: UIHostingController<Content>{
    
    override func viewDidLoad() {
        
//        view.backgroundColor = .clear
        
        if let presentationController = presentationController as? UISheetPresentationController{
            presentationController.detents = [
                .medium(),
                .large()
            ]
            
//
            presentationController.prefersGrabberVisible = true
        }
    }
}
