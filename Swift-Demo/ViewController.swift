//
//  ViewController.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/2.
//

import UIKit

import ObjectiveC.message

class ViewController: UIViewController {
    
    @objc var name :String?
    @objc var value :Array<Any>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let fun = makeIncrementer(forIncrement: 10)
//        print(fun())
//        print(fun())
//        print(fun())
        
        //
//        var customersInLine = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
//        print(customersInLine.count)
//
//        serve(customer: customersInLine.removeFirst())
//        print(customersInLine.count)
 
        
        print("异步执行结果 =  \(syncMehtod())")
        
        
        print("之后的任务")
        
//        perform(#selector(test), with: nil, afterDelay: 1)
//
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(test), object: nil)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let testVC = CameraViewController()
        navigationController?.pushViewController(testVC, animated: true)
    }
    
    func syncMehtod() -> NSInteger{
        var value = 0
        
        let group = DispatchGroup.init()
        group.enter()
        asyncMethod { (num) in
            value = num
            group.leave()
        }
        
        let result =  group.wait(timeout: .now())
        print("异步任务\(result == DispatchTimeoutResult.timedOut ? "超时" : "成功")")
        
        return value
    }
    
    
    
    
    func asyncMethod(callBack callback: @escaping (_ num: Int) -> Void) {
        DispatchQueue.global().async {
            print("异步开始")
            sleep(2)
            callback(2)
            print("异步结束")
        }
    }
    
    //@escaping 标记一个闭包为允许逃逸--不在这个方法中执行。。。
    //@autoclosure 标记为一个自动闭包
    func serve(customer customerProvider: @autoclosure () -> String) {
        print("现在要服务\(customerProvider())!")
    }
    
    
    //捕获值。。。。值捕获或址捕获由编译器决定
    func makeIncrementer(forIncrement amount: Int) -> (() -> Int) {
        var runingTotal = 0
        func incrementer() -> Int {
            runingTotal += amount
            return runingTotal
        }
        return incrementer
    }
    
    func someFunction(closure: () -> Void) {
        print("将要执行一个闭包")
        closure()
    }
    
    func test1() {
        let name = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
        
        let reversedNames = name.sorted() {$0 > $1}
        
        print(reversedNames)
        
        someFunction(closure: {
            print("1111")
        })
        
        
        let digitNames = [
            0: "Zero", 1: "One", 2: "Two", 3: "Three", 4: "Four",
            5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine"
        ]
        
        let numbers = [16, 58, 510]
        
        let strings = numbers.map { (num) -> String in
            
            var num = num
            var output = ""
            
            repeat {
                let key = num % 10
                output = digitNames[key]! + output
                num = num / 10
            } while (num > 0)
            
            return output
        }
        print(strings)
    }
    
    
    func test() {
        
        let car = Car(street: SpeedWay())
        car.run()
        
        let bus = Bus(street: Street())
        bus.run()
        
        
        getPropertyList()
    }
    
    func getIvar() {
        var count :UInt32 = 0
        
        let pList = class_copyIvarList(self.classForCoder, &count)
        
        
        for index in 0..<Int(count) {
            
            let ivar: Ivar = (pList?[index])!
            print(String(utf8String: ivar_getName(ivar)!)!)
        }

    }
    
    @objc func getPropertyList() {
        var count :UInt32 = 0
        
        let pList = class_copyPropertyList(self.classForCoder, &count)
        
        
        for index in 0..<Int(count) {
            let property: objc_property_t = (pList?[index])!
            
            print(String(utf8String: property_getName(property))!)
        }
    }
    
    @objc func testFunc() {
        print(1)
    }
    
    @objc func getMethodNames(){
        
        var count : UInt32 = 0
        let list = class_copyMethodList(object_getClass(self), &count)

        for index in 0..<count {
            let method = (list?[Int(index)])! as Method
            print(method_getName(method))
        }
        free(list)
    }

    
}

