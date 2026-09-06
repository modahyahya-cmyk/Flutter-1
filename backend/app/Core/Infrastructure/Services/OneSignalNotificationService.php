<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Services\NotificationServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OneSignalNotificationService implements NotificationServiceInterface
{
    public function sendPush(string $deviceToken, string $title, string $body, array $data = []): bool
    {
        if ($deviceToken === '') {
            return false;
        }

        $response = $this->request([
            'include_player_ids' => [$deviceToken],
            'headings' => ['en' => $title],
            'contents' => ['en' => $body],
            'data' => $data,
        ]);

        return $response && $response['success'] === 1;
    }

    public function sendPushToTopic(string $topic, string $title, string $body, array $data = []): bool
    {
        $response = $this->request([
            'included_segments' => [$topic],
            'headings' => ['en' => $title],
            'contents' => ['en' => $body],
            'data' => $data,
        ]);

        return $response && $response['success'] === 1;
    }

    public function sendSmS(string $phone, string $message): bool
    {
        // No real SMS provider is wired here; never report a false success.
        Log::warning("[SMS] SMS channel not configured; message NOT sent to {$phone}.");

        return false;
    }

    public function sendEmail(string $to, string $subject, string $htmlContent): bool
    {
        \Illuminate\Support\Facades\Mail::html($htmlContent, function ($mail) use ($to, $subject) {
            $mail->to($to)->subject($subject);
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

    private function request(array $payload): ?array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Basic '.config('app_settings.notifications.onesignal.rest_api_key'),
        ])->post('https://onesignal.com/api/v1/notifications', $payload);

        return $response->json();
    }
}
