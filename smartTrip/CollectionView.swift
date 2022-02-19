//
//  CollectionView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI

struct CollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest<CollectableItem>(entity: CollectableItem.entity(), sortDescriptors: []) var collectableItems: FetchedResults<CollectableItem>
    @State var selectedItem: CollectableItem? = nil

    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3 colonne
            VStack{
                HeaderView(item: selectedItem)
                ScrollView{
                    LazyVGrid(columns: columns){
                        ForEach(collectableItems){ citem in
                            Button(action:{
                                // Show tapped image in circle
                                selectedItem = citem
                            }){
                                ItemView(item: citem)
                            }
                            .buttonStyle(ItemButtonStyle(cornerRadius: 20))
                        }
                    }.padding(.all)
                }
//                .background(Color.white)
                .navigationTitle("My Collection")
                .navigationBarTitleDisplayMode(.inline)
            }
    }
}

struct ItemButtonStyle: ButtonStyle{
    let cornerRadius: CGFloat
    func makeBody(configuration: Configuration) -> some View{
        ZStack{
            configuration.label
            if configuration.isPressed {
                Color.black.opacity(0.2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black, radius: 2)
    }
}

struct HeaderView: View{
    @State var showingDetailsView = false
    @State var showingARView = false
    
    var item: CollectableItem?
    let isSelectedItemNull: Bool
    
    init(item: CollectableItem?){
        self.item = item
        self.isSelectedItemNull = (item == nil)
    }
    var body: some View{
        VStack{
            if !isSelectedItemNull {
                Image(uiImage: UIImage(data: item!.previewImage!)!)
                .resizable()
                .frame(width: 170, height: 170)
                .clipShape(Circle())
                .overlay(Circle().stroke())
            } else {
                Image("")
                .resizable()
                .frame(width: 170, height: 170)
                .clipShape(Circle())
                .overlay(Circle().stroke())
            }
            HStack(spacing: 200){
                VStack(spacing:2){
                    Button(action: {
                            // Do something with AR Kit
                        self.showingARView = true
                        }, label: {
                            Image(systemName: "arkit")
                                .resizable()
                                .frame(width: 60, height: 70)
                        }).fullScreenCover(isPresented: $showingARView, content:{
                            ARTestView()
                        })//.disabled(isSelectedItemNull)
                    Text("AR")
                }
                VStack(spacing:2){
                Button(action: {
                        // Show Info
                    self.showingDetailsView = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }).sheet(isPresented: $showingDetailsView, content:{
                        DetailsView(item: item!)
                    })//.disabled(isSelectedItemNull)
                    Text("Info")
                }
            }
        }
        .frame(height:280)
        .frame(maxWidth: .infinity)
//        .background(Color.white)
    }
}
/* OLD
struct HeaderView: View{
    @State var showingDetailsView = false
    @State var showingARView = false
    
    var item : Item
    init(item: Item){
        self.item = item
    }
    var body: some View{
        VStack{
                Image(item.image)
                .resizable()
                .frame(width: 170, height: 170)
                .clipShape(Circle())
                .overlay(Circle().stroke())
                
            HStack(spacing: 200){
                VStack(spacing:2){
                    Button(action: {
                            // Do something with AR Kit
                        self.showingARView = true
                        }, label: {
                            Image(systemName: "arkit")
                                .resizable()
                                .frame(width: 60, height: 70)
                        }).fullScreenCover(isPresented: $showingARView, content:{
                            ARTestView()
                        })
                    Text("AR")
                }
                VStack(spacing:2){
                Button(action: {
                        // Show Info
                    self.showingDetailsView = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }).sheet(isPresented: $showingDetailsView, content:{
                        DetailsView(item: item)
                    })
                    Text("Info")
                }
            }
        }
        .frame(height:280)
        .frame(maxWidth: .infinity)
//        .background(Color.white)
    }
}*/
struct ItemView: View {
    let item: CollectableItem
    let collected: Bool
    
    init(item: CollectableItem){
        self.item = item
       collected = (item.collectedItem != nil)
    }
    
    var body: some View{
        GeometryReader{ reader in
            VStack(spacing: 5){
                if collected {
                    Image(uiImage: UIImage(data: item.previewImage!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width:85)
                    Text(item.name!)
                    .foregroundColor(Color.black.opacity(0.9))
                }else{
                    Image("")
                        .resizable()
                        .scaledToFit()
                        .frame(width:85)
                    Text("?")
                        .foregroundColor(Color.black.opacity(0.9))
                }
            }
            .frame(width:reader.size.width, height: reader.size.height)
            .background(Color.white)
        }
        .frame(height: 125)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black, radius: 2)
    }
}
/* OLD
struct ItemView: View {
    let item: Item
    var body: some View{
        GeometryReader{ reader in
            VStack(spacing: 5){
                if(item.isUnlocked){
                Image(item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width:85)
                Text(item.title)
                    .foregroundColor(Color.black.opacity(0.9))
                }else{
                    Image(item.blackImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width:85)
                    Text("?")
                        .foregroundColor(Color.black.opacity(0.9))
                }
            }
            .frame(width:reader.size.width, height: reader.size.height)
            .background(Color.white)
        }
        .frame(height: 125)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black, radius: 2)
    }
}
*/
struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView().environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}
