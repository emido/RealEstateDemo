//
//  FloorPlanClass.swift
//  RealEstateApp
//
//  Created by A on 3/28/17.
//  Copyright © 2017 Alma. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import NotificationCenter

//import AVFoundation
//import AudioToolbox

class FloorPlanClass
{
    
    
    var planId: Int
    var planCoords: [String: String]
    
//    var planImageURL : URL!
//    var roomSoundsURL : [String: URL]?
    var planImageURL : String!
    var roomSound : [String: String]?
    var pinsData : [String: String]?
    
    var finishedDownloading : Bool!
    var documentsPath: String!
    
    init(id: Int, coordinates: [String: String])
    {
        planId = id
        planCoords = coordinates
        self.finishedDownloading = false

       
    }
    
    
    
    
    func getDocFilePath() -> String
    {
        var path = String()
        path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return path
        
    }

   
    
    func setRoomSoundData(floorId: Int ,coordinates: [String: String], soundStorage:FIRStorageReference)
    {
        
        let group = DispatchGroup()
//        self.roomSoundsURL = [String : URL]()
        self.roomSound = [String : String]()
        
        for planCoord in planCoords
        {
            
            
            group.enter()

            print("KEY **** ", planCoord.key)
            let audioName = "\(floorId)-\(planCoord.key)"
            let audioRef = soundStorage.child("FloorPlanSounds/\(floorId)/\(audioName).mp3")
            print(audioRef)
            
            
            DispatchQueue.main.async {
                
                //main code
//                audioRef.data(withMaxSize: INT64_MAX) {(data, error) in
//                    if let error = error {
//                        print("Error downloading: \(error)")
//                        return
//                    }
                
                
                // new code to test
                self.documentsPath = self.getDocFilePath()
                let filePath = self.documentsPath.appending("/Audio/\(audioName).mp3")
                let fileURL = URL.init(fileURLWithPath: filePath)
                print("filePath:", fileURL)

//                let localURL = URL(string: self.documentsPath)!
                
                let downloadTask = audioRef.write(toFile: fileURL)
                { url, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print("Error Downloading audio file: ", error)
                    } else {
                        // Local file URL for "images/island.jpg" is returned
                        
                        // roomSoundURl : [String: URL]?
//                        self.roomSoundsURL?[audioName] = url!
                        
                        self.roomSound?[audioName] = "/Audio/\(audioName).mp3"
                        
                        // let absoluteURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                        urls(for:, in: (self.roomSoundsURL?[audioName])!)[1]
                        print((self.roomSound?[audioName])!)
                        print("room sound downloaded", (self.roomSound?[audioName])!)
                    }
                   group.leave()
                }
                
                
            }
                
                
            }
                
        group.notify(queue: DispatchQueue.main, execute:{
            print("SOUND GROUP.NOTIFY")

            print(self.roomSound?.count ?? 0)
            
            if (self.planImageURL != nil)
            {
                if self.finishedDownloading == false
                {
                    self.finishedDownloading = true
                }
                print("plan image data is not nil != nil, ",self.planImageURL!)
                print("DONE Setting Sounds:", self.roomSound?.count ?? 0)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finished"), object: nil, userInfo: ["floorPlan":self])
                

            }
            
        })
    }

        
        

    
    
    func setImageData(floorId: Int ,coordinates: [String: String], imageType: String, imageStorage:FIRStorageReference)
    {
        
        let imageRef = imageStorage.child("FloorPlanImages/\(floorId)@\(imageType).jpg")
        
        let group = DispatchGroup()
        
        group.enter()

        self.documentsPath = self.getDocFilePath()
        let filePath = self.documentsPath.appending("/Images/\(imageType).jpg")
        let fileURL = URL.init(fileURLWithPath: filePath)
        print("filePath:", fileURL)
        
        
        DispatchQueue.main.async {
//            imageRef.data(withMaxSize: INT64_MAX) {(data, error) in
//                if let error = error {
//                    print("Error downloading: \(error)")
//                    return
//                }
//                
//                self.planImageData = data!
//                print(self.planImageData!)
//                group.leave()
//            }
            
            let downloadTask = imageRef.write(toFile: fileURL)
            { url, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print("Error Downloading image file: ", error)
                } else {
                    // Local file URL for "images/island.jpg" is returned
                    print("URL returned after downloading image: ", url!)
//                    self.planImageURL = url!
                    
                    self.planImageURL = "/Images/\(imageType).jpg"
                    print("room image", self.planImageURL)
                }
                group.leave()

            }
            
        }
        
        print("DONE Setting Image")
        
        group.notify(queue: DispatchQueue.main, execute:{
            
            print("IMAGE GROUP.NOTIFY")
            print(self.planImageURL!)
            
            if (self.roomSound?.count)! > 1
            {
                if self.finishedDownloading == false
                {
                    self.finishedDownloading = true
                }
                print("plan sound data is not nil != nil, ",self.roomSound!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finished"), object: nil, userInfo:["floorPlan":self])
            }
            
            print(self.finishedDownloading)
        })

        
    }

    
    
    
    
    func setPinsData (floorId: Int, coordinates:[String: String], floorType: String)
    {
        self.pinsData = [String: String]()
        
        for planCoord in coordinates
        {
            print("KEY **** ", planCoord.key)
            let roomCoords = planCoord.value
            let roomCoordArr = roomCoords.components(separatedBy: ",")
            let roomX = Int(roomCoordArr[0])
            let roomY = Int(roomCoordArr[1])
            
            
            let key = "\(floorId)-\(planCoord.key)"
            let value = "x:\(roomX!),y:\(roomY!)"
            self.pinsData?[key] = value
            
            print("key = ", key, " == ", (self.pinsData?[key])!)
        }

        
    }
    
    
    
    
    
    
    
    
    
    
    }
