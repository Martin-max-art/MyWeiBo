//
//  Bundle+Extension.swift
//  WeiBo
//
//  Created by lishaopeng on 16/12/9.
//  Copyright © 2016年 lishaopeng. All rights reserved.
//

import Foundation
extension Bundle{
    var nameSpace: String{
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
}
