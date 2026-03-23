using CuddleBear.Models;
using PayOS.Models.V2.PaymentRequests;
using PayOS.Models.Webhooks;

namespace CuddleBear.Service
{
    public interface IPayOSService
    {
        Task<CreatePaymentLinkResponse> CreatePaymentAsync(
            int orderId,
            int amount
        );

        Task<WebhookData> VerifyWebhookAsync(Webhook webhook);
        Task<PaymentStatusResponse> GetPaymentStatusAsync(int orderId);

    }

}
