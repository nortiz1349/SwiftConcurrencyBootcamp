//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/30.
//

import SwiftUI

//

actor CurrentUserManager {
	
	func updateDatabase(userInfo: MyClassUserInfo) {
		
	}
	
}

/// safely used in concurrent code.
struct MyUserInfo: Sendable {
	let name: String
}

// 추천하는 방법은 아님
final class MyClassUserInfo: @unchecked Sendable {
	private var name: String
	let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
	
	init(name: String) {
		self.name = name
	}
	
	func updateName(name: String) {
		queue.sync {
			self.name = name
		}
	}
}


class SendableBootcampViewModel: ObservableObject {
	
	let manager = CurrentUserManager()
	
	func updateCurrentUserInfo() async {
		let info = MyClassUserInfo(name: "info")
		await manager.updateDatabase(userInfo: info)
	}
}

struct SendableBootcamp: View {
	
	@StateObject private var vm = SendableBootcampViewModel()
	
    var body: some View {
        Text("Hello, World!")
			.task {
				
			}
    }
}

struct SandableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
