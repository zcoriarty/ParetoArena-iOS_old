//
//  LoginViewModel.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/13/23.
//

import SwiftUI
import Firebase
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: ObservableObject {
    // MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    // MARK: Apple Sign in Properties
    @Published var nonce: String = ""
    
    
    
    // MARK: Handling Error
    func handleError(error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    // MARK: Apple Sign in API
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential, completion: @escaping (AuthResult) -> ()) {
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else {
            print("error with Token")
            completion(.failure(NSError(domain: "", code: -1, userInfo: ["description": "Token is nil"])))
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            if let error = err {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            if let isNewUser = result?.additionalUserInfo?.isNewUser {
                completion(isNewUser ? .newUser : .existingUser)
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: ["description": "Additional user info is nil"])))
            }
        }
    }

    // MARK: Logging Google User into Firebase
    func logGoogleUser(user: GIDGoogleUser, completion: @escaping (AuthResult) -> Void) {
        Task {
            do {
                guard let idToken = user.idToken else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: ["description": "ID token is nil"])))
                    return
                }
                let accessToken = user.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                let authResult = try await Auth.auth().signIn(with: credential)
                
                if let isNewUser = authResult.additionalUserInfo?.isNewUser {
                    completion(isNewUser ? .newUser : .existingUser)
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: ["description": "Additional user info is nil"])))
                }
                
                print("Success Google!")
            } catch {
                completion(.failure(error))
            }
        }
    }
}
enum AuthResult {
    case newUser
    case existingUser
    case failure(Error)
}



// MARK: Extensions
extension UIApplication{
    func closeKeyboard(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Root Controller
    func rootController()->UIViewController{
        guard let window = connectedScenes.first as? UIWindowScene else{return .init()}
        guard let viewcontroller = window.windows.last?.rootViewController else{return .init()}
        
        return viewcontroller
    }
}

// MARK: Apple Sign in Helpers
func sha256(_ input: String) -> String {
 let inputData = Data(input.utf8)
 let hashedData = SHA256.hash(data: inputData)
 let hashString = hashedData.compactMap {
   return String(format: "%02x", $0)
 }.joined()

 return hashString
}

func randomNonceString(length: Int = 32) -> String {
 precondition(length > 0)
 let charset: Array<Character> =
     Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
 var result = ""
 var remainingLength = length

 while remainingLength > 0 {
   let randoms: [UInt8] = (0 ..< 16).map { _ in
     var random: UInt8 = 0
     let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
     if errorCode != errSecSuccess {
       fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
     }
     return random
   }

   randoms.forEach { random in
     if remainingLength == 0 {
       return
     }

     if random < charset.count {
       result.append(charset[Int(random)])
       remainingLength -= 1
     }
   }
 }

 return result
}
