//
//  ContentView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import MapKit

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
     
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.70024528747822,
                                       longitude: 14.707543253794043),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
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
        ContentView()
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
