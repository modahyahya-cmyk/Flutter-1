<?php

declare(strict_types=1);

namespace App\Core\Domain\State;

use App\Exceptions\BusinessException;

/**
 * Single source of truth for the DELIVERY state machine.
 *
 * Prevents arbitrary status jumps, duplicate pickup/completion, and invalid
 * driver operations. All delivery status changes go through
 * {@see assertTransition()}.
 */
final class DeliveryStateMachine
{
    public const ASSIGNED = 'assigned';
    public const PICKED_UP = 'picked_up';
    public const IN_TRANSIT = 'in_transit';
    public const DELIVERED = 'delivered';
    public const FAILED = 'failed';
    public const CANCELLED = 'cancelled';

    public const TERMINAL = [
        self::DELIVERED,
        self::FAILED,
        self::CANCELLED,
    ];

    private const TRANSITIONS = [
        self::ASSIGNED => [self::PICKED_UP, self::CANCELLED],
        self::PICKED_UP => [self::IN_TRANSIT, self::FAILED],
        self::IN_TRANSIT => [self::DELIVERED, self::FAILED],
    ];

    public static function canTransition(string $from, string $to): bool
    {
        return in_array($to, self::TRANSITIONS[$from] ?? [], true);
    }

    public static function isTerminal(string $status): bool
    {
        return in_array($status, self::TERMINAL, true);
    }

    public static function assertTransition(string $from, string $to): void
    {
        if (! self::canTransition($from, $to)) {
            throw new BusinessException("Cannot change delivery status from '{$from}' to '{$to}'.");
        }
    }
}
