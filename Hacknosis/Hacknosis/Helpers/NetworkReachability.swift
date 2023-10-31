//
//  NetworkReachability.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation
import Network

class NetworkReachability {
    
    static let shared = NetworkReachability()
    private var monitor: NWPathMonitor?
    private var isMonitoring = false
    
    // use it to notified that monitoring did start.
    var didStartMonitoringHandler: (() -> Void)?
    
    // use it to notified that monitoring did stopped.
    var didStopMonitoringHandler: (() -> Void)?
    
    // use it to monitor the network status changes.
    var netStatusChangeHandler: (() -> Void)?
    
    var previousStatus:NWPath.Status = .satisfied
    // use it to check network is connected or not.
    var isConnected: Bool {
        
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    // current network type like cellular, wi-fi or any other...
    var interfaceType: NWInterface.InterfaceType? {
        guard let _ = monitor else { return nil }
        return self.availableInterfacesTypes?.first
    }
    
    private var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }
    
    
    private init() { }
    
    // call it first to start monitoring the network connection.
    func startMonitoring() {
        
        // if already monitoring, return it.
        if isMonitoring { return }
        
        monitor = NWPathMonitor()
        
        // running it on background thread, because we are continually monitoring the network.
        let queue = DispatchQueue(label: "Monitor")
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { newPath in
            self.netStatusChangeHandler?()
            if newPath.status != self.previousStatus {
                //NotificationCenter.default.post(name: .networkReachabilityChanged, object: nil)
                debugPrint("netStatusChangeHandler:\(newPath.status)")
            }
            self.previousStatus = newPath.status
        }
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    // call it to stop the monitoring.
    func stopMonitoring() {
        if isMonitoring, let monitor = monitor {
            monitor.cancel()
            self.monitor = nil
            isMonitoring = false
            didStopMonitoringHandler?()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
