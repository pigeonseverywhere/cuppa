//
//  SettingsView.swift
//  Cuppa
//
//  Created by Yunshu D on 11/9/2023.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    var activateCaffeinate: (TimeInterval, Bool) -> Void
    
//    @State private var tabSelection = 1
    @Binding var tabSelection: Int
    
    var body: some View {
        TabView (selection: $tabSelection){
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }.tag(1)
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }.tag(2)
            CustomDurationSettingsView(activateCaffeinate: activateCaffeinate)
                .tabItem {
                    Label("Custom Duration", systemImage:  "command.square.fill")
                }.tag(3)
        }.frame(width: 400, height: 180)
        
    }

}

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launch = false
    @AppStorage("notifyOnTerminate") private var notify = false
    


    let numberFormatter: NumberFormatter = {
        let num = NumberFormatter()
        num.maximumFractionDigits = 0
        return num
    }()
    
    func requestNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound ]) { (authorised, error) in
            if authorised {
                print("auth")
            } else if !authorised {
                print("not auth ")
            } else {
                print(error?.localizedDescription as Any)
            }
        }

    }
    
    // TODO: add actual launch at login functionality
    var body: some View {
        HStack {
            VStack (alignment: .trailing, spacing: 8){
                Text("Startup: ")
                Text("Notify: ")
            }
            Form {
                Toggle("Launch on system startup", isOn: $launch)
                    .onChange(of: launch,  perform: { state in
                        if launch {
                            print("launch")
                            NSApp.enableRelaunchOnLogin()
                        } else {
                            print("no launch")
                            NSApp.disableRelaunchOnLogin()
                        }
                    })
                Toggle("Notify when timer ends", isOn: $notify)
                    .onChange(of: notify,  perform: { state in
                        if notify {
                            requestNotification()
                        }
                    })
            }

   
        }
    }
}
 
struct AppearanceSettingsView: View {
    var body: some View {
        VStack {
            Text("Appearance Settings")
                .font(.title)
            Text("Coming soon")
            
        }
    }
}
 
struct CustomDurationSettingsView: View {
    var activateCaffeinate: (TimeInterval, Bool) -> Void
    @AppStorage("customDuration") private var customDuration = 0.0
    
    var body: some View {
        VStack {
            HStack{
                Text("Custom Duration: ")
                Slider(value: $customDuration, in: 0...300)
                    .frame(width: 100.0)
                Text("\(customDuration, specifier: "%.0f") minutes")
            }
 
            Button("Confirm and Activate", action: {activateCaffeinate(customDuration * 60, false)})
        }
    }
}
