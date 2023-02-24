//
//  ConnectC2XViewController.swift
//

import Foundation
import UIKit
import Heartland_iOS_SDK
import CoreBluetooth

class ConnectC2XViewController: UIViewController {
    
    var device: HpsC2xDevice?
    var paxDevice: HpsPaxDevice?
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    @IBOutlet var connectionLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanButtonStackView: UIStackView!
    @IBOutlet weak var scanButtonReference: UIButton!
    
    
    @IBAction func scanButtonPressed() {
        
        scanButtonReference.isEnabled = false
        let timeout = 120

        let config = HpsConnectionConfig()
        config.username = ""
        config.password = ""
        config.siteID = "";
        config.deviceID = ""
        config.licenseID = ""
        config.developerID = ""
        config.versionNumber = ""
        config.timeout = timeout

        self.device = HpsC2xDevice(config: config)
        self.device?.deviceDelegate = self
        self.device?.scan()
        self.activityIndicator.isHidden = false
        
    }
    
    func testPaxDeviceManual() {
        let timeout = 120

        let config = HpsConnectionConfig()
        config.ipAddress = ""
        config.port = ""
        config.username = ""
        config.password = ""
        config.siteID = "";
        config.deviceID = ""
        config.licenseID = ""
        config.developerID = ""
        config.versionNumber = ""
        config.connectionMode = 1
        config.timeout = timeout

        self.paxDevice = HpsPaxDevice(config: config)

        let builder = HpsPaxCreditSaleBuilder(device: self.paxDevice)
        builder?.amount = 11.0
        builder?.referenceNumber = 10
        builder?.allowDuplicates = false


        builder?.execute({ response, error in

            if let error = error {
                print("Error: \(error)")
                return
            }
            if let response = response {
                print("Response: \(response)")
                let responseReturn = response.parseResponse()
                print("Response Parse: \(responseReturn.debugDescription)")
            }
        })
    }
    
    func testPaxDeviceAuth() {
        let timeout = 120

        let config = HpsConnectionConfig()
        config.ipAddress = ""
        config.port = ""
        config.username = ""
        config.password = ""
        config.siteID = "";
        config.deviceID = ""
        config.licenseID = ""
        config.developerID = ""
        config.versionNumber = ""
        config.connectionMode = 1
        config.timeout = timeout

        self.paxDevice = HpsPaxDevice(config: config)

        let card = HpsCreditCard()
        card.cardNumber = ""
        card.expMonth = 1
        card.expYear = 2
        card.cvv = ""

        let address = HpsAddress()
        address.address = ""
        address.zip = ""

        let builder = HpsPaxCreditAuthBuilder(device: self.paxDevice)
        builder?.amount = 11.0
        builder?.referenceNumber = 1
        builder?.allowDuplicates = true
        builder?.requestMultiUseToken = true
        builder?.creditCard = card
        builder?.address = address

        builder?.execute({ response, error in

            if let error = error {
                print("Error: \(error)")
                return
            }
            if let response = response {
                print("Response: \(response)")
                let responseReturn = response.parseResponse()
                print("Response Parse: \(responseReturn.debugDescription)")
            }
        })
    }
}

extension ConnectC2XViewController: HpsC2xDeviceDelegate {
    func onConnected() {
        self.connectionLabel.text = "Connected"
        scanButtonReference.isEnabled = true
        
        let selectedDevice:[String: HpsC2xDevice?] = ["selectedDevice": self.device]
        notificationCenter.post(name: Notification.Name(Constants.selectedDeviceNotification),
                                object: nil, userInfo: selectedDevice)
    }
    
    func onDisconnected() {
        self.connectionLabel.text = "Disconnected"
        scanButtonReference.isEnabled = true
    }
    
    func onError(_ deviceError: NSError) {
        self.connectionLabel.text = "Error"
        scanButtonReference.isEnabled = true
    }
    
    func onBluetoothDeviceList(_ peripherals: NSMutableArray) {
        
        let alertController = UIAlertController(title: "Devices", message: "Please select a device to connect", preferredStyle: .actionSheet)
        
        for peripheral in peripherals {
            if let peripheral = peripheral as? HpsTerminalInfo {
                let action = UIAlertAction(title: peripheral.name, style: .default) { [weak self] _ in
                    self?.device?.connectDevice(peripheral)
                }
                alertController.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [weak self] _ in
            self?.scanButtonReference.isEnabled = true
        }
        alertController.addAction(cancelAction)
        if case .pad = UIDevice.current.userInterfaceIdiom {
            alertController.popoverPresentationController?.sourceView = scanButtonStackView
            alertController.popoverPresentationController?.sourceRect = scanButtonStackView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = .down
        }
        self.present(alertController, animated: true)
        
        self.activityIndicator.isHidden = true
    }
}

// MARK: - IDIOM

private extension ConnectC2XViewController {
    enum UIUserInterfaceIdiom : Int {
        case phone // iPhone and iPod touch style UI
        case pad   // iPad style UI (also includes macOS Catalyst)
    }
}
