//
//  CollectionView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI

struct Item: Identifiable{
    let id = UUID()
    let title: String
    var isUnlocked: Bool
}

struct CollectionView: View {
    
    let items = [
        Item(title: "Duomo di Milano",isUnlocked: true),
        Item(title: "Torre di Pisa",isUnlocked: true),
        Item(title: "Mole Antonelliana", isUnlocked: true),
        Item(title: "Unisa", isUnlocked: true),
        Item(title: "Colosseo",isUnlocked: true),
        Item(title: "Santa Maria del Fiore",isUnlocked: true),
        Item(title: "Paestum",isUnlocked: true),
        Item(title: "Pompei",isUnlocked: true),
        Item(title: "Saline",isUnlocked: true),
        Item(title: "Cantoni di Palermo",isUnlocked: true),
        Item(title: "Pantheon",isUnlocked: true),
        Item(title: "Paestum",isUnlocked: true),
        Item(title: "Pompei",isUnlocked: true),
        Item(title: "Saline",isUnlocked: true),
        Item(title: "Cantoni di Palermo",isUnlocked: true),
        Item(title: "Pantheon",isUnlocked: false)
    ]
    
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3 colonne
        NavigationView {
            VStack{
                headerView()
                ScrollView{
                    LazyVGrid(columns: columns){
                        ForEach(items){ item in
                            if(item.isUnlocked){
                                // sbloccato e clickabile
                                Button(action:{}){
                                    ItemView(item: item)
                                }
                                .buttonStyle(ItemButtonStyle(cornerRadius: 20))
                            }else{
                                // è solo visibile, ma non è clickabile in quanto non sbloccato
                                ItemView(item: item)
                            }
                        }
                    }.padding(.all)
                }
                .background(Color.white)
                .navigationTitle("My Collection")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ItemButtonStyle: ButtonStyle{
    let cornerRadius: CGFloat
    func makeBody(configuration: Configuration) -> some View{
        ZStack{
            configuration.label
            if configuration.isPressed{
                Color.black.opacity(0.2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black, radius: 2)
    }
}

struct headerView: View{
    var body: some View{
        VStack{
            Image("immagine")
                .resizable()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke())
            HStack(spacing: 185){
                Image(systemName: "arkit")
                    .resizable()
                    .frame(width: 60, height: 70)
                
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
        }
        .frame(height:280)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct ItemView: View {
    let item: Item
    var body: some View{
        GeometryReader{ reader in
            VStack(spacing: 5){
                // inserire qui le cose da mostrare nei quadrati
//                Image(item.image)
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(item.imgColor)
//                    .frame(width: 50)
             Text(item.title).font(.system(size: 20, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
            }
            .frame(width:reader.size.width, height: reader.size.height)
            .background(Color.white)
        }
        .frame(height: 125)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black, radius: 2)
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
    }
}
