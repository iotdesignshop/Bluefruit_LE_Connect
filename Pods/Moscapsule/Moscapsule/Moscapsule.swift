//
//  Moscapsule.swift
//  Moscapsule
//
//  Created by flightonary on 2014/11/23.
//
//    The MIT License (MIT)
//
//    Copyright (c) 2014 tonary <jetBeaver@gmail.com>. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

public enum ReturnCode: Int {
    case success = 0
    case unacceptable_Protocol_Version = 1
    case identifier_Rejected = 2
    case broker_Unavailable = 3
    case noConnection = 4           // Added by antonio@openroad.es
    case connection_Refused = 5     // Added by antonio@openroad.es
    case unknown = 256

    public var description: String {
        switch self {
        case .success:
            return "Success"
        case .unacceptable_Protocol_Version:
            return "Unacceptable_Protocol_Version"
        case .identifier_Rejected:
            return "Identifier_Rejected"
        case .broker_Unavailable:
            return "Broker_Unavailable"
        case .noConnection:         // Added by antonio@openroad.es
            return "Connection Refused. Bad username or password"
        case .connection_Refused:   // Added by antonio@openroad.es
            return "Connection Refused. Not Authorized"
        case .unknown:
            return "Unknown"
        }
    }
}

public enum ReasonCode: Int {
    case disconnect_Requested = 0
    case unexpected = 1

    public var description: String {
        switch self {
        case .disconnect_Requested:
            return "Disconnect_Requested"
        case .unexpected:
            return "Unexpected"
        }
    }
}

public enum MosqResult: Int {
    case mosq_CONN_PENDING = -1
    case mosq_SUCCESS = 0
    case mosq_NOMEM = 1
    case mosq_PROTOCOL = 2
    case mosq_INVAL = 3
    case mosq_NO_CONN = 4
    case mosq_CONN_REFUSED = 5
    case mosq_NOT_FOUND = 6
    case mosq_CONN_LOST = 7
    case mosq_TLS = 8
    case mosq_PAYLOAD_SIZE = 9
    case mosq_NOT_SUPPORTED = 10
    case mosq_AUTH = 11
    case mosq_ACL_DENIED = 12
    case mosq_UNKNOWN = 13
    case mosq_ERRNO = 14
    case mosq_EAI = 15
}

public struct Qos {
    public static let At_Most_Once: Int32  = 0  // Fire and Forget, i.e. <=1
    public static let At_Least_Once: Int32 = 1  // Acknowledged delivery, i.e. >=1
    public static let Exactly_Once: Int32  = 2  // Assured delivery, i.e. =1
}

public func moscapsule_init() {
    mosquitto_lib_init()
}

public func moscapsule_cleanup() {
    mosquitto_lib_cleanup()
}

public struct MQTTReconnOpts {
    public let reconnect_delay_s: UInt32
    public let reconnect_delay_max_s: UInt32
    public let reconnect_exponential_backoff: Bool
    
    public init() {
        self.reconnect_delay_s = 5 //5sec
        self.reconnect_delay_max_s = 60 * 30 //30min
        self.reconnect_exponential_backoff = true
    }
    
    public init(reconnect_delay_s: UInt32, reconnect_delay_max_s: UInt32, reconnect_exponential_backoff: Bool) {
        self.reconnect_delay_s = reconnect_delay_s
        self.reconnect_delay_max_s = reconnect_delay_max_s
        self.reconnect_exponential_backoff = reconnect_exponential_backoff
    }
}

public struct MQTTWillOpts {
    public let topic: String
    public let payload: Data
    public let qos: Int32
    public let retain: Bool
    
    public init(topic: String, payload: Data, qos: Int32, retain: Bool) {
        self.topic = topic
        self.payload = payload
        self.qos = qos
        self.retain = retain
    }

    public init(topic: String, payload: String, qos: Int32, retain: Bool) {
        let rawPayload = payload.data(using: String.Encoding.utf8)!
        self.init(topic: topic, payload: rawPayload, qos: qos, retain: retain)
    }
}

public struct MQTTAuthOpts {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct MQTTPublishOpts {
    public let max_inflight_messages: UInt32
    public let message_retry: UInt32
    
    public init(max_inflight_messages: UInt32, message_retry: UInt32) {
        self.max_inflight_messages = max_inflight_messages
        self.message_retry = message_retry
    }
}

public struct MQTTServerCert {
    public let cafile: String?
    public let capath: String?
    
