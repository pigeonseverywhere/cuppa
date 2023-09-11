//
//  SettingsView.swift
//  Cuppa
//
//  Created by Yunshu D on 11/9/2023.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        TabView {
            GeneralSettingsView()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                AppearanceSettingsView()
                    .tabItem {
                        Label("Appearance", systemImage: "paintpalette")
                    }
        }.frame(width: 450, height: 250)
        
    }

}

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    // TODO: add actual launch at login functionality
    var body: some View {
        Toggle("Launch at login: ", isOn: $launchAtLogin)
            .toggleStyle(.switch)
    }
}
 
 
struct AppearanceSettingsView: View {
    var body: some View {
        Text("Appearance Settings")
            .font(.title)
    }
}
 
 

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

