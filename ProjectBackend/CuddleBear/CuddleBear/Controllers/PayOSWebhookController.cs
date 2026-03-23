using CuddleBear.Models;
using Microsoft.AspNetCore.Mvc;
using PayOS;
using PayOS.Models.Webhooks;

[ApiController]
[Route("api/payos/webhook")]
public class PayOSWebhookController : ControllerBase
{
    private readonly PayOSClient _client;
    private readonly BearShopDbContext _context;

    public PayOSWebhookController(
        IConfiguration config,
        BearShopDbContext context
    )
    {
        _client = new PayOSClient(
            config["PayOS:ClientId"]!,
            config["PayOS:ApiKey"]!,
            config["PayOS:ChecksumKey"]!
        );
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> HandleWebhook([FromBody] Webhook webhook)
    {
        // 1️⃣ Verify chữ ký PayOS
        var data = await _client.Webhooks.VerifyAsync(webhook);

        // 2️⃣ Chỉ xử lý khi thanh toán thành công
            if (!webhook.Success)
                return BadRequest();

        // 3️⃣ Lấy orderCode = orderId
        var orderId = (int)data.OrderCode;

        var order = await _context.Orders.FindAsync(orderId);
        if (order == null) return NotFound();

        // 4️⃣ Update trạng thái đơn
        order.StatusFee = "PAID";
        order.Status = "CONFIRMED";

        await _context.SaveChangesAsync();

        return Ok(new { message = "Webhook processed" });
    }
}
