//
//  ViewController.swift
//  RealEstateApp
//
//  Created by A on 3/28/17.
//  Copyright © 2017 Alma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

import AVFoundation
import AudioToolbox


class PlanTableViewController: UITableViewController
{
    // Create a reference to the realtime firebase database
    let fbReference = FIRDatabase.database().reference()
//    let fbStorage = FIRStorage.storage()
    
    // Create a reference to the file we want to download
    let storageReference = FIRStorage.storage().reference()

    
    var jsonArray : Array<NSDictionary>?
    
    // current image downloaded
    var downloadedImage : UIImage?
    
    // current floor plan downloaded
    var globalFloorPlan : FloorPlanClass!
    
    
   
    // numberOfRows in TableView
    var rowNum = 0
    
    // array of floor plans
    var downloadedFloorPlans : Array<FloorPlanClass>?
    
    
    // array of sounds
    var soundsArray : Array<String>?
   
    
    // document directory path
    var documentsPath : String!
    
    
    
    
    // For saving purpose
    var filesPath : String!
    var objectInFilePath : String!
    var globalImagePath : String?
//    var imageData : Data?
    var deviceScale: String!
    
    // session variables
    var downloadTask: URLSessionDownloadTask!
    var session: URLSession!
    
    
    
    
    override func viewDidLoad()
    {
       
        super.viewDidLoad()
        
       self.documentsPath = self.getDocFilePath()
        
        self.deviceScale = String(Int(UIScreen.main.scale))
        
        print("device scale", deviceScale)
        
        
        self.downloadedFloorPlans = Array<FloorPlanClass>()
        
        self.tableView.register(CellViewController.self, forCellReuseIdentifier: "PlanCell")

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        
        
        
        
        
        
        
        
        
        
        
//        self.filesPath = self.documentsPath.appending("/Files")
//
//        self.session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
//        self.progressView.setProgress(0.0, animated: false)
//        
       
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.downloadedFloorPlans = self.loadData()

    }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        var count = Int()
        let floorPlanParent = fbReference.child("imagesets")
        floorPlanParent.observe(.value, with:{ (snapshot: FIRDataSnapshot!) in
            count = Int(snapshot.childrenCount)
            self.rowNum = count
            self.tableView.reloadData()
            print("number of children:", count)
            
        })
        
    }
    
    
    
    // UITabelViewDatasource actions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        print("row count -->", self.rowNum)
        return self.rowNum
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var cell = CellViewController()
        cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as! CellViewController
        let index = indexPath.row + 1
        cell.setCell(planId: index)
