<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        return [
            'first_name' => $this->faker->firstName(),
            'last_name' => $this->faker->lastName(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->unique()->e164PhoneNumber(),
            'password' => Hash::make('Password@123'),
            'role' => 'customer',
            'status' => 'active',
            'language' => 'en',
            'timezone' => 'UTC',
            'email_verified_at' => now(),
            'email_notifications' => true,
            'push_notifications' => true,
            'sms_notifications' => false,
        ];
    }

    public function vendor(): static
    {
        return $this->state(fn () => ['role' => 'vendor']);
    }

    public function driver(): static
    {
        return $this->state(fn () => ['role' => 'driver']);
    }

    public function admin(): static
    {
        return $this->state(fn () => ['role' => 'admin']);
    }
}
