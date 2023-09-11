//
//  AppDelegate.swift
//  Cuppa
//
//  Created by Yunshu D on 21/8/2022.
//

import Cocoa
import Foundation
import AppKit
import SwiftUI


@main
struct CuppaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        UserDefaults.standard.register(defaults: [
            "customDuration": 1800,
            "launchAtLogin": false
        ])
    }

    
    var body: some Scene {
        Settings {
            SettingsView()
        }
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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        isActive = false
        caffeinateProc = nil
        toggleCupSymbol()
        setupMenus()

    }
    
    func setupMenus() {
        let menu = NSMenu()
        let custom = NSMenuItem(title: "Custom duration", action: #selector(set_custom), keyEquivalent: "c")
        menu.addItem(custom)
        
        let five = NSMenuItem(title: "5 minutes", action: #selector(set_five), keyEquivalent: "1")
        // TODO: add keyboard shortcuts- currently this does not quite work
//        five.allowsKeyEquivalentWhenHidden = true;
//        five.keyEquivalentModifierMask = [.control]
        menu.addItem(five)
        
        let fifteen = NSMenuItem(title: "15 minutes", action: #selector(set_fifteen), keyEquivalent: "2" )
        menu.addItem(fifteen)
        
        let thirty = NSMenuItem(title: "30 minutes", action: #selector(set_thirty), keyEquivalent: "3" )
        menu.addItem(thirty)
        
        let one_hour = NSMenuItem(title: "1 hour", action: #selector(set_hour), keyEquivalent: "4" )
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
        
        menu.addItem(withTitle: "About", action: #selector(about), keyEquivalent: "a")
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    

        statusItem.menu = menu
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
        // TODO: toggle add custom input view
    }
    @objc func set_indefinite() {
        self.toggleIndefinitely = true
        activateCaffeinate(duration: 0, indefinitely: true)
    }
    
    @objc func settings() {
        let launch = UserDefaults.standard.bool(forKey: "launchAtLogin")
        print(launch)
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    @objc func about() {
        NSApp.orderFrontStandardAboutPanel()
    }
    
    // Toggle symbol to full or empty depending on state
    func toggleCupSymbol() {
        var symbolName = "custom.cup.and.saucer.empty"
        if isActive {
            symbolName = "custom.cup.and.saucer.full"
            
        }
        if let statusButton = statusItem.button {
            if let image = NSImage(named: symbolName) {
                let config = NSImage.SymbolConfiguration(paletteColors: [.controlTextColor, .controlAccentColor])
                statusButton.image = image.withSymbolConfiguration(config)
            }
        }
    }
    
    // Activate caffeinate command for number minutes
    @objc func activateCaffeinate(duration: TimeInterval, indefinitely: Bool = false) {
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
            task.arguments = []
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
        }
    }
    
    @objc func deactivateCaffeinate() {
        terminateCaffeinate()
        self.isActive = false
        self.toggleIndefinitely = false
        self.caffeinateProc = nil
        toggleCupSymbol()
    }

    func notifyTermination(notification: NSNotification) {
        // TODO: send notif for cuppa timer finished
        // TODO: if user setting notif is allowed
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Tear down application
        terminateCaffeinate()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

