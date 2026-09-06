<?php

namespace App\Console\Commands;

use App\Core\Domain\Services\SubscriptionServiceInterface;
use Illuminate\Console\Command;

class ProcessExpiringSubscriptions extends Command
{
    protected $signature = 'subscriptions:process-expiring';

    protected $description = 'Expire subscriptions that have reached their end date.';

    public function handle(SubscriptionServiceInterface $subscriptions): int
    {
        $count = $subscriptions->processExpiringSubscriptions();

        $this->info("Processed {$count} expiring subscription(s).");

        return self::SUCCESS;
    }
}
