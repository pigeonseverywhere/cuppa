//
//  ContentView.swift
//  Cuppa
//
//  Created by Yunshu D on 8/11/2022.
//

import SwiftUI
struct ContentView : View {
    var body: some View {
        VStack {
            Text("Welcome to Cuppa!").font(.title).padding(.all)
            HStack {
                Text("Version v1.0.0").padding(.vertical)
                Spacer()
                    .frame(maxWidth: 40)
                Text("subversion")
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
