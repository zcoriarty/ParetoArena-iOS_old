//
//  FirebaseAuthStore.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/13/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct AuthErrorModel : Error{
    let message: String
}

class FirebaseUserStore {
    static let shared = FirebaseUserStore()
    private let db = Firestore.firestore()
    
    private init() {}
    
    @AppStorage("user_UID") private var userUID: String = ""
    
    func getUserId() throws -> String {
        guard let userId = Auth.auth().currentUser?.uid  else {
            throw AuthErrorModel(message: "User not signed in.")
        }
        return userId
    }
    
    func getFcmToken() async throws -> String {
        let userId = try self.getUserId()
        let docRef = db.collection("Users").document(userId)
        let document = try await docRef.getDocument()
        
        guard let data = document.data(), let fcmToken = data["fcmToken"] as? String else {
            throw AuthErrorModel(message: "FCM token is missing or data could not be retrieved.")
        }
        
        return fcmToken
    }
}
