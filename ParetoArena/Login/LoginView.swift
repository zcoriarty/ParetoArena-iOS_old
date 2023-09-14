//
//  LoginView.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/13/23.
//

import SwiftUI

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    // MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: User Defaults
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        VStack(spacing: 10){
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Lets build some ")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color("Secondary1"))
                    Text("habits")
                        .font(.largeTitle.bold())
                        .foregroundGradient(colors: [Color.red, Color.orange, Color.yellow])
                }
                Spacer()
            }


            VStack(spacing: 12){
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top,25)
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(Color("Secondary1"))
                    .hAlign(.trailing)
                
                Button(action: loginUser){
                    // MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(Color("Primary1"))
                        .hAlign(.center)
                        .fillView(Color("Secondary1"))
                }
                .padding(.top,10)
            }
            
            // MARK: Register Button
            HStack{
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now"){
                    dismiss()
                }
                .buttonStyle(GradientButtonStyle(colors: [Color.red, Color.orange, Color.yellow]))
                .fontWeight(.bold)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser(){
        isLoading = true
        closeKeyboard()
        Task {
            do {
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
//                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: If User if Found then Fetching User Data From Firestore
//    func fetchUser() async throws{
//        guard let userID = Auth.auth().currentUser?.uid else{return}
//        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
//        // MARK: UI Updating Must be Run On Main Thread
//        await MainActor.run(body: {
//            // Setting UserDefaults data and Changing App's Auth Status
//            userUID = userID
//            userNameStored = user.username
//            profileURL = user.userProfileURL
//            logStatus = true
//        })
//    }
// PICK UP FROM HERE
// requestAccessToGroup not being called?
// task list duplication and not getting upcoming, and not moving completed tasks to completed
    
    func resetPassword(){
        Task{
            do{
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error)async{
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

