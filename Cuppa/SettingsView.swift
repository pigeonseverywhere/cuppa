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
    var toggleCupSymbol: () -> Void
//    @State private var tabSelection = 1
    @Binding var tabSelection: Int
    
    var body: some View {
        TabView (selection: $tabSelection){
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }.tag(1)
            
            AppearanceSettingsView(toggleCupSymbol: toggleCupSymbol)
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }.tag(2)
            
            CustomDurationSettingsView(activateCaffeinate: activateCaffeinate)
                .tabItem {
                    Label("Custom time", systemImage:  "timer")
                }.tag(3)
            AboutView()
                .tabItem {
                    Label("About", systemImage: "cup.and.saucer.fill")
                }.tag(4)
            
        }.frame(width: 400, height: 180)
        
    }

}

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launch = false
    @AppStorage("notifyOnTerminate") private var notify = false
    @AppStorage("launchPreference") private var launchPref = false
    
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

    var body: some View {
        Form {
            VStack(spacing: 10){
                HStack {
                    Text("Launch at login")
                    Spacer()
                    Toggle("", isOn: $launch).toggleStyle(.switch)
                        .onChange(of: launch,  perform: { state in
                            if launch {
                                print("launch")
                                NSApp.enableRelaunchOnLogin()
                            } else {
                                print("no launch")
                                NSApp.disableRelaunchOnLogin()
                            }
                    })
                }
                Divider()
                HStack {
                    Text("Notification")
                    Spacer()
                    Toggle("", isOn: $notify).toggleStyle(.switch)
                        .onChange(of: notify,  perform: { state in
                            if notify {
                                requestNotification()
                            }
                    })
                }
            Divider()
                HStack{
                    Text("Show preferences on launch")
                    Spacer()
                    Toggle("", isOn: $launchPref).toggleStyle(.switch)
                }
                
            }
        }.padding(.horizontal).frame(width: 350, height: 100, alignment: .center
        )
    }
}
 
struct AppearanceSettingsView: View {
    var toggleCupSymbol: () -> Void
    enum CupIcon: String, CaseIterable, Identifiable {
        case custom
        case skeleton
        var id: Self { self }
    }
    @AppStorage("cupIcon") private var selectedSet = CupIcon.custom
    
    var body: some View {
        Form{
            HStack (spacing: 20){
                Text("Menu icons")

                Picker(selection: $selectedSet, label: Text("")) {
                    HStack{
                        Image(systemName: "cup.and.saucer")
                        Image("custom.cup.and.saucer.full").symbolRenderingMode(.palette).foregroundStyle(.primary, .tint)
                    }.tag(CupIcon.skeleton)
                    HStack{
                        Image("custom.cup.and.saucer.empty")
                        Image("custom.cup.and.saucer.full").symbolRenderingMode(.palette).foregroundStyle(.primary, .tint)
                    }.tag(CupIcon.custom)
                }.pickerStyle(RadioGroupPickerStyle()).onChange(of: selectedSet) { selectedSet in
                    print("selected: \(selectedSet)")
                    toggleCupSymbol()
                }
                
            }
            Text("Menubar icons to represent \nactivated/deactivated").font(.caption).foregroundColor(.secondary)
        }.padding(.horizontal).frame(width: 350)
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

struct AboutView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        HStack{
            Image("green-tea-257").resizable().frame(width: 80, height: 80)
            VStack(alignment: .leading){
                Text("Cuppa").font(.title)
                Text("v1.0.1").font(.subheadline)
                VStack(alignment: .leading, spacing: -2){
                    Link("Github page", destination: URL(string: "https://github.com/pigeonseverywhere/cuppa")!)
                    Link("App icon created by Freepik", destination: URL(string: "https://www.flaticon.com/free-icons/green-tea")!)
                }
                
            }
        }.frame(width: 400, height: 200)
    }
    
}
