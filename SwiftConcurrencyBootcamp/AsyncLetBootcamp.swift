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
			.navigationTitle("Async Let π₯³")
			.onAppear {
				Task {
					do {
						async let fetchImage1 = fetchImage()
						async let fetchImage2 = fetchImage()
						async let fetchImage3 = fetchImage()
						async let fetchImage4 = fetchImage()
						
						/// λ€μμ λΉλκΈ° ν¨μκ° λͺ¨λ μ€νλμ΄ κ²°κ³Όλ₯Ό μ»κΈ°κΉμ§ κΈ°λ€λ¦°λ€.
						/// μ¬λ¬ ν¨μμ κ²°κ³Όκ°μ μ»κΈ°κΉμ§ κΈ°λ€λ¦° ν νλ²μ μ»μ μ μλ μ₯μ μ΄ μλ€.
						/// λ€λ§ ν¨μμ μκ° λ§κ±°λ, κ°λ³μ μΌλ‘ μ·¨μ&μ°μ μμλ₯Ό μ ν  μ μλ€λ λ¨μ μ΄ μλ€.
						let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
						image.append(contentsOf: [image1, image2, image3, image4])
						
						/// μμ°¨μ μΌλ‘ μ€νλλ©° ν¨μμ κ²°κ³Όλ₯Ό μ»κ³  λ ν, λ€μ ν¨μκ° μ€νλλ―λ‘
						/// μλ κ²½μ°μ μ¬μ§μ 1,2,3,4 μμλ‘ νλμ© λ³΄μ¬μ§κ² λλ€.
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