    public init(cafile: String?, capath: String?) {
        self.cafile = cafile
        self.capath = capath
    }
}

public struct MQTTClientCert {
    public let certfile: String
    public let keyfile: String
    public let keyfile_passwd: String?
    
    public init(certfile: String, keyfile: String, keyfile_passwd: String?) {
        self.certfile = certfile
        self.keyfile = keyfile
        self.keyfile_passwd = keyfile_passwd
    }
}

public enum CertReqs: Int32 {
    case ssl_VERIFY_NONE = 0
    case ssl_VERIFY_PEER = 1
}

public struct MQTTTlsOpts {
    public let tls_insecure: Bool
    public let cert_reqs: CertReqs
    public let tls_version: String?
    public let ciphers: String?
    
    public init(tls_insecure: Bool, cert_reqs: CertReqs, tls_version: String?, ciphers: String?) {
        self.tls_insecure = tls_insecure
        self.cert_reqs = cert_reqs
        self.tls_version = tls_version
        self.ciphers = ciphers
    }
}

public struct MQTTPsk {
    public let psk: String
    public let identity: String
    public let ciphers: String?
    
    public init(psk: String, identity: String, ciphers: String?) {
        self.psk = psk
        self.identity = identity
        self.ciphers = ciphers
    }
}


open class MQTTConfig {
    open let clientId: String
    open let host: String
    open let port: Int32
    open let keepAlive: Int32
    open var cleanSession: Bool
    open var mqttReconnOpts: MQTTReconnOpts
    open var mqttWillOpts: MQTTWillOpts?
    open var mqttAuthOpts: MQTTAuthOpts?
    open var mqttPublishOpts: MQTTPublishOpts?
    open var mqttServerCert: MQTTServerCert?
    open var mqttClientCert: MQTTClientCert?
    open var mqttTlsOpts: MQTTTlsOpts?
    open var mqttPsk: MQTTPsk?

    open var onConnectCallback: ((_ returnCode: ReturnCode) -> ())!
    open var onDisconnectCallback: ((_ reasonCode: ReasonCode) -> ())!
    open var onPublishCallback: ((_ messageId: Int) -> ())!
    open var onMessageCallback: ((_ mqttMessage: MQTTMessage) -> ())!
    open var onSubscribeCallback: ((_ messageId: Int, _ grantedQos: Array<Int32>) -> ())!
    open var onUnsubscribeCallback: ((_ messageId: Int) -> ())!
    
    public init(clientId: String, host: String, port: Int32, keepAlive: Int32) {
        // MQTT client ID is restricted to 23 characters in the MQTT v3.1 spec
        self.clientId = { max in
            (clientId as NSString).length <= max ? clientId : clientId.substring(
to: //                advance(clientId.startIndex, max)
                clientId.characters.index(clientId.startIndex, offsetBy: max)
            )
        }(Int(MOSQ_MQTT_ID_MAX_LENGTH))
        self.host = host
        self.port = port
        self.keepAlive = keepAlive
        cleanSession = true
        mqttReconnOpts = MQTTReconnOpts()
    }
}

//@objc(__MosquittoContext)

public final class __MosquittoContext : NSObject {
    public var mosquittoHandler: OpaquePointer? = nil
    public var isConnected: Bool = false
    public var onConnectCallback: ((_ returnCode: Int) -> ())!
    public var onDisconnectCallback: ((_ reasonCode: Int) -> ())!
    public var onPublishCallback: ((_ messageId: Int) -> ())!
    public var onMessageCallback: ((_ message: UnsafePointer<mosquitto_message>) -> ())!
    public var onSubscribeCallback: ((_ messageId: Int, _ qosCount: Int, _ grantedQos: UnsafePointer<Int32>) -> ())!
    public var onUnsubscribeCallback: ((_ messageId: Int) -> ())!
    public var keyfile_passwd: String = ""
    internal override init(){}
}

public final class MQTTMessage {
    public let messageId: Int
    public let topic: String
    public let payload: Data
    public let qos: Int32
    public let retain: Bool

    public var payloadString: String? {
        return NSString(data: payload, encoding: String.Encoding.utf8.rawValue) as? String
    }

