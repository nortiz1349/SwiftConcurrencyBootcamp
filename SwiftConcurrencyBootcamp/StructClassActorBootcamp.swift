//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/28.
//

/*
 
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread safe
 - When you assign or pass reference type a new reference to original instance will be created
 
 - - - - - - - - - - - - - -
 
 STACK:
 - Stored Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast.
 - Each thread has it's own stack!
 
 HEAP:
 - Stores Reference types
 - Share across threads!
 
 - - - - - - - - - - - - - -
 
 STRUCT:
 - Based on VALUES!
 - Can be mutated
 - Stored in the Stack!
 
 CLASS:
 - Based on References (Instance)
 - Store in the Heap!
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 
 - - - - - - - - - - - - - -
 
 Structs: Data Models, Views
 Classes: ViewModels
 Actors: Shared 'Manager' and 'Data Store'
 
 
 */




import SwiftUI

actor StructClassActorBootcampDataManager {
	
	func getDataFromDatabase() {

	}
	
}

class StructClassActorBootcampViewModel: ObservableObject {
	
	@Published var title: String = ""
	
	init() {
		print("ViewModel INIT")
	}
}


struct StructClassActorBootcamp: View {
	
	@StateObject private var vm = StructClassActorBootcampViewModel()
	let isActive: Bool
	
	init(isActive: Bool) {
		self.isActive = isActive
		print("View INIT")
	}
	
    var body: some View {
        Text("Hello, World!")
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.ignoresSafeArea()
			.background(isActive ? .blue : .red)
			.task {
//				await runTest()
			}
    }
}

struct StructClassActorBootcampHomeView: View {
	
	@State private var isActive: Bool = false
	
	var body: some View {
		StructClassActorBootcamp(isActive: isActive)
			.onTapGesture {
				isActive.toggle()
			}
	}
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
		StructClassActorBootcampHomeView()
    }
}

extension StructClassActorBootcamp {
	
	private func runTest() async {
		print("Test started!")
		structTest1()
		printDivider()
		classTest1()
		printDivider()
		await actorTest1()
		
//		structTest2()
//		printDivider()
//		classTest2()
	}
	
	private func printDivider() {
		print("- - - - - - - - - - - - - - - - - - - -")
	}
	
	private func structTest1() {
		print("structTest1")
		let objectA = MyStruct(title: "Starting title!")
		print("ObjectA: ", objectA.title)
		
		print("Pass the VALUES of objectA to objectB")
		var objectB = objectA // "objectB"라는 완전히 새로운 Struct 를 생성한다.
		print("ObjectB: ", objectB.title)
		
		objectB.title = "Second title!"
		print("ObjectB title changed!")
		
		print("ObjectA: ", objectA.title)
		print("ObjectB: ", objectB.title)
	}
	
	private func classTest1() {
		print("classTest1")
		let objectA = MyClass(title: "Starting title!")
		print("ObjectA: ", objectA.title)
		
		print("Pass the REFERENCE of objectA to objectB")
		let objectB = objectA
		print("ObjectB: ", objectB.title)
		
		objectB.title = "Second title!"
		print("ObjectB title changed!")
		
		print("ObjectA: ", objectA.title)
		print("ObjectB: ", objectB.title)
	}
	
	private func actorTest1() async {
		Task {
			print("actorTest1")
			let objectA = MyActor(title: "Starting title!")
			await print("ObjectA: ", objectA.title)
			
			print("Pass the REFERENCE of objectA to objectB")
			let objectB = objectA
			await print("ObjectB: ", objectB.title)
			
//			objectB.title = "Second title!" // actor 외부에서 직접 프로퍼티를 수정할 수 없다.
			await objectB.updateTitle(newTitle: "Second title!")
			print("ObjectB title changed!")
			
			await print("ObjectA: ", objectA.title)
			await print("ObjectB: ", objectB.title)
		}
	}
}

struct MyStruct {
	var title: String
}

/// Immuable struct
struct CustomStruct {
	let title: String
	
	func updateTitle(newTitle: String) -> CustomStruct {
		CustomStruct(title: newTitle)
	}
}

/// struct 를 변경하는것을 조금 더 명시적으로 표현할 의도가 있는 경우
struct MutatingStruct {
	private(set) var title: String
	
	init(title: String) {
		self.title = title
	}
	
	mutating func updateTitle(newTitle: String) {
		title = newTitle
	}
}

extension StructClassActorBootcamp {
	private func structTest2() {
		print("structTest2")
		
		var struct1 = MyStruct(title: "Title1")
		print("Struct1", struct1.title)
		struct1.title = "Title2"
		print("Struct1", struct1.title)
		
		var struct2 = CustomStruct(title: "Title1")
		print("Struct2", struct2.title)
		struct2 = CustomStruct(title: "Title2")
		print("Struct2", struct2.title)
		
		var struct3 = CustomStruct(title: "Title1")
		print("Struct3", struct3.title)
		struct3 = struct3.updateTitle(newTitle: "Title2") // replace
		print("Struct3", struct3.title)
		
		var struct4 = MutatingStruct(title: "Title1")
		print("Struct4", struct4.title)
		struct4.updateTitle(newTitle: "Title2") // mutate
		print("Struct4", struct4.title)
	}
}

class MyClass {
	var title: String
	
	init(title: String) {
		self.title = title
	}
	
	func updateTitle(newTitle: String) {
		title = newTitle
	}
}

/// acotr 는 class 와 동일한 역할을 하는 참조타입 키워드임.
/// class 의 경우 - 멀티스레드 환경에서 heap에 있는 오브젝트에 다수의 스레드가 "동시에" 참조를 시도할 경우 문제가 발생할 수 있음.
/// 참조를 시도할때 우선순위를 지정하지 않기 때문(data race problem)
/// actor는 비동기식 키워드로 순차적으로 참조(async await) 한다.
/// 말 그대로 하나의 스레드의 작업이 끝나기를 기다린 후 다음 스레드가 작업을 하게 된다.
actor MyActor {
	var title: String
	
	init(title: String) {
		self.title = title
	}
	
	func updateTitle(newTitle: String) {
		title = newTitle
	}
}

extension StructClassActorBootcamp {
	
	private func classTest2() {
		print("classTest2")
		
		let class1 = MyClass(title: "Title1")
		print("Class1", class1.title)
		class1.title = "Title2"
		print("Class1", class1.title)
		
		let class2 = MyClass(title: "Title1")
		print("Class2", class2.title)
		class2.updateTitle(newTitle: "Title2")
		print("Class2", class2.title)
	}
	
}
