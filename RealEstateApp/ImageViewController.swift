//
//  ImageViewController.swift
//  RealEstateApp
//
//  Created by A on 3/28/17.
//  Copyright © 2017 Alma. All rights reserved.
//

import Foundation
import UIKit

import AVFoundation
import AudioToolbox


class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate
{
    var image : UIImage!
    var floorPlanClassInstance : FloorPlanClass?
    var newImageViewComp : UIImageView!
    var documentPath = String()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
//    var tap = UITapGestureRecognizer()
    
    var player: AVAudioPlayer!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        super.viewWillAppear(true)
//        self.imageView.becomeFirstResponder()
        

        
        
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 0.9
        
        self.scrollView.delegate = self
        
        let deviceScale = String(Int(UIScreen.main.scale))
        self.documentPath = self.getDocFilePath()
        
        self.getImage()
        
    
        if self.image != nil
        {
            print("image size in new view ---> ", self.image.size)
            
            self.newImageViewComp = UIImageView(image:self.image)
            self.newImageViewComp.isUserInteractionEnabled = true
            
            if self.floorPlanClassInstance != nil
            {
//                self.newImageViewComp = floorPlanClassInstance?.dropPinAt(imageView: imageViewTemp,imageType: "2x") //coordinates: (floorPlanClassInstance?.planCoords)!
                let pinsArr = self.dropPinAt(imageView: self.newImageViewComp, imageType:deviceScale, floorPinCoords: (self.floorPlanClassInstance?.pinsData)!)
                
                self.scrollView.addSubview(self.newImageViewComp)

                
                for item in pinsArr
                {
                    self.newImageViewComp.addSubview(item)
                }
                
                

            }
            

            
        }


    }
    
    
    
    func getImage()
    {
        
        let imagePathStr = (self.floorPlanClassInstance!.planImageURL)!
        print(imagePathStr)
        let filePath = self.documentPath.appending(imagePathStr)
        
        print("comes here to gt the image: ", filePath)
        
//        if FileManager.default.fileExists(atPath:imageURLStr)
//        {
//            print("comes here to gt the image")
////
//            do
//            {
                // Extract file
//                let fileContents = try Strin
//                let url = URL(fileURLWithPath: fileContents)
//                let data = NSData(contentsOf: url) as! Data
                self.image = UIImage(contentsOfFile: filePath)!
//            }
//            catch
//            {
//                print(error)
//                
//            }
        
//        }
    }
    
    
    
    // ScrollView Delegate methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return self.newImageViewComp
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        let offsetX = max((self.scrollView.bounds.width - self.scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((self.scrollView.bounds.height - self.scrollView.contentSize.height) * 0.5, 0)
        
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
    }
    
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    
    // Drop Pins On Image
    func dropPinAt(imageView: UIImageView, imageType: String, floorPinCoords: [String: String]) -> Array<UIView> //coordinates: [String: NSDictionary],
    {
        
        
        var pinsArr = Array<UIView>()

        
        for (key, value) in floorPinCoords
        {
            let pin = UIView()
            let xyPairArr = value.components(separatedBy: ",") //"x:\(roomX!) , y:\(roomY!)"
            let pinXArr = xyPairArr[0].components(separatedBy: ":")
            let pinX = Int(pinXArr[1])!
            
            let pinYArr = xyPairArr[1].components(separatedBy: ":")
            let pinY = Int(pinYArr[1])!

            pin.frame = CGRect(x:pinX , y:pinY, width: 20, height: 20)
            pin.backgroundColor = UIColor.red
            
            // Define gesture recognizer
            let tap = MyTapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            tap.gname = key
            tap.delegate = self
            
            
            // Add tap gesture to the pin
            pin.addGestureRecognizer(tap)
            
            
            pinsArr.append(pin)
        }
    
        print("pins array: ", pinsArr.count)
        
        return pinsArr
    }

    
    
    
    
    
    func handleTap(_ sender: UITapGestureRecognizer? = nil)
    {
        // handling code
       
        let gesture = sender as? MyTapGestureRecognizer
        let key = (gesture?.gname)!
//        let soundData = (self.floorPlanClassInstance?.roomSoundsURL?[key])!
        let soundData = (self.floorPlanClassInstance?.roomSound?[key])!
        self.playSoundUsingName(audioDataPath: soundData)
        
        
        
    }
    
    
    func playSoundUsingName(audioDataPath: String)
    {
        print("pin Tapped")

        self.player = AVAudioPlayer()
        
        let audioPath = self.documentPath.appending(audioDataPath)
        let audioURL = URL(fileURLWithPath: audioPath) // Sound Couldn't find
//        let audioURL = URL(string: audioPath)!
        print("url:", audioURL)

        
        var directory: ObjCBool = ObjCBool(false)
        let exists: Bool = FileManager.default.fileExists(atPath: audioPath, isDirectory: &directory)
        if exists {
            // Exists. Directory.
            
            do
            {
                self.player = try AVAudioPlayer(contentsOf: audioURL)
                print("AVAudioPlayer Success")
                self.player.prepareToPlay()
                self.player.delegate = self
                self.player.volume = 3.0
                self.player.play()
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            } 
            catch {
                print("AVAudioPlayer init failed")
            }
            
            
            
            
            
            
//            do {
//                self.player = try AVAudioPlayer(contentsOf: audioURL)
//                if(self.player.prepareToPlay()){
//                    print("preparation success")
////                    self.player.delegate = self
//                    self.player.volume = 4.0
//                    if(self.player.play()){
//                        print("Sound play success")
//                    }else{
//                        print("Sound file could not be played")
//                    }
//                }else{
//                    print("preparation failure")
//                }
//                
//            }catch{
//                print("Sound file could not be found")
//            }

            
        } else if exists {
            // Exists.
        }
        
        
        
        
        
        
        

        
//        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")!
        
//        if FileManager.default.fileExists(atPath: "Users/ASystem/Library/Developer/CoreSimulator/Devices/2D10AB4D-1031-46EE-9AC3-5CCF213DD26C/data/Containers/Data/Application/2FAFE8DA-DD06-4F86-A898-B0074398EF75/Documents/Audio/1-living.mp3")
//        {
        
        
//        let audioPath = audioDataURL.path
//        print(audioPath)
        
//        var directory: ObjCBool = ObjCBool(false)
//        var exists: Bool = FileManager.default.fileExists(atPath: , isDirectory: <#T##UnsafeMutablePointer<ObjCBool>?#>)("…", isDirectory: &directory)
//        
//        if exists && Bool(directory) {
//            // Exists. Directory.
//        } else if exists {
//            // Exists.
//        }

        
        
        
    }
    
    
    func getDocFilePath() -> String
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath
        
    }

    
    
    
    
}
