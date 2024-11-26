
import Foundation

import ArgumentParser

@main
struct PairingParser: ParsableCommand {
    
    // MARK: - Struct for the Plist Data
    struct DevicePair: Codable {
        let deviceCertificate: Data
        let devicePublicKey  : Data
        let escrowBag        : Data
        let hostCertificate  : Data
        let hostID           : UUID
        let hostPrivateKey   : Data
        let rootCertificate  : Data
        let rootPrivateKey   : Data
        let systemBUID       : UUID
        let wifiMACAddress   : String

        enum CodingKeys: String, CodingKey {
            case deviceCertificate = "DeviceCertificate"
            case devicePublicKey   = "DevicePublicKey"
            case escrowBag         = "EscrowBag"
            case hostCertificate   = "HostCertificate"
            case hostID            = "HostID"
            case hostPrivateKey    = "HostPrivateKey"
            case rootCertificate   = "RootCertificate"
            case rootPrivateKey    = "RootPrivateKey"
            case systemBUID        = "SystemBUID"
            case wifiMACAddress    = "WiFiMACAddress"
        }

        init?(from url: URL) {
            do {
                let data = try Data(contentsOf: url)
                let decoder = PropertyListDecoder()
                self = try decoder.decode(Self.self, from: data)
            } catch {
                print("Error parsing plist: \(error)")
                return nil
            }
        }
    }
    
    func dti(_ d: Data) -> UInt64 {
        if d.count >= 8 {
            return d.withUnsafeBytes { $0.load(as: UInt64.self) }
        } else {
            return dti(d + Data(repeating: 0, count: 8 - d.count))
        }
    }
    

    @Argument(help: "Path to the pairing file")
    var pairPath: String
    
    @Argument(help: "Path to save the Device Certificate")
    var devCertPath: String = "keys/server/cert.pem"
    
    @Argument(help: "Path to save the Root Certificate")
    var rootCertPath: String = "keys/ca/ca.crt"
    
    @Argument(help: "Path to save the Host Certificate")
    var hostCertPath: String = "keys/client/cert.pem"
    
    @Argument(help: "Path to save the Host Private Key")
    var hostPrivKeyPath: String = "keys/client/key.pem"
    
    mutating func run() throws {
        let pURL = URL(fileURLWithPath: pairPath)
        guard let pair = DevicePair(from: pURL) else {
            print("Failed to parse the pairing file.")
            return
        }
        
        // Ensure directories exist before saving files
        try ensureDirectoryExists(for: devCertPath)
        try ensureDirectoryExists(for: rootCertPath)
        try ensureDirectoryExists(for: hostCertPath)
        try ensureDirectoryExists(for: hostPrivKeyPath)
        
        // Save the files
        try pair.deviceCertificate.write(to: URL(fileURLWithPath: devCertPath))
        try pair.rootCertificate.write(to: URL(fileURLWithPath: rootCertPath))
        try pair.hostCertificate.write(to: URL(fileURLWithPath: hostCertPath))
        try pair.hostPrivateKey.write(to: URL(fileURLWithPath: hostPrivKeyPath))
        
        // Print details
        print("Certificates saved in keys!")
        print("Host ID: \(pair.hostID)")
        print("System BUID: \(pair.systemBUID)")
        print("WiFi MAC Address: \(pair.wifiMACAddress)")
        print("Escrow Bag as UInt64: \(pair.escrowBag)")
    }
    
    // Helper function to ensure directory exists
    private func ensureDirectoryExists(for path: String) throws {
        let directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
