//
//  AsyncLetBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Nortiz M1 on 2022/10/27.
//

import SwiftUI

struct AsyncLetBootcamp: View {
	
	@State private var image: [UIImage] = []
	let columns = [GridItem(.flexible()), GridItem(.flexible())]
	let url = URL(string: "https://picsum.photos/1000")!
	
    var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: columns) {
					ForEach(image, id: \.self) { image in
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
							.frame(height: 150)
					}
				}
			}
			.navigationTitle("Async Let 🥳")
			.onAppear {
				Task {
					do {
						async let fetchImage1 = fetchImage()
						async let fetchImage2 = fetchImage()
						async let fetchImage3 = fetchImage()
						async let fetchImage4 = fetchImage()
						
						/// 다수의 비동기 함수가 모두 실행되어 결과를 얻기까지 기다린다.
						/// 여러 함수의 결과값을 얻기까지 기다린 후 한번에 얻을 수 있는 장점이 있다.
						/// 다만 함수의 수가 많거나, 개별적으로 취소&우선순위를 정할 수 없다는 단점이 있다.
						let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
						image.append(contentsOf: [image1, image2, image3, image4])
						
						/// 순차적으로 실행되며 함수의 결과를 얻고 난 후, 다음 함수가 실행되므로
						/// 아래 경우의 사진은 1,2,3,4 순서로 하나씩 보여지게 된다.
						/*
						let image1 = try await fetchImage()
						self.image.append(image1)
						
						let image2 = try await fetchImage()
						self.image.append(image2)
						
						let image3 = try await fetchImage()
						self.image.append(image3)
						
						let image4 = try await fetchImage()
						self.image.append(image4)
						*/
					} catch {
						
					}
				}
			}
		}
    }
	
	func fetchImage() async throws -> UIImage {
		
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			if let image = UIImage(data: data) {
				return image
			} else {
				throw URLError(.badServerResponse)
			}
		} catch {
			throw error
		}
		
		
		
	}
}

struct AsyncLetBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootcamp()
    }
}
