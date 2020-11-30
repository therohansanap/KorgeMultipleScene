//
//  ViewController.swift
//  MultipleSceneExample
//
//  Created by Rohan on 30/11/20.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var containerView1: UIView!
  @IBOutlet weak var containerView2: UIView!
  
  let korgeVC1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "korgeVC") as! KorgeViewController
  
  let korgeVC2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "korgeVC") as! KorgeViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    containerView1.addSubview(korgeVC1.view)

    korgeVC1.view.translatesAutoresizingMaskIntoConstraints = false
    korgeVC1.view.topAnchor.constraint(equalTo: containerView1.topAnchor).isActive = true
    korgeVC1.view.bottomAnchor.constraint(equalTo: containerView1.bottomAnchor).isActive = true
    korgeVC1.view.leadingAnchor.constraint(equalTo: containerView1.leadingAnchor).isActive = true
    korgeVC1.view.trailingAnchor.constraint(equalTo: containerView1.trailingAnchor).isActive = true

    addChild(korgeVC1)
    korgeVC1.didMove(toParent: self)
    
//    containerView2.addSubview(korgeVC2.view)
//    
//    korgeVC2.view.translatesAutoresizingMaskIntoConstraints = false
//    korgeVC2.view.topAnchor.constraint(equalTo: containerView2.topAnchor).isActive = true
//    korgeVC2.view.bottomAnchor.constraint(equalTo: containerView2.bottomAnchor).isActive = true
//    korgeVC2.view.leadingAnchor.constraint(equalTo: containerView2.leadingAnchor).isActive = true
//    korgeVC2.view.trailingAnchor.constraint(equalTo: containerView2.trailingAnchor).isActive = true
//
//    addChild(korgeVC2)
//    korgeVC2.didMove(toParent: self)
  }
  
  


}

