//
//  DetailsView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import CoreData
import SceneKit

struct DetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var item : CollectableItem
    let unlocked: Bool
    
    init(item: CollectableItem){
        self.item = item
        unlocked = item.collectedItem != nil
    }
    
    var body: some View {
            GeometryReader { geo in
                let screenHeight = geo.frame(in: .global).height
                let screenWidth = geo.frame(in: .global).width
                ZStack {
                    
                    if screenHeight > screenWidth {
                        VStack(alignment: .center, content: {
                            if(unlocked){
                                
                                Group{
                                    if let p3Ddata=item.p3Ddata {
                                        try! SceneView(scene: SCNScene(url: p3Ddata), options: [.autoenablesDefaultLighting,.allowsCameraControl])
                                    } else {
                                        Image(uiImage: UIImage(data: item.previewImage!)!)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                .frame(height: 250, alignment: .center)
                                .padding()
                            }else{
                                
                            }
                            VStack(alignment: .leading){
                                
                                if(unlocked){
                                    Text("Nome")
                                        .font(.headline)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.medium)
                                    Text(item.name!)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("Descrizione")
                                        .font(.headline)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.medium)
                                        .padding(.top)
                                    ScrollView{
                                        Text(item.desc!)
                                            .font(.body)
                                    }
                                    .padding(.top, -10.0)
                                    
                                }else{
                                    Text("Non hai ancora sbloccato questo contenuto.\n\nTorna sulla mappa e cerca l'obiettivo più vicino a te! 💪")
                                        .font(.title2)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.semibold)
                                        .padding(.top)
                                }
                            }
                            .padding(.horizontal, 20.0)
                        })
                            
                            
                    } else {
                        
                        
                        HStack(alignment: .center, content: {
                            
                            if(unlocked){
                                
                                
                                Group{
                                    if let p3Ddata=item.p3Ddata {
                                        try! SceneView(scene: SCNScene(url: p3Ddata), options: [.autoenablesDefaultLighting,.allowsCameraControl])
                                    } else {
                                        Image(uiImage: UIImage(data: item.previewImage!)!)
                                            .resizable()
                                            .scaledToFit()
                                        
                                        
                                    }
                                }
                                .frame(height: 250, alignment: .center)
                                .padding()
                                
                                
                                
                            }else{
                                
                            }
                            
                            VStack(alignment: .leading){
                                
                                if(unlocked){
                                    Text("Nome")
                                        .font(.headline)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.medium)
                                    Text(item.name!)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("Descrizione")
                                        .font(.headline)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.medium)
                                        .padding(.top)
                                    ScrollView{
                                        Text(item.desc!)
                                            .font(.body)
                                    }
                                    .padding(.top, -10.0)
                                    
                                }else{
                                    
                                    Text("Non hai ancora sbloccato questo contenuto.\n\nTorna sulla mappa e cerca l'obiettivo più vicino a te! 💪")
                                        .font(.title2)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.semibold)
                                        .padding(.top)
                                }
                            }
                            .padding(.horizontal, 20.0)
                        })
                        
                            
                        
                    }
                }
            }
            .navigationTitle("Info")
        .navigationViewStyle(.stack)
    }
}




struct DetailsView_Previews: PreviewProvider {
    static var item = { () -> CollectableItem in
        let context = PersistanceController.preview.container.viewContext
        let req = NSFetchRequest<CollectableItem>(entityName: "CollectableItem") //nota
        req.predicate = NSPredicate(format:"name LIKE %@","Torre Eiffel")
        let res = try! context.fetch(req)
        return res.first!
    }()
    
    static var previews: some View {
        
        DetailsView(item: item)
            .previewInterfaceOrientation(.portrait)
    }
}
