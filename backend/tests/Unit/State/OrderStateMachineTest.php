<?php

namespace Tests\Unit\State;

use App\Core\Domain\State\OrderStateMachine;
use App\Exceptions\BusinessException;
use PHPUnit\Framework\TestCase;

class OrderStateMachineTest extends TestCase
{
    public function test_legal_forward_transitions(): void
    {
        $legal = [
            [OrderStateMachine::PENDING, OrderStateMachine::CONFIRMED],
            [OrderStateMachine::CONFIRMED, OrderStateMachine::PREPARING],
            [OrderStateMachine::PREPARING, OrderStateMachine::READY_FOR_PICKUP],
            [OrderStateMachine::READY_FOR_PICKUP, OrderStateMachine::OUT_FOR_DELIVERY],
            [OrderStateMachine::OUT_FOR_DELIVERY, OrderStateMachine::DELIVERED],
            [OrderStateMachine::DELIVERED, OrderStateMachine::REFUNDED],
        ];

        foreach ($legal as [$from, $to]) {
            $this->assertTrue(OrderStateMachine::canTransition($from, $to), "{$from}->{$to} should be legal");
        }
    }

    public function test_illegal_jumps_are_rejected(): void
    {
        $illegal = [
            [OrderStateMachine::PENDING, OrderStateMachine::DELIVERED],
            [OrderStateMachine::PENDING, OrderStateMachine::READY_FOR_PICKUP],
            [OrderStateMachine::CONFIRMED, OrderStateMachine::READY_FOR_PICKUP],
            [OrderStateMachine::DELIVERED, OrderStateMachine::PREPARING],
            [OrderStateMachine::OUT_FOR_DELIVERY, OrderStateMachine::PREPARING],
        ];

        foreach ($illegal as [$from, $to]) {
            $this->assertFalse(OrderStateMachine::canTransition($from, $to), "{$from}->{$to} should be illegal");
        }
    }

    public function test_assert_transition_throws_on_illegal(): void
    {
        $this->expectException(BusinessException::class);
        OrderStateMachine::assertTransition(OrderStateMachine::DELIVERED, OrderStateMachine::PENDING);
    }

    public function test_terminal_states(): void
    {
        $this->assertTrue(OrderStateMachine::isTerminal(OrderStateMachine::DELIVERED));
        $this->assertTrue(OrderStateMachine::isTerminal(OrderStateMachine::CANCELLED));
        $this->assertTrue(OrderStateMachine::isTerminal(OrderStateMachine::REFUNDED));
        $this->assertFalse(OrderStateMachine::isTerminal(OrderStateMachine::PENDING));
    }

    public function test_cancellation_only_from_cancellable_states(): void
    {
        $this->assertTrue(OrderStateMachine::isCancellable(OrderStateMachine::PENDING));
        $this->assertTrue(OrderStateMachine::isCancellable(OrderStateMachine::CONFIRMED));
        $this->assertFalse(OrderStateMachine::isCancellable(OrderStateMachine::PREPARING));
        $this->assertFalse(OrderStateMachine::isCancellable(OrderStateMachine::DELIVERED));
    }
}
