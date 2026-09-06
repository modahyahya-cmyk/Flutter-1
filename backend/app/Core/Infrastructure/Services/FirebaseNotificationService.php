<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Services\NotificationServiceInterface;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

class FirebaseNotificationService implements NotificationServiceInterface
{
    private ?Messaging $messaging = null;

    public function sendPush(string $deviceToken, string $title, string $body, array $data = []): bool
    {
        if ($deviceToken === '') {
            return false;
        }

        try {
            $message = CloudMessage::withTarget('token', $deviceToken)
                ->withNotification(FirebaseNotification::create($title, $body))
                ->withData($data);

            $this->messaging()->send($message);

            return true;
        } catch (\Throwable $e) {
            Log::error('Firebase push failed: '.$e->getMessage());

            return false;
        }
    }

    public function sendPushToTopic(string $topic, string $title, string $body, array $data = []): bool
    {
        try {
            $message = CloudMessage::withTarget('topic', $topic)
                ->withNotification(FirebaseNotification::create($title, $body))
                ->withData($data);

            $this->messaging()->send($message);

            return true;
        } catch (\Throwable $e) {
            Log::error('Firebase topic send failed: '.$e->getMessage());

            return false;
        }
    }

    public function sendSmS(string $phone, string $message): bool
    {
        // No real SMS provider is wired here. Reporting success would be a
        // lie, so we log a warning and return false (message NOT delivered)
        // until a Twilio/Vonage adapter is configured and credentials provided.
        Log::warning("[SMS] SMS channel not configured; message NOT sent to {$phone}.");

        return false;
    }

    public function sendEmail(string $to, string $subject, string $htmlContent): bool
    {
        \Illuminate\Support\Facades\Mail::html($htmlContent, function ($mail) use ($to, $subject) {
            $mail->to($to)
                ->subject($subject)
                ->from(
                    config('app_settings.email.from_address', 'noreply@vendorhub.com'),
                    config('app_settings.email.from_name', 'VendorHub')
                );
        });

        return true;
    }

    public function sendOrderNotification(string $deviceToken, array $orderData): bool
    {
        return $this->sendPush(
            $deviceToken,
            'Order '.($orderData['order_number'] ?? ''),
            'Your order status is now: '.($orderData['status'] ?? ''),
            $orderData
        );
    }

    public function sendDeliveryNotification(string $deviceToken, array $deliveryData): bool
    {
        return $this->sendPush(
            $deviceToken,
            'Delivery Update',
            'Your delivery is '.($deliveryData['status'] ?? ''),
            $deliveryData
        );
    }

    private function messaging(): Messaging
    {
        if ($this->messaging === null) {
            $factory = (new \Kreait\Firebase\Factory())
                ->withServiceAccount(config('app_settings.notifications.firebase.credentials_path'));
            $this->messaging = $factory->createMessaging();
        }

        return $this->messaging;
    }
}
