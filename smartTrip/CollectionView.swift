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
    
    @State var item : Item
    
    let items = [
        Item(title: "Torre Eiffel",image:"pic1", blackImage:"",desc:" La Torre Eiffel é una torre di ferro situata sugli Champ de Mars che prende il nome dal suo ingegnere Gustave Eiffel. Eretta nel 1889 come entrata dell' Esposizione Universale del 1889; é diventata l'icona della Francia e uno dei monumenti più conociuti al mondo. Con più di 7 milioni di visitatori l'anno, é il monumento più visitato al mondo. La Torre Eiffel é iscritta nei monumenti storici dopo il 24 giugno 1964 e iscritta nel patrimonio mondiale dell'UNESCO dopo il 1991.", isUnlocked: true),
        Item(title: "Big Ben",image:"pic2", blackImage:"", desc:"L'edificio delle Houses of Parliament e la Elisabeth Tower, comunemente denominata Big Ben, sono tra i monumenti più rappresentativi di Londra. Tecnicamente, Big Ben è il nome assegnato alla massiccia campana, del peso di oltre 13 tonnellate (13.760 kg), che si trova all'interno della torre dell'orologio. La torre dell'orologio offre uno spettacolo straordinario di notte quando i quattro quadranti sono illuminati.", isUnlocked: true),
        Item(title: "Colosseo",image:"colosseo", blackImage:"", desc:"L’Anfiteatro Flavio, più comunemente noto con il nome di Colosseo, si innalza nel cuore archeologico della città di Roma e accoglie quotidianamente un gran numero di visitatori attratti dal fascino della sua storia e della sua complessa architettura. L’edificio, detto Colosseo per via di una colossale statua che sorgeva nelle vicinanze, venne edificato nel I secolo d.C. per volere degli imperatori della dinastia flavia, ed ha accolto, fino alla fine dell’età antica, spettacoli di grande richiamo popolare, quali le cacce e i giochi gladiatori. L’edificio era, e rimane ancora oggi, uno spettacolo in se stesso. Si tratta infatti del più grande anfiteatro del mondo, in grado di offrire sorprendenti apparati scenografici, nonché servizi per gli spettatori.",isUnlocked: true),
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
            VStack{
                HeaderView(item: item)
                ScrollView{
                    LazyVGrid(columns: columns){
                        ForEach(items){ citem in
                            Button(action:{
                                // Show tapped image in circle
                                item = citem
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
//        .background(Color.white)
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
        CollectionView(item: Item(title: "lock",image:"", blackImage:"", desc:"", isUnlocked: false))
            .previewInterfaceOrientation(.portrait)
    }
}
