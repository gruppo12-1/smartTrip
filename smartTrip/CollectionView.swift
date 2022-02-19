//
//  CollectoinView.swift
//  smartTrip
//
//  Created by Grazia Ferrara on 19/02/22.
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
                .navigationTitle("My Collection")
                .navigationBarTitleDisplayMode(.inline)
            }
    }
}

struct ItemButtonStyle: ButtonStyle{
    @Environment(\.colorScheme) var colorScheme
    let cornerRadius: CGFloat
    func makeBody(configuration: Configuration) -> some View{
        ZStack{
            configuration.label
            if configuration.isPressed && colorScheme == .dark{
                Color.white.opacity(0.2)
            }else if configuration.isPressed{
                Color.black.opacity(0.2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: colorScheme == .dark ? Color.white : Color.black, radius: 2)
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
                        }).disabled(isSelectedItemNull)
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
                    }).disabled(isSelectedItemNull)
                    Text("Info")
                }
            }
        }
        .frame(height:280)
        .frame(maxWidth: .infinity)
    }
}

struct ItemView: View {
@Environment(\.colorScheme) var colorScheme
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
             .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
         }else{
             Image("")
                 .resizable()
                 .scaledToFit()
                 .frame(width:85)
             Text("?")
                 .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
         }
     }
     .frame(width:reader.size.width, height: reader.size.height)
     .background(colorScheme == .dark ? Color.black : Color.white)
 }
 .frame(height: 125)
 .clipShape(RoundedRectangle(cornerRadius: 30))
 .shadow(color: Color(UIColor.systemBackground), radius: 2)
}
}

struct CollectionView_Previews: PreviewProvider {
static var previews: some View {
    CollectionView()
        .environment(\.managedObjectContext, PersistanceController.preview.container.viewContext)
        .previewInterfaceOrientation(.portrait)
    }
}
