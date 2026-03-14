//
//  AccountRepository.swift
//  QuickPick
//
import Foundation
import FirebaseFirestore

class AccountRepository{
    private let db = Firestore.firestore()
    
    func createAccount(vid: String, username: String, region: String){
        db.collection("accounts").document(vid).setData([
            "vid": vid,
            "username": username,
            "region": region
        ]){ error in
            if let error = error {
                print("Error creating account: \(error.localizedDescription)")
            }else {
                print("Account created")
            }
        }
    }
    
    func getAccount(uid: String) {
           db.collection("accounts").document(uid).getDocument { snapshot, error in
               if let error = error {
                   print("Error reading account: \(error.localizedDescription)")
                   return
               }
               if let data = snapshot?.data() {
                   print("Account data: \(data)")
               }
           }
       }
    
    func updateRegion(uid: String, newRegion: String) {
            db.collection("accounts").document(uid).updateData([
                "region": newRegion
            ]) { error in
                if let error = error {
                    print("Error updating region: \(error.localizedDescription)")
                } else {
                    print("Region successfully updated")
                }
            }
        }
    
    func deleteAccount(uid: String) {
            db.collection("accounts").document(uid).delete { error in
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                } else {
                    print("Account successfully deleted")
                }
            }
        }
    
    
    
}
