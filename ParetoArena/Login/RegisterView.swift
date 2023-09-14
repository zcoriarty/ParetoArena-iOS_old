//
//  RegisterView.swift
//  ParetoArena
//
//  Created by Zachary Coriarty on 9/13/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CryptoKit
import AuthenticationServices
import PhotosUI
import GoogleSignIn
import GoogleSignInSwift

// MARK: Register View
struct RegisterView: View{
    
    @StateObject var loginModel: LoginViewModel = .init()
    private var firestoreDataSource: FirebaseUserStore = FirebaseUserStore.shared

    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    @State var userGroup: String = ""
    
    
    // Phone number Sign-In
    @State var phoneNumber: String = ""
    @State var phoneNumberPassword: String = ""


    // MARK: View Properties
    @State var showImagePicker: Bool = false
    @State var showEmailSignupFields: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var showLogin: Bool = false
    @State var isLoading: Bool = false
    // MARK: UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View{
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome to the ")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color("Secondary1"))
                    Text("Arena")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundGradient(colors: [Color.white, Color(.lightGray), Color.gray])
                    
                }
                Spacer()
            }
            // MARK: For Smaller Size Optimization
            
            HelperView()
            HStack(spacing: 8) {
                CustomAppleButton()
                CustomGoogleButton()
            }
            .frame(maxWidth: .infinity)
            

            Spacer()
            
            HStack{
                Spacer()
                Text("Already Have an account?")
                    .foregroundColor(.gray)
                
                Button("Login With Email"){
                    showLogin = true
                }
                .fontWeight(.bold)
                .foregroundColor(Color("Secondary1"))
                
                Spacer()
            }
            .font(.callout)

            HStack {
                Spacer()
                Text("By signing up you agree to the")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("EULA")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    .padding(.leading, -4)

                Spacer()
            }

//            Text("Privacy Policy, EULA, and Terms and Conditions")
//                .font(.caption2)
//                .foregroundColor(.gray)
//                .onTapGesture {
//                    if let url = URL(string: "https://patroonllc.com/") {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }

            

        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            // MARK: Extracting UIImage From PhotoItem
            if let newValue{
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                        // MARK: UI Must Be Updated on Main Thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                        
                    }catch{}
                }
            }
        }
