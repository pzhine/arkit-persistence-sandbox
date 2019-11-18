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
    @IBOutlet var saveButton: UIBarButtonItem!
    
    private var hud :MBProgressHUD!
    
    private var configuration :ARWorldTrackingConfiguration!
    
    private var _worldDoc :WorldDoc!
    var worldDoc :WorldDoc {
        get {
            return _worldDoc
        }
        set {
            _worldDoc = newValue
            self.storageKeyLabel.text = _worldDoc.data?.name
            if (_worldDoc.data?.worldMap != nil) {
                restoreWorldTrackingSession()
                saveButton.isEnabled = true
            }
        }
    }
    
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
    
    private func saveWorldMap() {
        
        self.sceneView.session.getCurrentWorldMap { worldMap, error in
            
            if error != nil {
                print(error?.localizedDescription as Any)
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
    
    private func startWorldTrackingSession() {
        configuration = ARWorldTrackingConfiguration()
        resetSession(configuration)
    }
    
    private func restoreWorldTrackingSession() {
        guard let data = worldDoc.data, let worldMap = worldDoc.data?.worldMap else {
            fatalError("Could not restore tracking session: Invalid or missing WorldDoc or WorldMap")
        }
        configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        resetSession(configuration)
        print("loaded worldMap: \(data.name))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        self.sceneView.session.delegate = self
        
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers()
        
        setupUI()
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        guard let hitResult = hitTestResult.first else {
            return
        }
        
        let boxAnchor = ARAnchor(name: "box-anchor", transform: hitResult.worldTransform)
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
//        print(anchor.name)
        if (anchorName == "box-anchor") {
            // add a virtual object
            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.005)
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
        
        //add constraints to labels
        self.worldMapStatusLabel.topAnchor.constraint(equalTo: self.sceneView.topAnchor, constant: 20).isActive = true
        self.worldMapStatusLabel.rightAnchor.constraint(equalTo: self.sceneView.rightAnchor, constant: -20).isActive = true
        self.worldMapStatusLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.storageKeyLabel.topAnchor.constraint(equalTo: self.sceneView.topAnchor, constant: 20).isActive = true
        self.storageKeyLabel.leftAnchor.constraint(equalTo: self.sceneView.leftAnchor, constant: 20).isActive = true
        self.storageKeyLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Map Name", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField {
            $0.placeholder = "Enter map name"
            $0.addTarget(alert, action: #selector(alert.textDidChangeInLoginAlert), for: .editingChanged)
        }

        let startAction = UIAlertAction(title: "Start Mapping", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text {
                self.worldDoc = WorldDoc(name: name)
                self.startWorldTrackingSession()
                self.saveButton.isEnabled = true
            }
            
        })
        
        startAction.isEnabled = false
        alert.addAction(startAction)

        self.present(alert, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.saveWorldMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func resetSession(_ config: ARWorldTrackingConfiguration) {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}

/* https://stackoverflow.com/questions/30596851/how-do-i-validate-textfields-in-an-uialertcontroller/39856501
 */
extension UIAlertController {

    func isValidName(_ name: String) -> Bool {
        return name.count > 0
    }

    @objc func textDidChangeInLoginAlert() {
        if let name = textFields?[0].text,
            let action = actions.last {
            action.isEnabled = isValidName(name)
        }
    }
}

