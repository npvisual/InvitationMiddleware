// Generated using Sourcery 1.0.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension InvitationAction {
    public var createInvitation: Void? {
        get {
            guard case .createInvitation = self else { return nil }
            return ()
        }
    }

    public var isCreateInvitation: Bool {
        self.createInvitation != nil
    }

    public var storeInvitation: Void? {
        get {
            guard case .storeInvitation = self else { return nil }
            return ()
        }
    }

    public var isStoreInvitation: Bool {
        self.storeInvitation != nil
    }

    public var receiveInvitation: URL? {
        get {
            guard case let .receiveInvitation(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .receiveInvitation = self, let newValue = newValue else { return }
            self = .receiveInvitation(newValue)
        }
    }

    public var isReceiveInvitation: Bool {
        self.receiveInvitation != nil
    }

    public var redeemInvitation: Void? {
        get {
            guard case .redeemInvitation = self else { return nil }
            return ()
        }
    }

    public var isRedeemInvitation: Bool {
        self.redeemInvitation != nil
    }

    public var stateChanged: Void? {
        get {
            guard case .stateChanged = self else { return nil }
            return ()
        }
    }

    public var isStateChanged: Bool {
        self.stateChanged != nil
    }

}
