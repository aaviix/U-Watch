//
//  UserProfileView.swift
//  U-Watch
//
//  Created by Avanish Singh on 14.02.25.
//

import SwiftUI

struct UserProfileView: View {
    // Use @AppStorage to persist user data in UserDefaults.
    @AppStorage("name") private var name: String = ""
    @AppStorage("sex") private var sex: String = "Not Specified"
    @AppStorage("age") private var age: String = ""
    @AppStorage("height") private var height: String = ""
    @AppStorage("weight") private var weight: String = ""
    @AppStorage("medications") private var medications: String = ""
    
    // A simple list of options for the "Sex" field.
    let sexes = ["Male", "Female", "Other", "Not Specified"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Name", text: $name)
                    
                    Picker("Sex", selection: $sex) {
                        ForEach(sexes, id: \.self) { option in
                            Text(option)
                        }
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Physical Stats")) {
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Medications")) {
                    TextField("Medications", text: $medications)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
