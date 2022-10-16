//
//  ContentView.swift
//  unzmover
//
//  Created by Dave Meaker on 05/10/2022.
//

import SwiftUI
import Zip

struct _files: Identifiable
{
	let id = UUID()
	var name : String
	var path : String
}

var File: [_files] = []

struct ContentView: View {
	@State var isShowingZip = false;
	@State var isShowingPath = false ;
	@State var autoDelete = true ;
	@State var dest: URL = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
	
	@AppStorage("path") var path = ""
	
	
	var body: some View {
		
        VStack {
			HStack {
				Button("Select .ZIP files to extract ...") {
					isShowingZip.toggle()
					
				}
				.fileImporter(isPresented: $isShowingZip, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: { results in
					
					switch results {
					case .success(let fileurls):
						File.removeAll()
						print(fileurls.count)
						
						for fileurl in fileurls {
							print(fileurl.path)
							let f = _files(name: extractFileName(fileurl: fileurl), path: "")
							File.append(f)
							extractFile(filename: fileurl,index: File.count-1,destinationFolder: dest, delete: autoDelete)
							
							
						}
						
					case .failure(let error):
						print(error)
					}
					
				})
				Toggle("Delete zip after extraction", isOn: $autoDelete)
			}
			HStack{
				
				
				Button("Select destination path ...")
				{
					isShowingPath.toggle()
				}
				.fileImporter(isPresented: $isShowingPath, allowedContentTypes: [.folder], allowsMultipleSelection: false, onCompletion: { results in
					
					switch results {
					case .success(let fileurls):
							dest = fileurls[0]
							path = dest.path()
							
					case .failure(let error):
						print(error)
					}
					
				})
				Text(" [ "+path+" ]")
			}
			Table(File) {
				TableColumn("File", value: \.name)
				TableColumn("Path") { f  in
					Text(f.path)
				}
			}
			
			
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
			.previewDevice("iPhone 13")
	}
}

func extractFile(filename: URL, index: Int, destinationFolder: URL, delete : Bool)
{
	do
	{
		print("\r"+destinationFolder.path())
		
		File[index].path = destinationFolder.path()
		
		try Zip.unzipFile(filename, destination: destinationFolder, overwrite: true, password: "") ;
		
		if (delete) {
			try FileManager().removeItem(at: filename)
		}
		
	} catch {
		File[index].path = "Failed to unzip"
	}
}

func extractFileName(fileurl: URL) -> String
{
	let s = fileurl.path()
	let i = s.index(s.lastIndex(of: "/")!,offsetBy: 1)
	let r = s.suffix(from: i)

	return String(r)
}

func createPath(path: String)
{
	if (FileManager.default.fileExists(atPath: path)) {
		return
	}
	
	do {
		try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
	} catch {
		
	}
}