    internal init(messageId: Int, topic: String, payload: Data, qos: Int32, retain: Bool) {
        self.messageId = messageId
        self.topic = topic
        self.payload = payload
        self.qos = qos
        self.retain = retain
    }
}

public final class MQTT {
    public class func newConnection(_ mqttConfig: MQTTConfig) -> MQTTClient {
        let mosquittoContext = __MosquittoContext()
        mosquittoContext.onConnectCallback = onConnectAdapter(mqttConfig.onConnectCallback)
        mosquittoContext.onDisconnectCallback = onDisconnectAdapter(mqttConfig.onDisconnectCallback)
        mosquittoContext.onPublishCallback = mqttConfig.onPublishCallback
        mosquittoContext.onMessageCallback = onMessageAdapter(mqttConfig.onMessageCallback)
        mosquittoContext.onSubscribeCallback = onSubscribeAdapter(mqttConfig.onSubscribeCallback)
        mosquittoContext.onUnsubscribeCallback = mqttConfig.onUnsubscribeCallback

        // setup mosquittoHandler
        mosquitto_context_setup(mqttConfig.clientId.cCharArray, mqttConfig.cleanSession, mosquittoContext)

        // set MQTT Reconnection Options
        mosquitto_reconnect_delay_set(mosquittoContext.mosquittoHandler,
                                      mqttConfig.mqttReconnOpts.reconnect_delay_s,
                                      mqttConfig.mqttReconnOpts.reconnect_delay_max_s,
                                      mqttConfig.mqttReconnOpts.reconnect_exponential_backoff)

        // set MQTT Will Options
        if let mqttWillOpts = mqttConfig.mqttWillOpts {
            mosquitto_will_set(mosquittoContext.mosquittoHandler, mqttWillOpts.topic.cCharArray,
                               Int32(mqttWillOpts.payload.count), (mqttWillOpts.payload as NSData).bytes,
                               mqttWillOpts.qos, mqttWillOpts.retain)
        }
        
        // set MQTT Authentication Options
        if let mqttAuthOpts = mqttConfig.mqttAuthOpts {
            mosquitto_username_pw_set(mosquittoContext.mosquittoHandler, mqttAuthOpts.username.cCharArray, mqttAuthOpts.password.cCharArray)
        }
        
        // set MQTT Publish Options
        if let mqttPublishOpts = mqttConfig.mqttPublishOpts {
            mosquitto_max_inflight_messages_set(mosquittoContext.mosquittoHandler, mqttPublishOpts.max_inflight_messages)
            mosquitto_message_retry_set(mosquittoContext.mosquittoHandler, mqttPublishOpts.message_retry)
        }

        // set Server/Client Certificate
        if mqttConfig.mqttServerCert != nil || mqttConfig.mqttClientCert != nil {
            let sc = mqttConfig.mqttServerCert
            let cc = mqttConfig.mqttClientCert
            mosquittoContext.keyfile_passwd = cc?.keyfile_passwd ?? ""
            mosquitto_tls_set_bridge(sc?.cafile, sc?.capath, cc?.certfile, cc?.keyfile, mosquittoContext)
        }

        // set TLS Options
        if let mqttTlsOpts = mqttConfig.mqttTlsOpts {
            mosquitto_tls_insecure_set(mosquittoContext.mosquittoHandler, mqttTlsOpts.tls_insecure)
            mosquitto_tls_opts_set_bridge(mqttTlsOpts.cert_reqs.rawValue, mqttTlsOpts.tls_version, mqttTlsOpts.ciphers, mosquittoContext)
        }

        // set PSK
        if let mqttPsk = mqttConfig.mqttPsk {
            mosquitto_tls_psk_set_bridge(mqttPsk.psk, mqttPsk.identity, mqttPsk.ciphers, mosquittoContext)
        }

        // start MQTTClient
        let mqttClient = MQTTClient(mosquittoContext: mosquittoContext)
        let host = mqttConfig.host
        let port = mqttConfig.port
        let keepAlive = mqttConfig.keepAlive
        mqttClient.serialQueue.addOperation {
            mosquitto_connect(mosquittoContext.mosquittoHandler, host.cCharArray, port, keepAlive)
            mosquitto_loop_start(mosquittoContext.mosquittoHandler)
        }
        
        return mqttClient
    }

    fileprivate class func onConnectAdapter(_ callback: ((ReturnCode) -> ())!) -> ((_ returnCode: Int) -> ())! {
        return callback == nil ? nil : { (rawReturnCode: Int) in
            callback(ReturnCode(rawValue: rawReturnCode) ?? ReturnCode.unknown)
        }
    }

    fileprivate class func onDisconnectAdapter(_ callback: ((ReasonCode) -> ())!) -> ((_ reasonCode: Int) -> ())! {
        return callback == nil ? nil : { (rawReasonCode: Int) in
            callback(ReasonCode(rawValue: rawReasonCode) ?? ReasonCode.unexpected)
        }
    }

