//
//  ViewReactor.swift
//  ARSummoner
//
//  Created by wantedly on 2018/09/30.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

final class ViewReactor: Reactor {
    enum Action {
        case detectPlane
        case tapPlane
    }
    
    // Actionに対する変更内容
    enum Mutation {
        
    }
    
    enum Stage {
        case detection
        case summons
        case takePhoto
    }
    
    struct State {
        var stage: Stage
        var gettedPlane: [PlaneNode]
    }
    
    let initialState: State
    
    init() {
        
    }
    
    // ActionからMutationを生成する
    func mutate(action: Action) -> Observable<Mutation> {
       
    }
    
    // MutationからStateを更新する
    func reduce(state: State, mutation: Mutation) -> State {
    }
}