//        cell.downloadBtn?.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let index = indexPath.row + 1
        self.downloadBtnTapped(index: index)
    }
    
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        
        let index = indexPath.row + 1
        for plan in self.downloadedFloorPlans!
        {
            if plan.planId == index
            {
                // floor plan found downloaded
                self.globalFloorPlan = plan
                performSegue(withIdentifier: "ImageView", sender: self.view)
                
            }
            else
            {
                // make an alert to tell user that he has to download the plan first
                print("You need to download the plan")
                
            }
        }

    }
    
    
    
    // Runs in viewWillAppear
    func loadData() -> Array<FloorPlanClass>
    {
        // Load the data from file
        
        let filePath = self.getDocFilePath()
        print("filePath:", filePath)
        var savedFloorPlans = Array<FloorPlanClass>()
        
        
        var directory: ObjCBool = ObjCBool(false)
        let exists: Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &directory)
        
        if exists {
            // Exists. Directory.
            print("directory exists")
            
            
            do
            {
                // Extract file
                
                let fileContents = try String(contentsOfFile: filePath)
                let contentArray = fileContents.components(separatedBy: "\n")
                
                for content in contentArray
                {
                    let  planContent = content.components(separatedBy: "#")
                    let plan : FloorPlanClass
                    
                    if planContent.count == 5
                    {
                        // Get plan id from saved data
                        let planId = planContent[0]
                        print(planId)
                        var coords = [String: String]()

                        // Get plan coords from saved data
                        let planCoordsStr = planContent[1]
                        let coordSetArr = planCoordsStr.components(separatedBy: ";")
                        for coordSet in coordSetArr
                        {
                            if coordSet != coordSetArr.last!
                            {
                                let roomCoordsArr = coordSet.components(separatedBy: "=")
                                coords[roomCoordsArr[0]] = roomCoordsArr[1]
                            }
                            
                        }
                        print("coords:", coords)

                        // Set the initial plan using init method of the FloorPlanClass
                        plan = FloorPlanClass.init(id: Int(planId)!, coordinates: coords)
                        
                        
                        // Get plan image from saved data
//                        let imageURLStr = planContent[2]
//                        plan.planImageURL = URL(string: imageURLStr)!
                        plan.planImageURL = planContent[2]
                        print("IMAGE URL STR: ",plan.planImageURL) // FileURL --> StringFromFileURl
                        

                        // Get plan sounds from saved data
//                        var sounds = [String:URL]()
                        var sounds = [String:String]()
                        let soundsArr = planContent[3].components(separatedBy: ";")
                        for soundSetStr in soundsArr
                        {
                            if soundSetStr != soundsArr.last!
                            {
                                let soundComponentArr = soundSetStr.components(separatedBy: "=")
//                                sounds[soundComponentArr[0]] = URL(string: soundComponentArr[1])!
                                sounds[soundComponentArr[0]] = soundComponentArr[1]
                            }
                        }
//                        plan.roomSoundsURL = sounds
                        plan.roomSound = sounds
                        print(plan.roomSound!)

                        
                        // Get plan pin data from saved data
                        var pins = [String:String]()
                        let pinsArr = planContent[4].components(separatedBy: ";")
                        for pinSetStr in pinsArr
                        {
                            if pinSetStr != pinsArr.last!
                            {
                                let pinComponentsArr = pinSetStr.components(separatedBy: "=")
                                pins[pinComponentsArr[0]] = pinComponentsArr[1]

                            }
                        }
                        plan.pinsData = pins
                        print(plan.pinsData!)
                        
                        savedFloorPlans.append(plan)
                    }
                    
                    
                }
            }
            catch
            {
                print(error)
                
            }

            
        } else if exists {
            // Exists.
            print("Cannot find the file for saved data")
        }
        
        return savedFloorPlans
        
        
    }

    
    
    
    
    
    
    
    
    
    

    // Add the new downloaded plan to the array
    func addPlan(notification: NSNotification)
    {
        print("IN NOTIFICATION : ADD PLAN")
        let planInstance = notification.userInfo?["floorPlan"] as! FloorPlanClass
        if planInstance.planImageURL != nil && planInstance.roomSound!.count > 1 && planInstance.finishedDownloading == true
        {
            if self.downloadedFloorPlans!.count >= 1
            {
                for plan in self.downloadedFloorPlans!
                {
                    if plan.planId != planInstance.planId
                    {
                        self.downloadedFloorPlans?.append(planInstance)
                        saveDataString()
                        
                        print("new floor plan added. Array count: ", self.downloadedFloorPlans!.count)
                        
                    }
                }
                
            }
            else{
                self.downloadedFloorPlans?.append(planInstance)
                saveDataString()
                
                print("new floor plan added. Array count: ", self.downloadedFloorPlans!.count)
                
            }
            
            
            
        }
        
    }
    
    
    
    // PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//        var newFloorPlan : FloorPlanClass!
