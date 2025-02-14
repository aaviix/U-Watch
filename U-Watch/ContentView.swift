//
//  ContentView.swift
//  U-Watch
//
//  Created by Avanish Singh on 14.02.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            
            HealthTrackingView()
                .tabItem {
                    Label("Health", systemImage: "heart.circle")
                }
            
            QuestionnaireView()
                .tabItem {
                    Label("Survey", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
