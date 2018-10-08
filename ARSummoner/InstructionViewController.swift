//
//  InstructionViewController.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/10/08.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        if ud.bool(forKey: "notFirstOpne") {
            super.viewDidAppear(animated)
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "ARVC")
            present(nextView, animated: true, completion: nil)
        }
        else {
            view.isHidden = false
            ud.set(true, forKey: "notFirstOpne")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
