//
//  NewEditProfileVC.swift
//  Pareto
//
//  Created by Zachary Coriarty on 5/1/23.
//

import SwiftUI
import UIKit
import Combine

struct EditProfileView: View {
    @State private var facebookURL: String = ""
    @State private var userName: String = ""
    @State private var instagramURL: String = ""
    @State private var twitterURL: String = ""
    @State private var bio: String = ""
    @State private var publicPortfolio: Bool = false
    @State private var profilePhoto: UIImage? = nil
    @State private var profileImageURL: String = ""
    @State private var showAlert: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImagePicker: Bool = false
    @StateObject var editProfileViewModel = EditProfileViewModel()
//    @State var model = ToggleModel()
    
    
    var body: some View {
        NavigationView {
            VStack {

                TextField("User Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true)
                
                TextField("Bio", text: $bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Facebook URL", text: $facebookURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Twitter URL", text: $twitterURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Instagram URL", text: $instagramURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
//                Toggle(isOn: $model.isDark) {
//                    Text("Dark Mode")
//                }
//                .padding()
                
                Button(action: {
                    editProfileViewModel.updateProfile(username: userName, bio: bio, fab: facebookURL, insta: instagramURL, twitter: twitterURL, publicPortfolio: "false")
                }) {
                    Text("Update")
                        .foregroundColor(Color(.label))
                }
                                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Edit Profile", displayMode: .inline)
        }
        .onAppear {
            // Fetch user data and set the initial state values
            // You can replace this with actual data fetched from the backend
            userName = USER.shared.details?.user?.fullName ?? ""
            bio = USER.shared.details?.user?.bio ?? ""
            facebookURL = USER.shared.details?.user?.facebookUrl ?? ""
            twitterURL = USER.shared.details?.user?.twitterUrl ?? ""
            instagramURL = USER.shared.details?.user?.instagramUrl ?? ""
            publicPortfolio = false
        }
        .onReceive(editProfileViewModel.$updateProfileSuccess, perform: { success in
            if success {
                print("Profile Updated")
            }
        })
        .onReceive(editProfileViewModel.$updateProfileError, perform: { error in
            if let error = error {
                print("Error: \(error)")
            }
        })
    }
}

class EditProfileViewModel: BaseViewModel {
    @Published var updateProfileSuccess: Bool = false
    @Published var updateProfileError: Error? = nil

    override init() {
        super.init()
        proxy = NetworkProxy()
        proxy.delegate = self
    }

    func updateProfile(username: String? = "", bio: String? = "", fab: String? = "", insta: String? = "", twitter: String? = "", publicPortfolio: String? = "") {
        proxy.requestForUpdateProfile(param: ["username": username!, "bio": bio!, "instagram_url": insta!, "twitter_url": twitter!, "facebook_url": fab!, "public_portfolio": publicPortfolio!])
    }
    
    // MARK: - Delegate
    override func requestDidBegin() {
        super.requestDidBegin()
    }

    override func requestDidFinishedWithData(data: Any, reqType: RequestType) {
        super.requestDidFinishedWithData(data: data, reqType: reqType)
        DispatchQueue.main.async {
            self.updateProfileSuccess = true
        }
    }
    
    override func requestDidFailedWithError(error: String, reqType: RequestType) {
        super.requestDidFailedWithError(error: error, reqType: reqType)
        DispatchQueue.main.async {
            self.updateProfileError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error])
        }
    }
}




struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView().environmentObject(EditProfileViewModel())
    }
}


