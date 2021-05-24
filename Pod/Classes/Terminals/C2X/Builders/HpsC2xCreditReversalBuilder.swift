import Foundation

@objcMembers
public class HpsC2xCreditReversalBuilder : HpsC2xBaseBuilder, GMSCreditReversalBuilder {
    public var amount: NSDecimalNumber?
    public var clientTransactionId: UUID?
    public var reason: ReversalReasonCode = .NOREASON
    public var referenceNumber: String?
    public var transactionId: String?
    
    public init(device: HpsC2xDevice) {
        super.init(transactionType: .creditReversal, device: device)
    }
    
    public override func buildRequest() -> Transaction? {
        return GMSRequestHelper.buildCreditReversalRequest(builder: self)
    }

    public override func mapResponse(_ data: HpsTerminalResponse, _ result: TransactionResult, _ response: TransactionResponse?) -> HpsTerminalResponse {
        return GMSResponseHelper.mapCreditReversalResponse(data, result, response)
    }
}
