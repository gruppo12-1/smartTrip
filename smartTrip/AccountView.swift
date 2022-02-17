//
//  AccountView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI

struct AccountView: View {
    
    
    @State private var toogle1 = false
    @State private var toogle2 = false
    
    var body: some View {
    
            ZStack{
                VStack(alignment: .center){
                    
//                  PARTE 1
//                  IMMAGINE
                    Image("Immagine")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                    
//                  PARTE 2
                    Form{
                        Section{
                            VStack{

//                              IMPOSTAZIONE 1 DA DEFINIRE
                                Toggle("Do something1", isOn: $toogle1)
                                
                                if toogle1 {
                                    
                                }
                                
//                              IMPOSTAZIONE 2 DA DEFINIRE
                                Toggle("Do something2", isOn: $toogle2)
                                
                                if toogle2 {
                                    
                                }
                                
                            }
                        }
                        
                        Section(){
                            Text("Nickname")
                            Text("Oggetti collezionati")
                            Text("OtherInfo")
                            
                        }
                        Section(){
                            Text("Otherthings")
                        }
                    }
                                        
                }
            .navigationTitle("Account Setting")
            .navigationBarItems(trailing: Button(action:{
//                BOTTONE DI CONDIVISIONE (ALTO A DESTRA) DELLA NAVIGATION BAR
//                DA IMPLEMENTARE
            },label: {Label("",systemImage: "square.and.arrow.up")}))
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
