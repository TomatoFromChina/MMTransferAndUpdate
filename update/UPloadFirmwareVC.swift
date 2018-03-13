//
//  UPloadFirmware.swift
//  Tomato
//
//  Created by xuliusheng on 2017/6/5.
//  Copyright © 2017 Tomato. All rights reserved.
//

import UIKit
import iOSDFULibrary
import CoreBluetooth

typealias successBlock = () -> ()

class UPloadFirmwareVC: UIViewController ,LoggerDelegate,DFUProgressDelegate,DFUServiceDelegate{

    var selectedPeripheral : CBPeripheral?
    var centralManager     : CBCentralManager?
    var dfuController      : DFUServiceController?
    var selectedFirmware   : DFUFirmware?
    var selectedFileURL    : URL?
    
    var bgView             : UIView!
    var processLab         : UILabel!
    var progressView       : UIProgressView!
    var alertVC            : UIAlertController!
    var successBlock       : successBlock?
    
    override func viewDidAppear(_ animated: Bool) {
        
        alertVC = UIAlertController(title: "update process", message: "\n\n\n\n\nprocessing，do not shut down！", preferredStyle: UIAlertControllerStyle.alert)
        
        processLab = UILabel(frame:CGRect(x:10, y:60, width:250, height:16))
        processLab.font = UIFont.systemFont(ofSize: 15)
        processLab.textAlignment = NSTextAlignment.center
        processLab.text = "0%"
        alertVC.view.addSubview(processLab);
        
        
        progressView = UIProgressView(progressViewStyle:UIProgressViewStyle.default)
        progressView.frame = CGRect(x:10, y:95, width:250, height:1)
        
        
        
        
        alertVC.view.addSubview(progressView)
        self.present(alertVC, animated: true) {
            self.upload()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "update", style: .plain, target:self, action:#selector(UPloadFirmwareVC.upload))
        
        
        var aFileURL:URL?
        var documentPath:String?
        var exist:Bool = false
		let homeDirectory = NSHomeDirectory()
		documentPath = homeDirectory + "/Documents/" + "blue.zip"
		aFileURL = URL(string :documentPath!)
		let fileManager = FileManager.default
		exist = fileManager.fileExists(atPath: documentPath!)
		
 
        if exist == false {
            let filePath = Bundle.main.path(forResource: "DFU_BLE_UART", ofType: "zip")
            aFileURL = URL(string:filePath!)
        }
		
        selectedFirmware = DFUFirmware(urlToZipFile: aFileURL!)
		centralManager = FQBleManager.shared().manager
			
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func upload() -> Void {
        print("bgin")
		
        if (selectedPeripheral != nil && selectedFirmware != nil) {
            let initiator = DFUServiceInitiator(centralManager: centralManager!, target: selectedPeripheral!)
            initiator.forceDfu = false //UserDefaults.standard.bool(forKey: "dfu_force_dfu")
            initiator.packetReceiptNotificationParameter = 20//UInt16(UserDefaults.standard.integer(forKey: "dfu_number_of_packets"))
            initiator.logger = self
            initiator.delegate = self
            initiator.progressDelegate = self
            initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
            dfuController = initiator.with(firmware: selectedFirmware!).start()
        }else{
			print("selectedPeripheral == nil || selectedFirmware == nil");
        }
    }

    func performDFU() {
        
        // To start the DFU operation the DFUServiceInitiator must be used

        //uploadButton.setTitle("Cancel", for: UIControlState())
        //uploadButton.isEnabled = true
    }
    
    
    
    //MARK: - DFUServiceDelegate
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .connecting:
            print("Connecting...")
            processLab.text = "Connecting..."
            break
        case .starting:
            print("Starting DFU...")
            processLab.text = "Starting DFU..."
            break
        case .enablingDfuMode:
            processLab.text = "Enabling DFU Bootloader..."
            print("Enabling DFU Bootloader...")
            break
        case .uploading:
            print("Uploading...")
            break
        case .validating:
            print("Validating...")
            break
        case .disconnecting:
            print("Disconnecting...")
            break
        case .completed:
            print("Upload complete")
            self.dismiss(animated:(alertVC != nil)) {
				self.view.window?.makeToast("update success!")
				if (self.successBlock != nil){
					self.successBlock!()
				}
				
                self.dismiss(animated: true, completion: {
                })
            }
            break
//            NORDFUConstantsUtility.showAlert(message: "Upload complete")
//            if NORDFUConstantsUtility.isApplicationStateInactiveOrBackgrounded() {
//                NORDFUConstantsUtility.showBackgroundNotification(message: "Upload complete")
//            }
//            self.clearUI()
        case .aborted:
            print("Upload aborted")
			self.view.window?.makeToast("update aborted!")
            break
            
//            NORDFUConstantsUtility.showAlert(message: "Upload aborted")
//            if NORDFUConstantsUtility.isApplicationStateInactiveOrBackgrounded(){
//                NORDFUConstantsUtility.showBackgroundNotification(message: "Upload aborted")
//            }
//            self.clearUI()
        }
    }
	
	func removeBlue()->Bool {
		
		let homeDirectory = NSHomeDirectory()
		let documentPath = homeDirectory + "/Documents/" + "blue.zip"
		
		let fileManager = FileManager.default
		let exist = fileManager.fileExists(atPath: documentPath)
		if exist {
			do{
				try fileManager.removeItem(atPath: documentPath)
			}catch{
				return false
			}
		}
		return true;
	}
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
//        if NORDFUConstantsUtility.isApplicationStateInactiveOrBackgrounded() {
//            NORDFUConstantsUtility.showBackgroundNotification(message: message)
//        }
//        self.clearUI()
        print("出错了")
		self.view.window?.makeToast("update error!")
		self.dismiss(animated:(alertVC != nil)) {
			self.dismiss(animated: true, completion: {
			})
		}
		
    }
    
    //MARK: - DFUProgressDelegate
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        progressView.setProgress(Float(progress) / 100.0,animated:true)
        processLab.text = String("\(progress)% (\(part)/\(totalParts))")
    }
    
    func logWith(_ level: LogLevel, message: String){
        
    }



}
