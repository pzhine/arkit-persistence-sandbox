//
//  ViewController.swift
//  WorldAsSupport
//
//  Created by Paul on 10/20/19.
//  Copyright © 2019 UPF. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var hud :MBProgressHUD!
    
    private var worldDoc :WorldDoc!
    
    static var storageKey = "box3"
    
    private lazy var worldMapStatusLabel :UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var versionLabel :UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var storageKeyLabel :UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveWorldMapButton :UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(red: 53/255, green: 73/255, blue: 94/255, alpha: 1)
        button.addTarget(self, action: #selector(saveWorldMap), for: .touchUpInside)
        return button
        
    }()
    
    static var compileDate :Date {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    static var prettyCompileDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: compileDate)
    }
    
    @objc func saveWorldMap() {
        
        self.sceneView.session.getCurrentWorldMap { worldMap, error in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            if let map = worldMap {
                
                self.worldDoc.data?.worldMap = map
                self.worldDoc.saveData()
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.label.text = "World Map Saved!"
                self.hud.hide(animated: true, afterDelay: 2.0)
            }
            
        }
    }
    
    private func restoreWorldMap() {
        let configuration = ARWorldTrackingConfiguration()
        if let data = worldDoc.data {
            configuration.initialWorldMap = data.worldMap
            print("loaded worldMap: \(data.name)")
        }
        sceneView.session.run(configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.autoenablesDefaultLighting = true 
        
        // Set the view's delegate
        sceneView.delegate = self
        self.sceneView.session.delegate = self
        
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers()
        
        setupUI()
        worldDoc = WorldDoc(name: ViewController.storageKey)
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        
        let camera = self.sceneView.session.currentFrame!.camera
        let boxAnchor = ARAnchor(name: "box-anchor", transform: camera.transform)
        self.sceneView.session.add(anchor: boxAnchor)
            
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        switch frame.worldMappingStatus {
            case .notAvailable:
                self.worldMapStatusLabel.text = "NOT AVAILABLE"
            case .limited:
                self.worldMapStatusLabel.text = "LIMITED"
            case .extending:
                self.worldMapStatusLabel.text = "EXTENDING"
            case .mapped:
                self.worldMapStatusLabel.text = "MAPPED"
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        print(anchor)
        
        guard let anchorName = anchor.name else {
            return
        }
        print(anchor.name)
        if (anchorName == "box-anchor") {
            // add a virtual object
            let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.purple
            box.materials = [material]
            let boxNode = SCNNode(geometry: box)
            node.addChildNode(boxNode)
        }
    }
    
    private func setupUI() {
        
        self.view.addSubview(self.worldMapStatusLabel)
        self.view.addSubview(self.versionLabel)
        self.view.addSubview(self.storageKeyLabel)
        self.view.addSubview(self.saveWorldMapButton)
        
        //add constraints to labels
        self.worldMapStatusLabel.topAnchor.constraint(equalTo: self.sceneView.topAnchor, constant: 20).isActive = true
        self.worldMapStatusLabel.rightAnchor.constraint(equalTo: self.sceneView.rightAnchor, constant: -20).isActive = true
        self.worldMapStatusLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.versionLabel.topAnchor.constraint(equalTo: self.sceneView.topAnchor, constant: 20).isActive = true
        self.versionLabel.leftAnchor.constraint(equalTo: self.sceneView.leftAnchor, constant: 20).isActive = true
        self.versionLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.versionLabel.text = ViewController.prettyCompileDate
        
        self.storageKeyLabel.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -20).isActive = true
        self.storageKeyLabel.leftAnchor.constraint(equalTo: self.sceneView.leftAnchor, constant: 20).isActive = true
        self.storageKeyLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.storageKeyLabel.text = ViewController.storageKey
        
        // add constraints to save world map button
        self.saveWorldMapButton.rightAnchor.constraint(equalTo: self.sceneView.rightAnchor, constant: -20).isActive = true
        self.saveWorldMapButton.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -20).isActive = true
        self.saveWorldMapButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.saveWorldMapButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restoreWorldMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
