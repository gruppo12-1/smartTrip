//
//  AccountView.swift
//  smartTrip
//
//  Created by Salvatore Apicella on 12/02/22.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        
        
        NavigationView {
    
            ZStack{
                VStack(alignment: .center){
                    Image("PicProva")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                    
                    Form{
                        Section{
                            VStack{
                                HStack{
                                    Button{} label: {
                                        Label("settings",systemImage: "gear")
                                    }
                                    .padding()
                                    .buttonStyle(.bordered)
                                    
                                    Spacer(minLength: 0)
                                    
                                    Button{} label: {
                                        Label("share",systemImage: "square.and.arrow.up")
                                    }
                                    .padding()
                                    .buttonStyle(.bordered)
                                    
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
                
            }
            .navigationTitle("Account Setting")
            .navigationBarItems(leading: Button(action:{

                
            }) {
                Text("Cancel")
            })
        }
        
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
