//
//  LoginViewModel.swift
//  AuthenticationApp
//
//  Created by Isai Arellano on 12/12/22.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showNextView: Bool = false
    @Published var credentialsSaved : Bool = false
    @Published var message : String = ""
    @Published var authentication = Authentication()
    @Published var credentials = Credentials()
    
    
    
    func loginFake(){
        if email == "Isai.arellano@mail.com" && password == "P@ssword123"{
            self.authentication.requestBiometricSave(email: self.email, password: self.password, completion: {(result:Result<Bool, Authentication.AuthenticationError>) in
                switch result {
                case .success(let band):
                    if band {
                        self.message = "Credenciales guardadas con éxito."
                        print(self.message)
                        self.showNextView = true
                    }
                    else {
                        self.message     = "Imposible guardar las credenciales."
                        print("Error: \(self.message)")
                    }
                case .failure(let error):
                    self.message = error.localizedDescription
                    print("Error: \(error)")
                }
            })
        }else {
                self.showNextView = false
        }
    }
    
    
    
    
}
