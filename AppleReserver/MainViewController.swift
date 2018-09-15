//
//  MainViewController.swift
//  AppleReserver
//
//  Created by Sunnyyoung on 2017/9/19.
//  Copyright © 2017年 Sunnyyoung. All rights reserved.
//

import Cocoa
//import Alamofire

class MainViewController: NSViewController {
    @IBOutlet weak var storeTableView: NSTableView!
    @IBOutlet weak var availabilityTableView: NSTableView!
    @IBOutlet weak var notificationButton: NSButton!
    @IBOutlet weak var timerIntervalButton: NSPopUpButton!
    @IBOutlet weak var fireButton: NSButton!
    @IBOutlet weak var indicator: NSProgressIndicator!

    fileprivate lazy var products: [IPhonexsProduct] = []
    fileprivate var stores: [Store]?
    fileprivate var availabilities: [Availability]? {
        didSet {
            guard let availabilities = self.availabilities, self.notificationButton.state == .on else {
                return
            }
            for selectedPartNumber in self.selectedPartNumbers {
                guard let availability = availabilities.first(where: { $0.partNumber == selectedPartNumber }),
                    availability.contract || availability.unlocked else {
                    return
                }
                let notification = NSUserNotification()
                notification.informativeText = "\(availability.partNumber) 有货啦！！！"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }

    fileprivate var selectedStore: Store?
    fileprivate var selectedPartNumbers: Set<String> = []

    fileprivate var pollingTimer: Timer?
    fileprivate var reserveURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadProducts()
        self.loadStores()
    }

    // MARK: Load method
    func loadProducts() {
        guard let fileURL = Bundle.main.url(forResource: "iPhone-xs", withExtension: "json") else {
            return
        }
        do {
            let fileData = try Data.init(contentsOf: fileURL)
            guard let json = try JSONSerialization.jsonObject(with: fileData, options: .mutableContainers) as? [String: Any] else {
                return
            }
            let productTree = json["productTree"] as! [String : Any]
            let root = productTree["root"] as! [String : [String : Any]]
            root.forEach { (root_dict) in
                let screen_size_dict = root_dict.value
                let screenname = root_dict.key
                screen_size_dict.forEach({ (screen_dict) in
                    let colorname = screen_dict.key
                    if colorname == "_images" {
                        return
                    }
                    let colordict = screen_dict.value as? [String : Any]
                    colordict?.forEach({ (capacity_dict) in
                        let capacity = capacity_dict.key
                        let productdict = capacity_dict.value as! [String : Any]
                        guard let partNumber = productdict["partNumber"] as? String else { return }
                        guard let price = productdict["price"] as? String else { return }
                       
                        let product = IPhonexsProduct(partNumber: partNumber, color: colorname, capacity: capacity, screenSize: screenname, price: price)
                        self.products.append(product)
                    })
                    
                })
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    func loadStores() {
        request(AppleURL.stores).responseJSON { (response) in
            if let error = response.error {
                NSAlert(error: error).runModal()
            } else {
                guard let json = response.value as? [String: Any],
                    let stores = (json["stores"] as? [[String: Any]])?.map({ Store(json: $0) }) else {
                    return
                }
                self.stores = stores
                self.storeTableView.reloadData()
            }
        }
    }

    @objc private func reloadAvailability() {
        request(AppleURL.availability).responseJSON { (response) in
            if let error = response.error {
                NSAlert(error: error).runModal()
            } else {
                guard let storeNumber = self.selectedStore?.storeNumber,
                    let json = response.value as? [String: Any],
                    let stores = json["stores"] as? [String: Any],
                    let availabilities = (stores[storeNumber] as? [String: [String: [String: Bool]]])?.map({ Availability(key: $0.key, value: $0.value) }) else {
                    return
                }
                self.availabilities = availabilities
                self.availabilityTableView.reloadData()
            }
        }
    }

    // MARK: Event method
    @IBAction func fireAction(_ sender: NSButton) {
        let interval = Double(self.timerIntervalButton.titleOfSelectedItem ?? "3") ?? 3.0
        if self.pollingTimer?.isValid == true {
            sender.title = "开始"
            self.storeTableView.isEnabled = true
            self.timerIntervalButton.isEnabled = true
            self.indicator.stopAnimation(sender)
            self.pollingTimer = {
                self.pollingTimer?.invalidate()
                return nil
            }()
        } else {
            sender.title = "停止"
            self.storeTableView.isEnabled = false
            self.timerIntervalButton.isEnabled = false
            self.indicator.startAnimation(sender)
            self.pollingTimer = {
                let timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(reloadAvailability), userInfo: nil, repeats: true)
                timer.fire()
                return timer
            }()
        }
    }

    @IBAction func reserveAction(_ sender: NSTableView) {
        guard let url = self.reserveURL, sender.selectedRow >= 0 else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

extension MainViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.storeTableView {
            return self.stores?.count ?? 0
        } else if tableView == self.availabilityTableView {
            return self.availabilities?.count ?? 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == self.storeTableView {
            return self.stores?[row].storeName
        } else if tableView == self.availabilityTableView {
            guard let identifier = tableColumn?.identifier.rawValue,
                let availability = self.availabilities?[row],
                let product = self.products.first(where: { $0.partNumber == availability.partNumber }) else {
                return nil
            }
            switch identifier {
            case "Monitoring":
                return self.selectedPartNumbers.contains(availability.partNumber)
            case "PartNumber":
                return availability.partNumber
            case "Description":
                return product.description
            case "Capacity":
                return product.capacity
            case "Status":
                return (availability.contract || availability.unlocked) ? "有货" : "无货"
            default:
                return nil
            }
        } else {
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let partNumber = self.availabilities?[row].partNumber, let selected = object as? Bool else {
            return
        }
        if selected {
            self.selectedPartNumbers.insert(partNumber)
        } else {
            self.selectedPartNumbers.remove(partNumber)
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView, tableView.selectedRow >= 0 else {
            return
        }
        if tableView == self.storeTableView {
            self.selectedStore = self.stores?[tableView.selectedRow]
            self.selectedPartNumbers.removeAll()
            self.availabilityTableView.deselectAll(nil)
            self.reloadAvailability()
        } else if tableView == self.availabilityTableView {
            guard let storeNumber = self.selectedStore?.storeNumber,
                let partNumber = self.availabilities?[tableView.selectedRow].partNumber else {
                return
            }
            // https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone/availability?channel=1&appleCare=N&iPP=N&partNumber=MT712CH/A&path=/cn/shop/buy-iphone/iphone-xs/MT712CH/A&rv=1
            self.reserveURL = URL(string: "https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone?quantity=1&store=\(storeNumber)&partNumber=\(partNumber)&channel=1&sourceID=&iUID=&iuToken=&iUP=N&appleCare=N&rv=1&path=%2Fcn%2Fshop%2Fbuy-iphone%2Fiphone-xs%2FMT712CH%2FA&plan=unlocked")
            // URL    https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone?quantity=1&store=R448&partNumber=MT9P2CH%2FA&channel=1&sourceID=&iUID=&iuToken=&iUP=N&appleCare=N&rv=1&path=%2Fcn%2Fshop%2Fbuy-iphone%2Fiphone-xs%2FMT712CH%2FA&plan=unlocked
        }
    }
}
