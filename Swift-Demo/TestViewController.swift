//
//  TestViewController.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import MobileCoreServices

class TestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var timer:Timer?
    lazy var imagePicker = { () -> UIImagePickerController in
        let picker = UIImagePickerController.init()
        picker.sourceType = .camera
        picker.delegate = self
//        picker.cameraCaptureMode = .video
        picker.cameraDevice = .rear
        picker.mediaTypes = [kUTTypeMovie as String]
        // UI setup
        picker.view.frame = view.bounds
        picker.allowsEditing = false
        picker.showsCameraControls = false
        picker.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return picker
    }()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        title = "TestView"
        // Do any additional setup after loading the view.
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in
//            print("1234567890")
//        })
        
        let enterBack = NotificationCenter.default.rx.notification(Notification.Name.NSExtensionHostDidEnterBackground).takeUntil(rx.deallocated).subscribe { [weak self ](notification) in
            
            self?.imagePicker.dismiss(animated: true) {
                print("关闭摄像头")
            }

        }
        disposeBag.insert(enterBack)
        
        addChild(imagePicker)
        view.addSubview(imagePicker.view)
        imagePicker.view.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        timer?.invalidate()
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            print("关闭摄像头")
        }
    }
    
    @objc func timerSelector() -> Void {
        print([Date.init()])
    }
    
    deinit {
        timer?.invalidate()
        print("deinit")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

