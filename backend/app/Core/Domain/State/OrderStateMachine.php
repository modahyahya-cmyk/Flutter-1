<?php

declare(strict_types=1);

namespace App\Core\Domain\State;

use App\Exceptions\BusinessException;

/**
 * Single source of truth for the ORDER state machine.
 *
 * Every status mutation for an order must be validated here. Controllers and
 * repositories must NOT perform arbitrary status updates; they route through
 * the domain/service layer which calls {@see assertTransition()} so illegal
 * jumps, cancellations from invalid states and duplicate completions are
 * impossible.
 */
final class OrderStateMachine
{
    public const PENDING = 'pending';
    public const CONFIRMED = 'confirmed';
    public const PREPARING = 'preparing';
    public const READY_FOR_PICKUP = 'ready_for_pickup';
    public const OUT_FOR_DELIVERY = 'out_for_delivery';
    public const DELIVERED = 'delivered';
    public const CANCELLED = 'cancelled';
    public const REFUNDED = 'refunded';

    /** Terminal states: once reached, the order can never change again. */
    public const TERMINAL = [
        self::DELIVERED,
        self::CANCELLED,
        self::REFUNDED,
    ];

    /**
     * States from which the CUSTOMER may request a cancellation. Cancelling
     * later (after preparing begins) is not permitted to protect the vendor
     * and the delivery fleet.
     */
    public const CANCELLABLE = [
        self::PENDING,
        self::CONFIRMED,
    ];

    private const TRANSITIONS = [
        // Pending -> confirmed: vendor/system acknowledges the order.
        self::PENDING => [self::CONFIRMED, self::CANCELLED],
        // Confirmed -> preparing: vendor starts preparing.
        self::CONFIRMED => [self::PREPARING, self::CANCELLED],
        // Preparing -> ready: vendor has the order on the counter.
        self::PREPARING => [self::READY_FOR_PICKUP, self::CANCELLED],
        // ready -> out (delivery) for delivery orders, or -> delivered for
        // pickup/dine-in orders (handed to the customer directly).
        self::READY_FOR_PICKUP => [self::OUT_FOR_DELIVERY, self::DELIVERED],
        // out -> delivered: driver drops it off.
        self::OUT_FOR_DELIVERY => [self::DELIVERED],
        // delivered -> refunded: admin refund after a post-delivery dispute.
        self::DELIVERED => [self::REFUNDED],
    ];

    public static function canTransition(string $from, string $to): bool
    {
        return in_array($to, self::TRANSITIONS[$from] ?? [], true);
    }

    public static function isTerminal(string $status): bool
    {
        return in_array($status, self::TERMINAL, true);
    }

    public static function isCancellable(string $status): bool
    {
        return in_array($status, self::CANCELLABLE, true);
    }

    public static function assertTransition(string $from, string $to): void
    {
        if (! self::canTransition($from, $to)) {
            throw new BusinessException("Cannot change order status from '{$from}' to '{$to}'.");
        }
    }
}
