//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

public extension NSNotification.Name {
    /// Posted when registration state changes (e.g. the user becomes registered, or deregistered).
    static let registrationStateDidChange = NSNotification.Name("NSNotificationNameRegistrationStateDidChange")

    /// Posted when the local number changes. This may be due to a registration state change, but could just be a change
    /// number operation with no actual registration changes.
    static let localNumberDidChange = NSNotification.Name("NSNotificationNameLocalNumberDidChange")
}

public protocol RegistrationStateChangeManager {

    func registrationState(tx: DBReadTransaction) -> TSRegistrationState

    /**
     * Called once registration/reregistration is complete and the app is ready for normal operation.
     * Not used for secondary linking or change number.
     * This puts the state into ``TSRegistrationState.registered``.
     *
     * To observe changes related to this method, use ``NSNotification.Name.registrationStateDidChange``
     * and ``NSNotification.Name.localNumberDidChange``.
     *
     * Note that some side effects (generally, those that must happen in the same write transaction)
     * are triggered internally by this class and don't need separate observation.
     */
    func didRegisterPrimary(
        e164: E164,
        aci: Aci,
        pni: Pni,
        authToken: String,
        tx: DBWriteTransaction
    )

    /**
     * Called when a secondary device is linked but is not finished provisioning.
     * This puts the state into ``TSRegistrationState.linkedButUnprovisioned``.
     * ``didFinishProvisioningSecondary`` completes the process.
     *
     * To observe changes related to this method, use ``NSNotification.Name.registrationStateDidChange``
     * and ``NSNotification.Name.localNumberDidChange``.
     *
     * Note that some side effects (generally, those that must happen in the same write transaction)
     * are triggered internally by this class and don't need separate observation.
     *
     * PNI TODO: once all devices are PNI-capable, remove PNI nullability here.
     */
    func didLinkSecondary(
        e164: E164,
        aci: Aci,
        pni: Pni?,
        authToken: String,
        deviceId: UInt32,
        tx: DBWriteTransaction
    )

    /**
     * After linking, secondary devices sync storage service records and do other
     * setup before provisioning is finished, then this is called after its all done.
     * This puts the state into ``TSRegistrationState.provisioned``.
     *
     * To observe changes related to this method, use ``NSNotification.Name.registrationStateDidChange``.
     *
     * Note that some side effects (generally, those that must happen in the same write transaction)
     * are triggered internally by this class and don't need separate observation.
     *
     * This is a pretty bad approach and we should stop doing eventually, by letting provisioning
     * itself internally manage its intermediary state instead of outsourcing state management here.
     */
    func didFinishProvisioningSecondary(tx: DBWriteTransaction)

    /**
     * Called once change number is complete.
     * Should never change registration state; can only change number if already registered.
     *
     * To observe changes related to this method, use ``NSNotification.Name.localNumberDidChange``.
     *
     * Note that some side effects (generally, those that must happen in the same write transaction)
     * are triggered internally by this class and don't need separate observation.
     *
     * PNI TODO: once all devices are PNI-capable, remove PNI nullability here.
     * The `pni` parameter is nullable to support legacy behavior.
     */
    func didUpdateLocalPhoneNumber(
        _ e164: E164,
        aci: Aci,
        pni: Pni?,
        tx: DBWriteTransaction
    )

    /**
     * Reset the account state to prepare for reregistration.
     * Should only be called when in ``TSRegistrationState.deregistered`` or
     * ``TSRegistrationState.delinked``, and local identifiers are set.
     * This puts the state into ``TSRegistrationState.reregistering``.
     *
     * Can fail, if local state is not as expected. In these cases, will return false and callers
     * should abort any reregistration attempts.
     *
     * To observe changes related to this method, use ``NSNotification.Name.registrationStateDidChange``
     * and ``NSNotification.Name.localNumberDidChange``.
     *
     * Note that some side effects (generally, those that must happen in the same write transaction)
     * are triggered internally by this class and don't need separate observation.
     */
    func resetForReregistration(
        localPhoneNumber: E164,
        localAci: Aci,
        wasPrimaryDevice: Bool,
        tx: DBWriteTransaction
    ) -> Bool

    /**
     * Set when a transfer (incoming or outgoing) begins.
     * This puts the state into ``TSRegistrationState.transferringIncoming``,
     * ``TSRegistrationState.transferringPrimaryOutgoing`` or
     * ``TSRegistrationState.transferringLinkedOutgoing``.
     *
     * Will trigger a ``NSNotification.Name.registrationStateDidChange``.
     */
    func setIsTransferInProgress(tx: DBWriteTransaction)

    /**
     * Set when an incoming or outgoing transfer ends.
     * Puts registration state back to whatever it was (just resets isTransferring which is an independent variable).
     *
     * Note that after a successful incoming transfer, local database state ends up broken and registration state is indeterminate,
     * so this is only meaningful if the transfer is ended because it failed or was cancelled.
     *
     *  - parameter sendStateUpdateNotification: If true, ``NSNotification.Name.registrationStateDidChange``
     *  will be sent, otherwise it will be supressed. (Set to false only after an incoming transfer completes, to avoid
     *  observers then checking for broken local database state before the app reboots.)
     */
    func setIsTransferComplete(
        sendStateUpdateNotification: Bool,
        tx: DBWriteTransaction
    )

    /**
     * Set when an outgoing transfer ends.
     * This puts the state into ``TSRegistrationState.tranferred``.
     */
    func setWasTransferred(tx: DBWriteTransaction)

    /**
     * Unregisters with the server, resetting all app data after completion (if successful).
     */
    func unregisterFromService(auth: ChatServiceAuth) async throws
}
