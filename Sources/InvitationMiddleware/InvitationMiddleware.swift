import os.log
import Foundation
import Combine

import SwiftRex

// MARK: - ACTIONS
//sourcery: Prism
public enum InvitationAction {
    case createInvitation
    case storeInvitation
    case receiveInvitation(URL)
    case redeemInvitation
    case stateChanged(InvitationState)
}
// MARK: - STATE
public struct InvitationState: Equatable, Codable {
    public let list: [String: InvitationInfo]
    
    public init(list: [String: InvitationInfo]) {
        self.list = list
    }
    
    public static let empty = InvitationState(list: [:])
}

/// The "context" for the invitation that was sent for :
///   * a user to join a new family
///   * or a family to join a carpool
public struct InvitationInfo: Equatable, Codable {
    public enum InvitationType: String, Codable {
        case family
        case carpool
    }

    public let type: InvitationType
    public let subjectId: String
    public let redeemed: Bool
}

// MARK: - ERRORS
public enum InvitationError: Error {
    case invitationURLCreationError
    case invitationCreationError
    case invitationUpdateError
    case invitationDeletionError
    case invitationDecodingError
    case invitationEncodingError
    case invitationDataNotFoundError
}

// MARK: - PROTOCOL
public protocol InvitationStorage {
    // Note that the short link creation might need to be extracted out of this
    // middleware so we can keep it more streamlined and focused on its core functionality.
    func createShortLink() -> AnyPublisher<URL, InvitationError>
    func register(keys: CollectionDifference<String>)
    func create(key: String, invitation: InvitationInfo) -> AnyPublisher<Void, InvitationError>
    func read(key: String) -> AnyPublisher<InvitationInfo, InvitationError>
    func update(key: String, params: [String: Any]) -> AnyPublisher<Void, InvitationError>
    func delete(key: String) -> AnyPublisher<Void, InvitationError>
    func changeListeners() -> AnyPublisher<InvitationState, InvitationError>
}

// MARK: - MIDDLEWARE
/// The IntivationMiddleware is specifically designed to suit the needs of one application.
///
/// It offers the following :
///   * it allows for the creation of a dynamic link URL that can be shared
///   * it provides several facilities to create, read, update and delete the invitation
///     entry with the data provider,
///   * it listens to all state changes for the particular keys that were registered
///
/// Any new state change collected from the listener is dispatched as an action
/// so the global state can be modified accordingly.
///
public class InvitationMiddleware: Middleware {
    public typealias InputActionType = InvitationAction
    public typealias OutputActionType = InvitationAction
    public typealias StateType = InvitationState?
    
    private static let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "InvitationMiddleware")

    private var output: AnyActionHandler<OutputActionType>? = nil
    private var getState: GetState<StateType>? = nil

    private var provider: InvitationStorage
    
    private var stateChangeCancellable: AnyCancellable?
    private var operationCancellable: AnyCancellable?
    
    private var idBuffer: [String] = []

    public init(provider: InvitationStorage) {
        self.provider = provider
    }
    
    public func receiveContext(getState: @escaping GetState<StateType>, output: AnyActionHandler<OutputActionType>) {
        os_log(
            "Receiving context...",
            log: InvitationMiddleware.logger,
            type: .debug
        )
        self.getState = getState
        self.output = output
        self.stateChangeCancellable = provider
            .changeListeners()
            .sink { (completion: Subscribers.Completion<InvitationError>) in
                var result: String = "success"
                if case let Subscribers.Completion.failure(err) = completion {
                    result = "failure : " + err.localizedDescription
                }
                os_log(
                    "State change completed with %s.",
                    log: InvitationMiddleware.logger,
                    type: .debug,
                    result
                )
            } receiveValue: { value in
                os_log(
                    "State change receiving value for : %s...",
                    log: InvitationMiddleware.logger,
                    type: .debug,
                    String(describing: value)
                )
                self.output?.dispatch(.stateChanged(value))
            }
    }
    
    public func handle(
        action: InputActionType,
        from dispatcher: ActionSource,
        afterReducer : inout AfterReducer
    ) {
    }
}
