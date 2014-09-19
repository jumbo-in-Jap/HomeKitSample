//
//  ViewController.swift
//  homekit
//
//  Created by 羽田 健太郎 on 2014/09/18.
//  Copyright (c) 2014年 me.jumbeeee.ken. All rights reserved.
//

import UIKit

class ViewController: UIViewController,HMHomeManagerDelegate,HMAccessoryBrowserDelegate{
    var homeManager:HMHomeManager = HMHomeManager()
    var accessoryBrowser:HMAccessoryBrowser = HMAccessoryBrowser()
    var accessories = [HMAccessory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeManager.delegate = self;
        self.accessoryBrowser.delegate = self;
        self.accessoryBrowser.startSearchingForNewAccessories()
        
        //self.destroyAllHome()
    }
    
    
    /*
    一度追加した名前は使えない、どんどんアプリケーション内に保存されていく
    https://developer.apple.com/library/ios/documentation/HomeKit/Reference/HomeKit_Constants/index.html#//apple_ref/c/tdef/HMErrorCode
    Failed to build home Error Domain=HMErrorDomain Code=32 "The operation couldn’t be completed. (HMErrorDomain error 32.)"
    32 - HomeWithSimilarNameExists
    */
    func buildHome()
    {
        // make home
        self.homeManager.addHomeWithName("myHome",
            completionHandler: { (home:HMHome!,err:NSError!)->Void in
                if((err) != nil)
                {
                    println("Failed to build home \(err)")
                }else{
                    self.buildRoom()
                }
            }
        )
    }
    
    func buildRoom()
    {
        var myhome:HMHome = self.homeManager.homes[0] as HMHome
        myhome.addRoomWithName("myRoom",
            completionHandler: { (home:HMRoom!,err:NSError!)->Void in
            if((err) != nil)
            {
                NSLog("ERROR")
            }else{
                print("success")
                }
            }
        )
    }
    
    func addAccessory()
    {
        var myhome:HMHome = self.homeManager.primaryHome
        myhome.addAccessory(self.accessories[0] as HMAccessory,
            completionHandler: {(err:NSError!) -> Void in
                if(err != nil)
                {
                    NSLog("Accesoried : %@", myhome.accessories.count)
                    var services:[HMService] = myhome.servicesWithTypes([HMServiceTypeLockMechanism]) as [HMService]
                    
                    var testService:HMService = services[0] as HMService
                    NSLog("Service name: %@", testService.name)
                }
        })
        
    }
    
    func destroyAllHome()
    {
        var homes:[HMHome] = self.homeManager.homes as [HMHome]
        NSLog("Now home:%d", homes.count)
        for home:HMHome in homes
        {
            self.homeManager.removeHome(home,
                completionHandler: {(err:NSError!) -> Void in
                    if(err == nil)
                    {
                        println("remove home err")
                    }
            })
        }
    }
    
    
    @IBAction func tapAction(sender:AnyObject)
    {
        //self.addAccessory()
        var myhome:HMHome = self.homeManager.primaryHome
        var myhomeAccessories:[HMAccessory] = myhome.accessories as [HMAccessory]
        // これでidentifyが変更される,時間が経つと戻る
        myhomeAccessories[0].identifyWithCompletionHandler(
            {(err:NSError!)->Void in
        
                var myhomeActions:[HMActionSet] = myhome.actionSets as [HMActionSet]
                var myhomeServices:[HMService] = myhomeAccessories[0].services as [HMService]
                
                for service:HMService in myhomeServices
                {
                    NSLog("s - %@", service.name)
                    if(service.name == "Deadbolt testAccessroy 1")
                    {
                    for characteristic:HMCharacteristic in service.characteristics as [HMCharacteristic]
                    {
                        /* metadata
                        2014-09-19 23:33:06.952 homekit[3026:357337]  c - [%@ Format: uint8, Min: 0.00, Max: 3.00, Step: 1.00 ]
                        2014-09-19 23:33:06.953 homekit[3026:357337]  c - [%@ Format: uint8, Min: 0.00, Max: 1.00, Step: 1.00 ]
                        */
                        characteristic.writeValue(1.0,
                            completionHandler:
                            {(err:NSError!)->Void in
                                if(err != nil)
                                {
                                    
                                }
                        })
                        NSLog(" c - %@", characteristic.metadata)
                    }
                    }
                }
        
        })
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // - homekit manager browser delegate
    func homeManager(manager: HMHomeManager!, didAddHome home: HMHome!)
    {
        println("didadd")
    }
    
    func homeManager(manager: HMHomeManager!, didRemoveHome home: HMHome!)
    {
        println("remove")
    }
    
    // homeeは10件まで
    // アプリケーション内のhomeが装填される
    func homeManagerDidUpdateHomes(manager: HMHomeManager!)
    {
        println("update")
        NSLog("Primary home is %@", manager.primaryHome.name)
        //self.destroyAllHome()
    }
    
    func homeManagerDidUpdatePrimaryHome(manager: HMHomeManager!)
    {
        println("updatePri")
    }
    
    // - accessory browser delegate
    func accessoryBrowser(browser: HMAccessoryBrowser!, didFindNewAccessory accessory: HMAccessory!)
    {
        
        /*
        NSLog("%@", accessory.identifier)
        NSLog("%@", accessory.reachable)
        NSLog("%@", accessory.bridged)
        NSLog("%@", accessory.blocked)
        NSLog("%@", accessory.identifier)
        NSLog("%@", accessory.services)
        */
        
        if !contains(self.accessories, accessory)
        {
            self.accessories.append(accessory)
            NSLog("Add Accessory %@", accessory.name)
        }
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser!, didRemoveNewAccessory accessory: HMAccessory!)
    {
        
    }
    
    
}

