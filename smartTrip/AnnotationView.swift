//
//  AnnotationView.swift
//  smartTrip
//
//  Created by Grazia Ferrara on 22/02/22.
//

import SwiftUI

struct AnnotationView: View {
    
    
    var body: some View {
        
        VStack(spacing:0){
            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .background(Color.blue)
                .cornerRadius(36)
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.blue)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
                .padding(.bottom,40)
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            AnnotationView()
        }
    }
}
    
    
}