//
        if segue.identifier == "ImageView"
        {
            let imageController = segue.destination as! ImageViewController
//            let defaultImage = UIImage(named: "house.jpg")
//            print("image data -- >", self.downloadedImage!)
//            imageController.imageView = UIImageView(image: self.downloadedImage!)
//            imageController.image = UIImage(data: self.globalFloorPlan.planImageData!)
            imageController.floorPlanClassInstance = self.globalFloorPlan
            
        }
    }
    
    
    
    func getDocFilePath() -> String
    {
        self.documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = self.documentsPath.appending("/data.txt")
        return filePath
        
    }
    
    
    func saveDataString()
    {
        let filePath = self.getDocFilePath()
        print("filePath:", filePath)
        
        var saveString = ""
        
        // First clear the previous data saved into the .txt file
        do
        {
            let fileContents = try String(contentsOfFile: filePath)
            try fileContents.write(toFile: filePath, atomically: true, encoding: .utf8)
            //            try saveString.write(toFile: "\(textFileURL)", atomically: true, encoding: .utf8)
            print("File is clear")
        }
        catch
        {
            print(error)
        }
        
        print("Save String",saveString)
        

        for plan in self.downloadedFloorPlans!
        {
            let id = "\(plan.planId)"
            print(plan.planId)  // Int #
            
            let coords = plan.planCoords
            var coordsInStr = String()
            
            for item in coords
            {
                let indexOfItem = coords.index(forKey: item.key)
                let lastIndex = coords.endIndex
                
                if indexOfItem! == lastIndex {
                    // this is the last item in coords
                    print("item key: ", item.key)
                    print("is last item")
                    coordsInStr += "\(item.key)=\(item.value)"
                }
                else{
                    coordsInStr += "\(item.key)=\(item.value);"
                }
                
            }
            print("COORDSINSTR: ",coordsInStr)  // Dictionary[String:String] --> planCoords[key]=String  ==> String=String, String=String, ... #

            
            

//            let imageURLStr = "\(plan.planImageURL!)"
            let imageURLStr = plan.planImageURL!
            print("IMAGE URL STR: ",plan.planImageURL) // FileURL --> StringFromFileURl
//            print("IMAGE URL STR: ",plan.planImageURL!) // FileURL --> StringFromFileURl
            
            
            
            
//            let sounds = plan.roomSoundsURL!
            let sounds = plan.roomSound!
            var soundsInStr = String()
            for item in sounds
            {
                let indexOfItem = sounds.index(forKey: item.key)
                let lastIndex = sounds.endIndex
                if indexOfItem == lastIndex {
                    // this is the last item in coords
                    soundsInStr += "\(item.key)=\(item.value)"
                }
                else{
                    soundsInStr += "\(item.key)=\(item.value);"
                }
                
            }
            print("SOUNDSINSTR: ",soundsInStr) // Dictionary[String:URL] --> rooSoundURL[key]=URL(FileURL --> StringFromFileURl)  ==> String=String, String=String, ...
            
            
            
            let pins = plan.pinsData!
            var pinsInStr = String()
            for item in pins
            {
                let indexOfItem = pins.index(forKey: item.key)
                let lastIndex = pins.endIndex
                
                if indexOfItem == lastIndex {
                    // this is the last item in coords
                    pinsInStr += "\(item.key)=\(item.value)"
                }
                else{
                    pinsInStr += "\(item.key)=\(item.value);"
                }
                
            }

            

            print("PINSINSTR: ",pinsInStr) // [String:String] ==> "key"= "x:\(roomX!),y:\(roomY!)"

            
//            let planCoordsString = "living:\(plan.planCoords[value(forKey: "living")!])"
            saveString = "\(saveString)\(id)#\(coordsInStr)#\(imageURLStr)#\(soundsInStr)#\(pinsInStr)\n"
        }
        
        do
        {
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
//            try saveString.write(toFile: "\(textFileURL)", atomically: true, encoding: .utf8)
            print("Saved TO File")
        }
        catch
        {
            print(error)
        }
        
        print("Save String",saveString)
        
    }
    

    
    
    
  
    
    

    
    
    func downloadBtnTapped(index: Int)
    {
        
        
        var newFloorPlan : FloorPlanClass?
        
        let indexString = String(index)
        let newChild = fbReference.child("imagesets").child(indexString)
        var floorId = Int()
        
        newChild.child("id").observeSingleEvent(of: .value, with:
            {(snapshot) in
                // Get imageId value
                floorId = snapshot.value as! Int
            })
            
            
        newChild.child("coordinates").observeSingleEvent(of: .value, with:
            { (snapshot) in
                    
                    // Get floorPlan details in dictionaries
                let value = snapshot.value as? NSDictionary
                let bathDic = value?["bath"] as? NSDictionary
                let bathCoordStr = bathDic?["\(self.deviceScale!)x"] as! String
                
                let livingDic = value?["living"] as? NSDictionary
                let livingCoordStr = livingDic?["\(self.deviceScale!)x"] as! String
                
                
//                let group = DispatchGroup()
//                group.enter()
                
                print("id:", floorId)
                
                
                newFloorPlan = FloorPlanClass.init(id: floorId, coordinates: ["bath": bathCoordStr, "living": livingCoordStr])
                
//                DispatchQueue.main.async {
                     newFloorPlan = self.downloadPlanData(floorPlan: newFloorPlan!, imagePath: self.documentsPath!)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.addPlan), name: NSNotification.Name(rawValue: "finished"), object: nil)
                

//                    group.leave()
//                }
               
//                group.notify(queue: DispatchQueue.main, execute:{
//                    
//                    print("%%%%%%%%%%%%%%%%",(newFloorPlan?.roomSoundData)!, (newFloorPlan?.planImageData)!,(newFloorPlan?.pinsData)!)
                
                
//                })
                
                
            })
            {(error) in
                print(error.localizedDescription)
            }
        
       
        
        
    }
    
    
    

    
    func  downloadPlanData(floorPlan : FloorPlanClass, imagePath : String) -> FloorPlanClass
    {
        // Start the download task and save the returned image to the global downloadedImage
        
        floorPlan.setRoomSoundData(floorId: floorPlan.planId, coordinates: floorPlan.planCoords, soundStorage: self.storageReference)

        
        
        floorPlan.setImageData(floorId: floorPlan.planId, coordinates: floorPlan.planCoords, imageType:"2x" , imageStorage: self.storageReference)
        
        floorPlan.setPinsData(floorId: floorPlan.planId, coordinates: floorPlan.planCoords, floorType: "2x")
        
        
        return floorPlan
        
       
        
        
    }
    
    
    
    
    
    
    
    
}

