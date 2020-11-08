//
//  FactoryRequest.swift
//  JJGuiso
//
//  Created by Juan J LF on 11/5/20.
//

import Foundation


class FactoryRequest : Factory<GuisoRequest> {
    
    override func create() -> GuisoRequest? {
        return GuisoRequest()
    }
}
