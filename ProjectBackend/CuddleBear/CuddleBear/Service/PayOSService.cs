using System.Text.Json;
using CuddleBear.Models;
using CuddleBear.Service;
using Microsoft.Extensions.Configuration;
using PayOS;
using PayOS.Models;
using PayOS.Models.V2.PaymentRequests;
using PayOS.Models.Webhooks;

namespace CuddleBear.Service
{
    public class PayOSService : IPayOSService
    {
        private readonly PayOSClient _client;

        public PayOSService(IConfiguration config)
        {
            _client = new PayOSClient(
                config["PayOS:ClientId"]!,
                config["PayOS:ApiKey"]!,
                config["PayOS:ChecksumKey"]!
            );
        }

        public async Task<CreatePaymentLinkResponse> CreatePaymentAsync(
            int orderId,
            int amount
        )
        {
            var request = new CreatePaymentLinkRequest
            {
                OrderCode = orderId,
                Amount = amount,
                Description = $"ORDER_{orderId}",
                ReturnUrl = "http://localhost:5173/payment-success",
                CancelUrl = "http://localhost:5173/payment-cancel"
            };

            return await _client.PaymentRequests.CreateAsync(request);
        }

        public async Task<WebhookData> VerifyWebhookAsync(Webhook webhook)
        {
            // Nếu sai chữ ký → PayOS THROW exception
            return await _client.Webhooks.VerifyAsync(webhook);
        }
        public async Task<PaymentStatusResponse> GetPaymentStatusAsync(int orderId)
        {
            // SDK trả về JSON string hoặc object → parse về PayOSPayment
            var paymentRaw = await _client.PaymentRequests.GetAsync(orderId.ToString());

            // Nếu trả về string JSON
            var payment = JsonSerializer.Deserialize<PayOSPayment>(
                JsonSerializer.Serialize(paymentRaw),
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
            )!;

            return new PaymentStatusResponse
            {
                OrderCode = payment.OrderCode,
                Amount = payment.Amount,
                Code = payment.Status == "PAID" ? "00" : "01",
                Status = payment.Status
            };
        }




    }
}
