<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Services\NotificationServiceInterface;

/**
 * Notification façade. Delegates to the configured channel adapter so callers
 * (e.g. OrderProcessingService) never care whether FCM or OneSignal is active.
 */
class NotificationService implements NotificationServiceInterface
{
    private NotificationServiceInterface $activeChannel;

    public function __construct()
    {
        $channel = config('app_settings.notifications.default_channel', 'firebase');

        $this->activeChannel = $channel === 'onesignal'
            ? app(OneSignalNotificationService::class)
            : app(FirebaseNotificationService::class);
    }

    public function sendPush(string $deviceToken, string $title, string $body, array $data = []): bool
    {
        return $this->activeChannel->sendPush($deviceToken, $title, $body, $data);
    }

    public function sendPushToTopic(string $topic, string $title, string $body, array $data = []): bool
    {
        return $this->activeChannel->sendPushToTopic($topic, $title, $body, $data);
    }

    public function sendSmS(string $phone, string $message): bool
    {
        return $this->activeChannel->sendSmS($phone, $message);
    }

    public function sendEmail(string $to, string $subject, string $htmlContent): bool
    {
        return $this->activeChannel->sendEmail($to, $subject, $htmlContent);
    }

    public function sendOrderNotification(string $deviceToken, array $orderData): bool
    {
        return $this->activeChannel->sendOrderNotification($deviceToken, $orderData);
    }

    public function sendDeliveryNotification(string $deviceToken, array $deliveryData): bool
    {
        return $this->activeChannel->sendDeliveryNotification($deviceToken, $deliveryData);
    }
}
