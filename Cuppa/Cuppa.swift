//
//  Cuppa.swift
//  Cuppa
//
//  Created by Yunshu D on 21/8/2022.
//

import Cocoa
import Foundation
import AppKit
import SwiftUI
import UserNotifications


@main
struct CuppaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        UserDefaults.standard.register(defaults: [
            "customDuration": 30,
            "launchAtLogin": false,
            "notifyOnTerminate": false,
            "lastVisitedPreference": 2,
            "firstLaunch": true,
            "launchPreference": false,
            "cupIcon": "custom",

        ])
    }

    @AppStorage("lastVisitedPreference") private var recentPref = 1
    
    var body: some Scene {
        Settings {
            SettingsView(activateCaffeinate: self.appDelegate.activateCaffeinate, toggleCupSymbol: self.appDelegate.toggleCupSymbol, tabSelection: $recentPref)
        }
    }
}

extension NSEvent {
    var isRightClick: Bool {
        let rightClick = (self.type == .rightMouseDown || self.type == .rightMouseUp)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
}

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var caffeinateProc: Process!
    private var timerDuration: TimeInterval!
    private var isActive: Bool!
    private var toggleIndefinitely: Bool!
    private var popover: NSPopover!
  
//    UNUserNotificationCenter.current().delegate = self
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        @AppStorage("lastVisitedPreference") var pref = 1
        @AppStorage("firstLaunch") var  firstLaunch = false
        @AppStorage("launchPreference") var  launchPref = false
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        isActive = false
        caffeinateProc = nil
        toggleCupSymbol()
        setupMenus()
        
