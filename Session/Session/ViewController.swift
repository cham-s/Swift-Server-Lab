//
//  ViewController.swift
//  Session
//
//  Created by chams on 23/12/2018.
//  Copyright © 2018 Chams. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, URLSessionDelegate, URLSessionDownloadDelegate {
    
    private lazy var urlSession = URLSession(configuration: .default,
                                             delegate: self,
                                             delegateQueue: nil)
    var downloadTask: URLSessionTask?
    var isSuspended = false
    @IBOutlet weak var progressBarIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLabel.isHidden = true
        progressBarIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    private func startDownload(url: URL) {
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        self.downloadTask = downloadTask
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.downloadTask {
            let calculateProgress = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * Float(100)
            DispatchQueue.main.async {
                self.progressLabel.isHidden = false
                self.progressBarIndicator.isHidden = false
                self.progressLabel.stringValue = "\(Float(totalBytesWritten) / 1000.0)KB/\(Float(totalBytesExpectedToWrite) / 1000.0)KB"
                self.progressBarIndicator.doubleValue = Double(calculateProgress)
            }

        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // check for and handle errors:
        // * downloadTask.response should be an HTTPResponse with status Code in 200..299
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let savedURL = documentsURL.appendingPathComponent(location.lastPathComponent)
            print(savedURL.path)
            try FileManager.default.moveItem(at: location, to: savedURL)
            
        } catch {
            // handle file system error
            print("something bad happened: \(error.localizedDescription)")
        }
    }
    
    @IBAction func startDownload(_ sender: Any) {
        guard let task = downloadTask else {
            let url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/3f/JPEG_example_flower.jpg")!
            startDownload(url: url)
            return
        }
        task.resume()
        isSuspended = false
    }
    
    @IBAction func stopDownload(_ sender: Any) {
        guard let task = downloadTask else { return }
        task.suspend()
        isSuspended = true
    }
}

