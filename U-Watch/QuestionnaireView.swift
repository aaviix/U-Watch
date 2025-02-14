//
//  QuestionnaireView.swift
//  U-Watch
//
//  Created by Avanish Singh on 14.02.25.
//

import SwiftUI

struct QuestionnaireView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Questionnaire Page")
                    .font(.title)
                Text("Display questions and record answers here...")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Survey")
        }
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
    }
}