        // Show preferences if first launch
        if (firstLaunch || launchPref) {
            settings()
            UserDefaults.standard.set(false, forKey: "firstLaunch")
        }
        
        
        // TODO: detect left/right button click
        if let button = statusItem.button {
            print("button initiated")
            button.action = #selector(onClick)
            button.sendAction(on: [.leftMouseDown, .rightMouseDown, .rightMouseUp, .leftMouseUp])
        }
    }
    
    
    @objc
    func onClick() {
        print("bleh")
        if let event = NSApp.currentEvent, event.isRightClick {
            print("right")
        } else {
          print("left")
        }
    }
    
    @objc func doSomeAction(_ sender: NSStatusBarButton) {
        // TODO: allow user to see how long cuppa has until deactivation
        print("we are here")
        guard let event = NSApp.currentEvent else {
            print("naw")
            return
            
        }
            switch event.type {
            case .rightMouseDown:
//                statusItem.popUpMenu(statusItemMenuHandler.menu)
                print("right!")
            default:
                print("leftg!")
            }
    }

    func applicationWillUpdate(_ notification: Notification) {
        NSApp.arrangeInFront(nil)
    }
    
    

    func setupMenus() {
        @AppStorage("customDuration") var customDuration = 0.0
        
        let menu = NSMenu()
        // TODO custom timer
        let custom = NSMenuItem(title: "Custom (\(String(format: "%.0f", customDuration)) minutes)", action: #selector(set_custom), keyEquivalent: "c")
        menu.addItem(custom)
        
        // TODO: add global keyboard shortcuts- currently shortcuts only work when menu is shown
    
        let five = NSMenuItem(title: "5 minutes", action: #selector(set_five), keyEquivalent: "")
        menu.addItem(five)
        
        let fifteen = NSMenuItem(title: "15 minutes", action: #selector(set_fifteen), keyEquivalent: "" )
        menu.addItem(fifteen)
        
        let thirty = NSMenuItem(title: "30 minutes", action: #selector(set_thirty), keyEquivalent: "" )
        menu.addItem(thirty)
        
        let one_hour = NSMenuItem(title: "1 hour", action: #selector(set_hour), keyEquivalent: "" )
        menu.addItem(one_hour)
        
        let infinite = NSMenuItem(title: "Indefinitely", action: #selector(set_indefinite), keyEquivalent: "i" )
        menu.addItem(infinite)
        
        menu.addItem(NSMenuItem.separator())
        
        let deactivate = NSMenuItem(title: "Deactivate", action: #selector(deactivateCaffeinate), keyEquivalent: "d")
        menu.addItem(deactivate)
        deactivate.allowsKeyEquivalentWhenHidden = true;
        
        menu.addItem(NSMenuItem.separator())
        
        let settings = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: "s" )
        menu.addItem(settings)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "About Cuppa...", action: #selector(about), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
        
        statusItem.menu = menu
    }
    
    func launchOnLogin() {
        @AppStorage("launchAtLogin") var launch = false
        if launch {
            print("will launch")
            NSApp.enableRelaunchOnLogin()
        } else {
            print("will not launch")
            NSApp.disableRelaunchOnLogin()
        }
    }
    
    @objc func set_five() {
        activateCaffeinate(duration: 300)
    }
    @objc func set_fifteen() {
        activateCaffeinate(duration: 900)
    }
    @objc func set_thirty() {
        activateCaffeinate(duration: 1800)
    }
    @objc func set_hour() {
        activateCaffeinate(duration: 3600)
    }
    @objc func set_custom() {
        UserDefaults.standard.set(3, forKey: "lastVisitedPreference")
        settings()
    }
    @objc func set_indefinite() {
        self.toggleIndefinitely = true
        activateCaffeinate(duration: 0, indefinitely: true)
    }
    
    @objc func settings() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            NSApp.arrangeInFront(nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    @objc func about() {
        NSApp.orderFrontStandardAboutPanel()
    }
    
    // Toggle symbol to full or empty depending on state
    func toggleCupSymbol() {
        @AppStorage("cupIcon") var icon = "custom"
        
        var symbolName = "custom.cup.and.saucer.empty"
        if (isActive) {
            symbolName = "custom.cup.and.saucer.full"
        }
        else if (icon == "skeleton"){
            symbolName = "cup.and.saucer"
        }
        
        let config = NSImage.SymbolConfiguration(paletteColors: [.controlTextColor, .controlAccentColor])

        if let statusButton = statusItem.button {
            if (icon == "custom" || isActive){
                if let image = NSImage(named: symbolName) {
                    statusButton.image = image.withSymbolConfiguration(config)
                }
            } else {
                if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "cup") {
                    statusButton.image = image.withSymbolConfiguration(config)
                }
            }
        }
    }
    
    // Activate caffeinate command for number minutes
    @objc func activateCaffeinate(duration: TimeInterval, indefinitely: Bool = false) {

        setupMenus()
        // Terminate existing instances
        if (self.isActive) {
            terminateCaffeinate()
        }
        self.timerDuration = duration
        self.isActive = true
        toggleCupSymbol()
        spawnCaffeinate(indefinitely: indefinitely)

        // Spawn separate thread for job if not running infinitely
        if (!indefinitely) {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.timerDuration) {
                self.deactivateCaffeinate()
            }
        }
    }
    
    // Spawn caffeinate process
    func spawnCaffeinate(indefinitely: Bool = false) {
        let task = Process()
        task.launchPath = "/usr/bin/caffeinate"
        task.standardOutput = FileHandle.nullDevice // Equivalent to /dev/null
        task.standardError = FileHandle.nullDevice
        if indefinitely == false {
            task.arguments = ["-dt", String(format: "%.f", self.timerDuration)]
        } else {
            task.arguments = ["-d"]
        }
        self.caffeinateProc = task
        task.launch()
    }
    
    
    // Terminates current caffeinate process
    func terminateCaffeinate() {
        // Check there actually is an instance running
        if (self.caffeinateProc == nil) {
            return
        }
        if (self.caffeinateProc.isRunning) {
            self.caffeinateProc.terminate()
            if UserDefaults.standard.bool(forKey: "notifyOnTerminate") {
                setNotification()
            }
        }
    }
    
    @objc func deactivateCaffeinate() {
        terminateCaffeinate()
        self.isActive = false
        self.toggleIndefinitely = false
        self.caffeinateProc = nil
        toggleCupSymbol()
    }
    
    @objc func setNotification(duration: TimeInterval = 1) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let id = "Deactivated"
                let content = UNMutableNotificationContent()
                content.title = "Cuppa has deactivated!"
                content.body = "Your Mac screen will go to sleep normally"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                center.add(request) { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                    
                }
            }
        }
    }

//
//    func notifyTermination(notification: NSNotification) {
//
//        // TODO: send notif for cuppa timer finished
//        // TODO: if user setting notif is allowed
//    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Tear down application
        terminateCaffeinate()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}
