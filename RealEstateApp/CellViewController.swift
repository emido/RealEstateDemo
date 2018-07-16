//
//  CellViewController.swift
//  RealEstateApp
//
//  Created by A on 4/4/17.
//  Copyright © 2017 Alma. All rights reserved.
//

import Foundation
import UIKit

class CellViewController : UITableViewCell
{

    var cellLabel: UILabel?
    var cellBtn: UIButton?
    var spinner:UIActivityIndicatorView?
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    func setCell(planId: Int)
    {
        self.cellLabel = UILabel(frame: CGRect(x:20, y:5, width:150, height:24))
        self.cellLabel?.text = "Floor Plan - \(planId)"
        
//        self.downloadBtn = UIButton(frame: CGRect(x: 150, y: 5, width: 40, height: 24))
//        self.cellBtn?.setTitle("Download", for: .normal)
//        self.cellBtn?.backgroundColor = .red
//        self.cellBtn?.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
//        
        
        self.contentView.addSubview(cellLabel!)
//        self.contentView.addSubview(downloadBtn!)

        
    }

    

    
}
