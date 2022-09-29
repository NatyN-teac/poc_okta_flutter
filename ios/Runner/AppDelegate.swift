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
              self?.signIn(username: argment["email"]!, password: argment["password"]!, completion: { resul in
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
                 }
             })
//              self?.fetchLimit = call.arguments as! Int
//              self?.flutterResult = result
//              self?.getPhotos()
//          case "fetchImage":
//              self?.fetchImage(args: call.arguments as? Dictionary<String, Any>, result: result)
          default:
              result(FlutterMethodNotImplemented)
          }
      })
      
      
    
  
      
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func signIn(username: String, password: String,completion: @escaping (Result<Token, InteractionCodeFlowError>) -> Void){
        let flow =  InteractionCodeFlow(
            issuer: URL(string: "https://dev-08901952.okta.com/oauth2/default")!,
            clientId: "0oa6n8dw1yIMgQ5RE5d7",
            scopes: "openid profile offline_access",
            redirectUri: URL(string: "com.embeddedauth://callback")!)
          flow.start { result in
            switch result {
            case .success(let response):
                print("response : \(response)")
                guard let remediation = response.remediations[.identify],
                      let usernameField = remediation["identifier"],
                      let passwordField = remediation["credentials.passcode"]
                else{
                    return
                }
                usernameField.value = username
                passwordField.value = password
                 return remediation.proceed(completion: {res in
                    switch res {
                    case .success(let rsp):
                        guard rsp.isLoginSuccessful else {return}
                        rsp.exchangeCode(){ tokn in
                            completion(tokn)
                        }
                    case .failure(let error):
                        print("error happened during trying to implement")
                    }
                    
                } )
            case .failure(let error):
                print("Error : \(error)")
            }
        }
    }
    
}
