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


//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var caffeinateProc: Process!
    private var timerDuration: TimeInterval!
    private var isActive: Bool!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        isActive = false
        caffeinateProc = nil
        toggleCupSymbol()
        setupMenus()
        
//        // TODO small window to show preferences, utilities etc.
//        let contentView = ContentView()
//        window = NSWindow(
//                   contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//                   backing: .buffered, defer: false)
//               window.center()
//               window.setFrameAutosaveName("Main Window")
//               window.contentView = NSHostingView(rootView: contentView)
//               window.makeKeyAndOrderFront(nil)

    }
    
    // TODO get rid of? Was having trouble with UIapplication not being in scope
//    func application(_ application: NSApplication, didFinishLaunchingWithOptions launchOptions: [NSApplication.ActivationOptions /*LaunchOptionsKey*/ : Any]? = nil) -> Bool {
//        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        isActive = false
//        caffeinateProc = nil
//        toggleCupSymbol()
//        setupMenus()
        
//        let center = NSUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
//
//            if let error = error {
//                // Handle the error here.
//            }
//
//            // Provisional authorization granted.
//        }
        
        
//    }

    
    func setupMenus() {
        let menu = NSMenu()
        let custom = NSMenuItem(title: "Custom duration", action: #selector(set_custom), keyEquivalent: "c")
        custom.allowsKeyEquivalentWhenHidden = true;
        custom.keyEquivalentModifierMask = [.control]
        menu.addItem(custom)
        
        let five = NSMenuItem(title: "5 minutes", action: #selector(set_five), keyEquivalent: "1")
        five.allowsKeyEquivalentWhenHidden = true;
        five.keyEquivalentModifierMask = [.control]
        menu.addItem(five)
        
        let fifteen = NSMenuItem(title: "15 minutes", action: #selector(set_fifteen), keyEquivalent: "2" )
        fifteen.allowsKeyEquivalentWhenHidden = true;
        fifteen.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(fifteen)
        
        let thirty = NSMenuItem(title: "30 minutes", action: #selector(set_thirty), keyEquivalent: "3" )
        thirty.allowsKeyEquivalentWhenHidden = true;
        thirty.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(thirty)
        
        let one_hour = NSMenuItem(title: "1 hour", action: #selector(set_hour), keyEquivalent: "4" )
        one_hour.allowsKeyEquivalentWhenHidden = true;
        one_hour.keyEquivalentModifierMask = [.command, .option]
        menu.addItem(one_hour)
        
        
        menu.addItem(NSMenuItem.separator())
        
        let deactivate = NSMenuItem(title: "Deactivate", action: #selector(deactivateCaffeinate), keyEquivalent: "d")
        menu.addItem(deactivate)
        deactivate.allowsKeyEquivalentWhenHidden = true;
        deactivate.keyEquivalentModifierMask = [.command, .option]
        
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        one_hour.keyEquivalentModifierMask = [.command, .option]
        
        statusItem.menu = menu
    }
    
    @objc func set_test() {
        print("Testing...")
        activateCaffeinate(duration: 30)
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
        // TODO
    }
    
    // Toggle symbol to full or empty depending on state
    func toggleCupSymbol() {
        var symbolName = "custom.cup.and.saucer.empty"
        if isActive {
            symbolName = "custom.cup.and.saucer.full"
            
        }
        // #DEBUGGING
        //print("setting symbol to ", symbolName)
        if let statusButton = statusItem.button {
            if let image = NSImage(named: symbolName) {
                let config = NSImage.SymbolConfiguration(paletteColors: [.controlTextColor, .controlAccentColor])
                statusButton.image = image.withSymbolConfiguration(config)
            }
        }
    }
    
    // Activate caffeinate command for number minutes
    @objc func activateCaffeinate(duration: TimeInterval) {
        // Terminate existing instances
        if (self.isActive) {
            terminateCaffeinate() // TODO
        }
        self.timerDuration = duration
        self.isActive = true
        toggleCupSymbol()
        spawnCaffeinate()

        // Spawn separate thread for job
        DispatchQueue.main.asyncAfter(deadline: .now() + self.timerDuration) {
            self.deactivateCaffeinate()
        }
    }
    
    
    // Spawn caffeinate process
    func spawnCaffeinate() {
        let task = Process()
        task.launchPath = "/usr/bin/caffeinate"
        task.standardOutput = FileHandle.nullDevice // Equivalent to /dev/null
        task.standardError = FileHandle.nullDevice
        task.arguments = ["-dt", String(format: "%.f", self.timerDuration)]
        self.caffeinateProc = task
        task.launch()
    }
    
    
    // Terminates current caffeinate process
    func terminateCaffeinate() {
        // Double check there actually is an instance running
        if (self.caffeinateProc == nil) {
            return
        }
        if (self.caffeinateProc.isRunning) {
            self.caffeinateProc.terminate()
        }
    }
    
    @objc func deactivateCaffeinate() {
        // #DEBUGGING
        //print("Deactivating caffeinate instance...")
        terminateCaffeinate()
        self.isActive = false
        self.caffeinateProc = nil
        toggleCupSymbol()
    }

    func notifyTermination(notification: NSNotification) {
        // send notif for cuppa finished
        // if user setting notif is allowed
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        terminateCaffeinate()
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

