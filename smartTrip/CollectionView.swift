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
    let image: String
    let blackImage: String
    let desc: String
    var isUnlocked: Bool
}

struct CollectionView: View {
    
    let items = [
        Item(title: "Torre Eiffel",image:"pic1", blackImage:"",desc:"La Torre Eiffel é una torre di ferro situata sugli Champ de Mars che prende il nome dal suo ingegnere Gustave Eiffel. Eretta nel 1889 come entrata dell' Esposizione Universale del 1889; é diventata l'icona della Francia e uno dei monumenti più conociuti al mondo. Con più di 7 milioni di visitatori l'anno, é il monumento più visitato al mondo. La Torre Eiffel é iscritta nei monumenti storici dopo il 24 giugno 1964 e iscritta nel patrimonio mondiale dell'UNESCO dopo il 1991.", isUnlocked: true),
        Item(title: "Big Ben",image:"pic2", blackImage:"", desc:"", isUnlocked: true),
        Item(title: "Colosseo",image:"colosseo", blackImage:"", desc:"",isUnlocked: true),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
        Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false),
    ]
    
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3 colonne
        NavigationView {
            VStack{
                HeaderView(item: items[0])
                ScrollView{
                    LazyVGrid(columns: columns){
                        ForEach(items){ item in
                            Button(action:{
                                // Show tapped image in circle
                            }){
                                ItemView(item: item)
                            }
                            .buttonStyle(ItemButtonStyle(cornerRadius: 20))
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
        .background(Color.white)
    }
}

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

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
.previewInterfaceOrientation(.portrait)
    }
}
