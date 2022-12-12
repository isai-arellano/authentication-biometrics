//
//  Authentication.swift
//  AuthenticationApp
//
//  Created by Isai Arellano on 10/12/22.
//

import Foundation
import LocalAuthentication

class Authentication: ObservableObject {
    
    enum BiometrycType {
        case none
        case face
        case touch
    }
    
    enum AuthenticationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
        case deniedAccess
        case noFaceIdEnrolled
        case noFingerprintEnrolled
        case biometricError
        case credentialsNotSaved
        
        var id: String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Usuario o contraseña incorrectos. Inténtalo de nuevo.", comment: "")
            case .deniedAccess:
                return NSLocalizedString("Acceso denegado. Vaya a la aplicación de configuración, localice esta aplicación y active Face ID.", comment: "")
            case .noFaceIdEnrolled:
                return NSLocalizedString("Aún no has registrado ningún Face ID.", comment: "")
            case .noFingerprintEnrolled:
                return NSLocalizedString("Aún no has registrado ninguna huella digital.", comment: "")
            case .biometricError:
                return NSLocalizedString("No se reconoció su rostro o su huella digital.", comment: "")
            case .credentialsNotSaved:
                return NSLocalizedString("Sus credenciales no han sido guardadas.", comment: "")
            }
        }
    }
    
    func biometricType() -> BiometrycType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        switch authContext.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        @unknown default:
            return .none
        }
    }
    
    func hasCredentials() -> Bool {
        return KeychainStorage.getCredentials() != nil
    }
    
    func removeCredentials() -> Bool {
        return KeychainStorage.removeCredentials()
    }
    
    func requestBiometricUnlock(completion: @escaping(Result<Credentials, AuthenticationError>) -> Void ){
        let credentials = KeychainStorage.getCredentials()
        guard let credentials = credentials else {
            completion(.failure(.credentialsNotSaved))
            return
        }
        let context = LAContext()
        var error: NSError?
        var canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            switch error.code {
                case -6:
                completion(.failure(.deniedAccess))
            case 7:
                if context.biometryType == .faceID {
                    completion(.failure(.noFaceIdEnrolled))
                }
                else {
                    completion(.failure(.noFingerprintEnrolled))
                }
            default:
                completion(.failure(.biometricError))
            }
            return
        }
        
        if canEvaluate {
            if context.biometryType != .none {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Es necesario acceder a las credenciales.") { success, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(.biometricError))
                        }
                        else {
                            completion(.success(credentials))
                        }
                    }
                }
            }
        }
    }
    
    func requestBiometricSave(email: String, password: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void ){
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            switch error.code {
            case -6:
                completion(.failure(.deniedAccess))
            case -7:
                if context.biometryType == .faceID {
                    completion(.failure(.noFaceIdEnrolled))
                }
                else {
                    completion(.failure(.noFingerprintEnrolled))
                }
            default:
                completion(.failure(.biometricError ))
            }
            return
        }
        
        if canEvaluate {
            if context.biometryType != .none {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Es necesario acceder a las credenciales."){ success, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(.biometricError))
                        }
                        else{
                            let credentials = Credentials(email: email, password: password)
                            if KeychainStorage.savedCredentials(credentials){
                                completion(.success(true))
                            }
                            else {
                                completion(.success(false))
                            }
                        }
                    }
                }
            }
        }
    }
}
