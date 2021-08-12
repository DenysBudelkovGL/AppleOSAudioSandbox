//
//  ViewController.swift
//  AudioTest
//
//  Created by Denys Budelkov on 03.08.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var startButtons: [UIButton]!
    @IBOutlet weak var stopButton: UIButton!
    
    let sb: AudioSandbox? = AudioSandbox()
    
    var audioService: AudioEngineService? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    ///
    
    func startTestService(_ service: AudioEngineService) {
        stopButton.isEnabled = true;
        startButtons.forEach { $0.isEnabled = false; }
        
        //DispatchQueue.main.async {
        audioService = service
        service.start()
        //}
    }

    @IBAction func testCoreAudioPressed(_ sender: Any) {
        let alert = UIAlertController(title: "TODO:", message: "TODO:", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func testAVAudioEnginePressed(_ sender: Any) {
        let service = AVAudioEngineService()
        startTestService(service)
    }
    
    @IBAction func testCancelPressed(_ sender: Any) {
        stopButton.isEnabled = false;
        startButtons.forEach { $0.isEnabled = true; }
        audioService?.stop()
    }
    
}

