<?php

namespace Tests\Unit\State;

use App\Core\Domain\State\DeliveryStateMachine;
use App\Exceptions\BusinessException;
use PHPUnit\Framework\TestCase;

class DeliveryStateMachineTest extends TestCase
{
    public function test_legal_transitions(): void
    {
        $legal = [
            [DeliveryStateMachine::ASSIGNED, DeliveryStateMachine::PICKED_UP],
            [DeliveryStateMachine::PICKED_UP, DeliveryStateMachine::IN_TRANSIT],
            [DeliveryStateMachine::IN_TRANSIT, DeliveryStateMachine::DELIVERED],
        ];

        foreach ($legal as [$from, $to]) {
            $this->assertTrue(DeliveryStateMachine::canTransition($from, $to), "{$from}->{$to} should be legal");
        }
    }

    public function test_illegal_duplicate_and_jump_transitions_are_rejected(): void
    {
        $illegal = [
            [DeliveryStateMachine::ASSIGNED, DeliveryStateMachine::DELIVERED], // jump
            [DeliveryStateMachine::DELIVERED, DeliveryStateMachine::IN_TRANSIT], // duplicate completion
            [DeliveryStateMachine::DELIVERED, DeliveryStateMachine::ASSIGNED],
            [DeliveryStateMachine::PICKED_UP, DeliveryStateMachine::ASSIGNED],
        ];

        foreach ($illegal as [$from, $to]) {
            $this->assertFalse(DeliveryStateMachine::canTransition($from, $to), "{$from}->{$to} should be illegal");
        }
    }

    public function test_assert_transition_throws_on_duplicate_delivery(): void
    {
        $this->expectException(BusinessException::class);
        DeliveryStateMachine::assertTransition(DeliveryStateMachine::DELIVERED, DeliveryStateMachine::DELIVERED);
    }

    public function test_terminal_states(): void
    {
        $this->assertTrue(DeliveryStateMachine::isTerminal(DeliveryStateMachine::DELIVERED));
        $this->assertTrue(DeliveryStateMachine::isTerminal(DeliveryStateMachine::FAILED));
        $this->assertTrue(DeliveryStateMachine::isTerminal(DeliveryStateMachine::CANCELLED));
        $this->assertFalse(DeliveryStateMachine::isTerminal(DeliveryStateMachine::ASSIGNED));
    }
}
