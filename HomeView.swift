//
//  HomeView.swift
//  AuthenticationApp
//
//  Created by Isai Arellano on 12/12/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack{
            Text("HOME VIEW")
            Button("Cerrar sesión"){
                viewModel.authentication.removeCredentials()
                self.viewModel.showNextView = true
            }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(Color.white)
                .cornerRadius(15)
                .padding()
        }
        .fullScreenCover(isPresented: $viewModel.showNextView, content: {
            ContentView()
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