//        .onTapGesture { // caused an error with sign in apple button
//            closeKeyboard()
//        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    // Custom Apple Sign in Button
    @ViewBuilder
    func CustomAppleButton() -> some View {
        CustomButton(isGoogle: false)
            .overlay {
                SignInWithAppleButton { (request) in
                    closeKeyboard()
                    isLoading = true
                    loginModel.nonce = randomNonceString()
                    request.requestedScopes = [.email,.fullName]
                    request.nonce = sha256(loginModel.nonce)
                } onCompletion: { (result) in
                    switch result {
                    case .success(let user):
                        print("success")
                        guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                            print("error with firebase")
                            return
                        }
                        loginModel.appleAuthenticate(credential: credential) { authResult in
                            switch authResult {
                            case .newUser:
//                                registerUser(authProvider: .apple, appleCredential: credential)
                                print("new user")
                            case .existingUser:
                                print("User already exists. No need to register again.")
//                                Task {
//                                    do {
//                                        try await fetchUser()
//                                    } catch {
//                                        print("Failed to fetch user: \(error)")
//                                    }
//                                }

                            case .failure(let error):
                                print("Failed to authenticate: \(error)")
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    isLoading = false
                }
                .blendMode(.overlay)
                .frame(height: 55)
        }
        .clipped()
    }

    // Custom Google Sign in Button
    @ViewBuilder
    func CustomGoogleButton() -> some View {
        CustomButton(isGoogle: true)
            .overlay {
                GoogleSignInButton {
                    closeKeyboard()
                    isLoading = true
                    Task {
                        do {
                            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                            let config = GIDConfiguration(clientID: clientID)
                            GIDSignIn.sharedInstance.configuration = config
                            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController())
                            loginModel.logGoogleUser(user: result.user) { authResult in
                                switch authResult {
                                case .newUser:
//                                    registerUser(authProvider: .google, googleUser: result.user)
                                    print("new user")
                                case .existingUser:
                                    print("User already exists. No need to register again.")
                                    Task {
                                        do {
//                                            try await fetchUser()
                                            print("existing user")
                                        } catch {
                                            print("Failed to fetch user: \(error)")
                                        }
                                    }

                                case .failure(let error):
                                    print("Failed to login with Google: \(error)")
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    isLoading = false
                }
                .blendMode(.overlay)

            }
            .clipped()

    }
    
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

    
    @ViewBuilder
    func HelperView()->some View{
        VStack(spacing: 12) {
            ZStack{

                if let userProfilePicData,let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else{
                    Image(systemName: "person.crop.circle.fill.badge.plus")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
                        .font(.system(size: 65))
                }
            }

            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top,25)
                        
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            

            let isInfoComplete = !(emailID.isEmpty || password.isEmpty)

            if isInfoComplete {
                Button(action: {
                    registerUser(authProvider: .email)
                }) {
                    // MARK: Signup Button - Ready
                    Text("Sign up With Email")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color(.lightGray), Color.gray]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                }
                .padding(.top, 10)

            } else {
                Button(action: {
                    // Show a message to the user with the required fields
                    var missingFields = ""
                    if emailID.isEmpty { missingFields += "Email\n" }
                    if password.isEmpty { missingFields += "Password\n" }
                    errorMessage = "Missing:\n" + missingFields
                    showError = true
                }) {
                    // MARK: Signup Button - Not Ready
                    Text("Sign up With Email")
                        .foregroundGradient(colors: [Color.white, Color(.lightGray), Color.gray])
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(LinearGradient(gradient: Gradient(colors: [Color.white, Color(.lightGray), Color.gray]), startPoint: .leading, endPoint: .trailing), lineWidth: 1))
                }
                .padding(.top, 10)
            }
        }
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
    }
    
    enum AuthProvider {
        case email, apple, google
    }

    func registerUser(authProvider: AuthProvider, appleCredential: ASAuthorizationAppleIDCredential? = nil, googleUser: GIDGoogleUser? = nil) {
        isLoading = true
        closeKeyboard()
        
        Task {
            do {
                var userUID: String
                var email: String
                var profileURL: URL?
                var userName: String
                
                switch authProvider {
                case .email:
                    // Step 1: Creating Firebase Account
                    try await Auth.auth().createUser(withEmail: emailID, password: password)
                    userUID = Auth.auth().currentUser?.uid ?? ""
                    email = emailID
                    userName = usernameFromEmail(email: emailID)

                    // Upload the profile picture if you have it
                    if let imageData = userProfilePicData {
                        let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                        let _ = try await storageRef.putDataAsync(imageData)
                        profileURL = try await storageRef.downloadURL()
                    }
                    
                    if profileURL == nil {
                        profileURL = try await uploadDefaultProfileImage()
                    }

                    
                case .apple:
                    guard let appleCredential = appleCredential else { return }
                    userUID = Auth.auth().currentUser?.uid ?? ""
                    email = appleCredential.email ?? ""
                    userName = "\(appleCredential.fullName?.givenName ?? "") \(appleCredential.fullName?.familyName ?? "")"
                    print("userid", userUID)
                    print("email", email)
                    print("userName", userName)

                    // You might have a profile picture URL or use a default one
                    if profileURL == nil {
                        profileURL = try await uploadDefaultProfileImage()
                    }

                    
                case .google:
                    guard let googleUser = googleUser else { return }
                    userUID = Auth.auth().currentUser?.uid ?? ""
                    email = googleUser.profile?.email ?? ""
                    userName = googleUser.profile?.name ?? ""
                    if profileURL == nil {
                        profileURL = try await uploadDefaultProfileImage()
                    }
                    print("idtoken", userUID)
                    print("userUID", userUID)
                    print("email", email)
                    print("userName", userName)
                    print("profileURL", profileURL)

                }
                
//                // Step 4: Creating a User Firestore Object
//                let startingGroup = HabitGroup(id: UUID().uuidString, name: "Personal")
//                let user = User(username: userName, userBio: userBio, userBioLink: "", userUID: userUID, userEmail: email, userProfileURL: profileURL!, deviceToken: "", fcmToken: "", blocked: [], groups: [startingGroup], currentGroup: startingGroup)
//
//                // Step 5: Saving User Doc into Firestore Database
//                let userRef = Firestore.firestore().collection("Users").document(userUID)
//                try userRef.setData(from: user)
//
//                // Step 6: Create group in both the user's sub-collection and the main Groups collection
//                try await createGroupForUser(uid: userUID, group: startingGroup)
//                try await createGroupInMainCollection(group: startingGroup, userID: userUID, userName: userName, profilePic: profileURL!)
//
//                // Save user details locally or in the app's state
//                userNameStored = userName
//                self.userUID = userUID
//                self.profileURL = profileURL
                logStatus = true
                
            } catch {
                print("Registration error: \(error.localizedDescription)")
                
                // MARK: Deleting Created Account In Case of Failure
                do {
                    try await Auth.auth().currentUser?.delete()
                } catch let deletionError {
                    print("Failed to delete user after failed registration: \(deletionError.localizedDescription)")
                }
            }
        }
    }
    
    func uploadDefaultProfileImage() async throws -> URL {
        guard let nullProfileData = UIImage(named: "NullProfile")?.pngData() else {
            throw NSError(domain: "Asset Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "NullProfile asset not found"])
        }
        
        let storageRef = Storage.storage().reference().child("Default_Images").child("NullProfile.png")
        let _ = try await storageRef.putDataAsync(nullProfileData)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL
    }


    
    func usernameFromEmail(email: String) -> String {
        return email.split(separator: "@").first.map(String.init)!
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
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool) -> some View {
        HStack{
            Group{
                if isGoogle{
                    Image("Google")
                        .resizable()
                        .renderingMode(.template)
                }else{
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

