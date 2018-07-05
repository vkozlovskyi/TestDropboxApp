//
//  ViewController.swift
//  TestDropboxApp
//
//  Created by Vladimir Kozlovskyi on 7/1/18.
//  Copyright © 2018 Vladimir Kozlovskyi. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController {

  @IBOutlet private weak var requestButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let isNotAuthorized = DropboxClientsManager.authorizedClient == nil
    if isNotAuthorized {
      DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                    controller: self,
                                                    openURL: { (url: URL) -> Void in
                                                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                    })
    } else {
      userDidAuthorized()
    }
  }

  @IBAction func requestImage(_ sender: UIButton) {
    getRandomMetadata { [weak self] metadata in
      self?.getThumbnail(from: metadata) { image in
        print("thumbnail received")
      }
    }
  }

  private func getRandomMetadata(completion: @escaping (Files.Metadata) -> Void) {
    guard let client = DropboxClientsManager.authorizedClient else {
      assertionFailure()
      return
    }

    client.files.listFolder(path: "", recursive: true).response { response, error in
      let metadata = response!.entries.filter({ $0.name.isImage }).first!
      completion(metadata)
    }
  }

  private func getThumbnail(from metadata: Files.Metadata, completion: @escaping (UIImage?) -> Void) {
    guard let client = DropboxClientsManager.authorizedClient else {
      assertionFailure()
      return
    }

    client.files.getThumbnail(path: "\(metadata.pathDisplay!)", size: .w640h480, mode: .bestfit).response(completionHandler: { dataResponse, error in
      if let (_, data) = dataResponse,
         let image = UIImage(data: data) {
        completion(image)
      } else {
        completion(nil)
      }
    })
  }

  func userDidAuthorized() {
    requestButton.isEnabled = true
  }
}

private extension String {
  var isImage: Bool {
    return self.hasSuffix(".jpg")
  }
}
