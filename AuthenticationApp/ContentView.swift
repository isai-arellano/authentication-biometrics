//
//  ContentView.swift
//  AuthenticationApp
//
//  Created by Isai Arellano on 10/12/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
            Text("Iniciar sesión")
                .font(.title)
            
            if self.viewModel.credentialsSaved == true {
                Button {
                    viewModel.authentication.requestBiometricUnlock {(result: Result<Credentials, Authentication.AuthenticationError>) in
                        switch result {
                        case .success(let credentials):
                            viewModel.credentials = credentials
                            self.viewModel.showNextView = true
                            
                        case .failure(let error):
                            print(error)
                            self.viewModel.message = error.errorDescription ?? "Error desconocido"
                        }
                    }
                }label: {
                    Image(systemName: viewModel.authentication.biometricType() == .face ? "faceid" : "touchid")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20,height: 20)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .cornerRadius(15)
                        .padding()
                }
            }
            else {
                TextField("Correo", text: $viewModel.email)
                    .padding()
                    .font(.headline)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                SecureField("Contraseña", text: $viewModel.password)
                    .padding()
                    .font(.headline)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                Button("Ingresar"){
                    viewModel.loginFake()
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(Color.white)
                .cornerRadius(15)
                .padding()
            }
        }
        .onAppear{
            self.viewModel.credentialsSaved = viewModel.authentication.hasCredentials()
        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.showNextView, content: {
            HomeView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
