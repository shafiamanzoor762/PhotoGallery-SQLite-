//
//  FeaturedFacesView.swift
//  photoGallery
//
//  Created by apple on 05/07/2025.
//
struct LinkViewData: Identifiable {
    let id: String
    let person1: Personn
    let person2: Personn
}

import Foundation

class FeaturedFacesViewModel : ObservableObject {
    var allLinks: [Link] = []
    
    @Published var allLinkedPersons: [LinkViewData] = []
    
    let personHandler = PersonHandler()
    
    func getLinkedPersonsCompleteDetail() -> [LinkViewData] {
            do {
                let allLinks = try personHandler.getAllLinks()
                self.allLinks  =  allLinks
                
                let resolvedLinks: [LinkViewData] = allLinks.compactMap { link in
                    guard
                        let p1 = try? personHandler.getPersonDetails(personId: link.person1Id),
                        let p2 = try? personHandler.getPersonDetails(personId: link.person2Id)
                    else { return nil }

                    return LinkViewData(id: "\(link.person1Id)-\(link.person2Id)", person1: p1, person2: p2)
                }
                
                return resolvedLinks
                
            } catch {
                print("Error fetching links: \(error)")
                return []
            }
        }
    
    func loadLinks() {
        self.allLinkedPersons = getLinkedPersonsCompleteDetail()
    }
    
    func removeLink(person1Id: Int, person2Id: Int) async -> Bool {
        do {
            return try personHandler.removeLinkIfExists(person1Id: person1Id, person2Id: person2Id)
        } catch {
            return false
        }
    }
    
    
    func removeAllLinks() async -> Bool {
        var status  = false
        for link in allLinks {
            status = await removeLink(person1Id: link.person1Id, person2Id: link.person2Id)
            if  !status {
                return status
            }
        }
        return  status
    }
}
