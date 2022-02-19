//
//  DetailsView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI
import CoreData



struct DetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var item : CollectableItem
    let unlocked: Bool
    
    init(item: CollectableItem){
        self.item = item
        unlocked = item.collectedItem != nil
    }
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geo in
                let hz = geo.frame(in: .global).height
                let vt = geo.frame(in: .global).width
                ZStack {
                    
                    if hz > vt {
                        
                        
                        VStack(alignment: .center, content: {
                            
                            if(unlocked){
                                Image(uiImage: UIImage(data: item.previewImage!)!)
                                    .resizable()
                                    .frame(width: 170, height: 170, alignment: .center)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke())
                                    .padding()
                            }else{
                                Image("")
                                    .resizable()
                                    .frame(width: 170, height: 170, alignment: .center)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke())
                                    .padding()
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
                                    Text("?")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                    Text("Non hai ancora sbloccato questo contenuto.")
                                        .font(.title2)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.horizontal, 20.0)
                        })
                            
                            
                    } else {
                        
                        
                        HStack(alignment: .center, content: {
                            if(unlocked){
                                Image(uiImage: UIImage(data: item.previewImage!)!)
                                    .resizable()
                                    .frame(width: 170, height: 170, alignment: .center)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke())
                                    .padding()
                            }else{
                                Image("")
                                    .resizable()
                                    .frame(width: 170, height: 170, alignment: .center)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke())
                                    .padding()
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
                                    Text("?")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                    Text("Non hai ancora sbloccato questo contenuto.")
                                        .font(.title2)
                                        .foregroundColor(Color.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.horizontal, 20.0)
                            
                        })
                    }
                }
            }
            
            
            .navigationTitle("Info")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    
    
}




struct DetailsView_Previews: PreviewProvider {
    static var item = { () -> CollectableItem in
        let context = PersistanceController.preview.container.viewContext
        let req = NSFetchRequest<CollectableItem>(entityName: "CollectableItem")
        req.predicate = NSPredicate(format:"name LIKE %@","Torre Eiffel")
        let res = try! context.fetch(req)
        return res.first!
    }()
    
    static var previews: some View {
        
        DetailsView(item: item)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