    fileprivate class func onMessageAdapter(_ callback: ((MQTTMessage) -> ())!) -> ((UnsafePointer<mosquitto_message>) -> ())! {
        return callback == nil ? nil : { (rawMessage: UnsafePointer<mosquitto_message>) in
            let message = rawMessage.pointee
            let topic = String(cString: message.topic)
            let payload = Data(bytes: UnsafeMutableRawPointer(message.payload), count: Int(message.payloadlen))
            let mqttMessage = MQTTMessage(messageId: Int(message.mid), topic: topic, payload: payload, qos: message.qos, retain: message.retain)
            callback(mqttMessage)
        }
    }

    fileprivate class func onSubscribeAdapter(_ callback: ((Int, Array<Int32>) -> ())!) -> ((Int, Int, UnsafePointer<Int32>) -> ())! {
        return callback == nil ? nil : { (messageId: Int, qosCount: Int, grantedQos: UnsafePointer<Int32>) in
            var grantedQosList = [Int32](repeating: Qos.At_Least_Once, count: qosCount)
            Array(0..<qosCount).reduce(grantedQos) { (qosPointer, index) in
                grantedQosList[index] = qosPointer.pointee
                return qosPointer.successor()
            }
            callback(messageId, grantedQosList)
        }
    }
}

public final class MQTTClient {
    fileprivate let mosquittoContext: __MosquittoContext
    public fileprivate(set) var isFinished: Bool = false
    internal let serialQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MQTT Client Operation Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    public var isConnected: Bool {
        return mosquittoContext.isConnected
    }

    internal init(mosquittoContext: __MosquittoContext) {
        self.mosquittoContext = mosquittoContext
    }
    
    deinit {
        disconnect()
    }

    public func publish(_ payload: Data, topic: String, qos: Int32, retain: Bool, requestCompletion: ((MosqResult, Int) -> ())? = nil) {
        serialQueue.addOperation {
            if (!self.isFinished) {
                var messageId: Int32 = 0
                let mosqReturn = mosquitto_publish(self.mosquittoContext.mosquittoHandler, &messageId, topic.cCharArray,
                    Int32(payload.count), (payload as NSData).bytes, qos, retain)
                requestCompletion?(MosqResult(rawValue: Int(mosqReturn)) ?? MosqResult.mosq_UNKNOWN, Int(messageId))
            }
        }
    }

    public func publishString(_ payload: String, topic: String, qos: Int32, retain: Bool, requestCompletion: ((MosqResult, Int) -> ())? = nil) {
        if let payloadData = (payload as NSString).data(using: String.Encoding.utf8.rawValue) {
            publish(payloadData, topic: topic, qos: qos, retain: retain, requestCompletion: requestCompletion)
        }
    }

    public func subscribe(_ topic: String, qos: Int32, requestCompletion: ((MosqResult, Int) -> ())? = nil) {
        serialQueue.addOperation {
            if (!self.isFinished) {
                var messageId: Int32 = 0
                let mosqReturn = mosquitto_subscribe(self.mosquittoContext.mosquittoHandler, &messageId, topic.cCharArray, qos)
                requestCompletion?(MosqResult(rawValue: Int(mosqReturn)) ?? MosqResult.mosq_UNKNOWN, Int(messageId))
            }
        }
    }

    public func unsubscribe(_ topic: String, requestCompletion: ((MosqResult, Int) -> ())? = nil) {
        serialQueue.addOperation {
            if (!self.isFinished) {
                var messageId: Int32 = 0
                let mosqReturn = mosquitto_unsubscribe(self.mosquittoContext.mosquittoHandler, &messageId, topic.cCharArray)
                requestCompletion?(MosqResult(rawValue: Int(mosqReturn)) ?? MosqResult.mosq_UNKNOWN, Int(messageId))
            }
        }
    }

    public func disconnect() {
        if (!isFinished) {
            isFinished = true
            let context = mosquittoContext
            serialQueue.addOperation {
                mosquitto_disconnect(context.mosquittoHandler)
                mosquitto_loop_stop(context.mosquittoHandler, false)
                mosquitto_context_cleanup(context)
            }
        }
    }

    public func awaitRequestCompletion() {
        serialQueue.waitUntilAllOperationsAreFinished()
    }

    public var socket: Int32? {
        let sock = mosquitto_socket(mosquittoContext.mosquittoHandler)
        return (sock == -1 ? nil : sock)
    }
}

private extension String {
    var cCharArray: [CChar] {
        return self.cString(using: String.Encoding.utf8)!
    }
}
