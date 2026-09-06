<?php

namespace App\Core\Domain\Services;

interface NotificationServiceInterface
{
    public function sendPush(string $deviceToken, string $title, string $body, array $data = []): bool;

    public function sendPushToTopic(string $topic, string $title, string $body, array $data = []): bool;

    public function sendSmS(string $phone, string $message): bool;

    public function sendEmail(string $to, string $subject, string $htmlContent): bool;

    public function sendOrderNotification(string $deviceToken, array $orderData): bool;

    public function sendDeliveryNotification(string $deviceToken, array $deliveryData): bool;
}
