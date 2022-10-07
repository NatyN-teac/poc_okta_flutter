import UIKit
import Flutter
import OktaIdx

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      let controller = (window?.rootViewController as! FlutterViewController)
      let methodChannel =
          FlutterMethodChannel(name: "com.okta_poc", binaryMessenger: controller.binaryMessenger)
      
      methodChannel
          .setMethodCallHandler({ [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method {
              
          case "signin":
              let arg = call.arguments as? Dictionary<String,String>
              guard let argment = arg else {return }

              let argumentDict = ["issuer": arg?["issuer"] ?? "","clientId": arg?["clientId"] ?? "","redirectUri": arg?["redirectUri"] ?? ""]
              
              self?.signIn(username: argment["email"]!, password: argment["password"]!, startingData: argumentDict,completion: { resul in
                 switch resul {
                 case .success(let token):
                     let finalResult: String = """
                        {
                         "accessToken": "\(token.accessToken)",
                         "id": "\(token.id)",
                        "idToken":"\(token.idToken != nil ? token.idToken!.rawValue: "")",
                        "tokenType": "\(token.tokenType)",
                        "isRefreshing":\(token.isRefreshing),
                        "isValid": \(token.isValid),
                        "isExpired":\(token.isExpired),
                        "refreshToken":"\(token.refreshToken != nil ? token.refreshToken! : "")",
                        "deviceSecret":"\(token.deviceSecret != nil ? token.deviceSecret! : "")",
                        "authorizationHeader":"\(token.authorizationHeader != nil ? token.authorizationHeader! : "")"
                        }
                        """
                     result(finalResult)
                 case .failure(let error):
                     print("final error: \(error)")
                     result(FlutterMethodNotImplemented)
                 }
             })
          default:
              result(FlutterMethodNotImplemented)
          }
      })
      
      
    
  
      
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func signIn(username: String, password: String,startingData: Dictionary<String, String>, completion: @escaping (Result<Token, InteractionCodeFlowError>) -> Void){
        let flow =  InteractionCodeFlow(
            issuer: URL(string: startingData["issuer"]!)!,
            clientId: startingData["clientId"]! ,
            scopes: "openid profile offline_access",
            redirectUri: URL(string: startingData["redirectUri"]!)!)
        
          flow.start { result in
            switch result {
            case .success(let response):
                
                response.cancel { re in
                    switch re {
                    case .success(let myCancelResponse):
                        print("result is done: \(myCancelResponse.isLoginSuccessful)")
                        
                        print("response : \(response.isLoginSuccessful)")
                        if let remediation = myCancelResponse.remediations[.identify]{
                                remediation["identifier"]?.value = username
                                remediation["credentials.passcode"]?.value = password
                            
                            return remediation.proceed(completion: {res in
                               switch res {
                               case .success(let rsp):
                                   guard rsp.isLoginSuccessful else {return}
                                   rsp.exchangeCode(){ tokn in
                                       completion(tokn)
                                   }
                               case .failure(let error):
                                   print("error happened during trying to implement \(error)")
                               }
                               
                           } )
                            
                    }
                    case .failure(let err):
                        print("error is \(err)")
                    }
                }
                
                print("response : \(response.isLoginSuccessful)")
                
//              else{
//                      print("identifier : what happened, \(response.remediations["identifier"]) and \(response.remediations["credentials.passcode"])")
////                      print("passcode : \(remediation["credentials.passcode"])")
//
//                    return
//                }
//                print("result after guard : \(remediation)")
//                usernameField.value = username
//                passwordField.value = password
                
            case .failure(let error):
                print("Error : \(error)")
            }
        }
    }
    
}
