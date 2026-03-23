using System.Security.Claims;
using CuddleBear.Models;
using CuddleBear.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PayOS.Models.Webhooks;

[Route("api/order")]
[ApiController]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly BearShopDbContext _context;
    private readonly IPayOSService _payOSService;

    public OrdersController(
        BearShopDbContext context,
        IPayOSService payOSService
    )
    {
        _context = context;
        _payOSService = payOSService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        var userId = int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!
        );

        var order = new Order
        {
            UserId = userId,
            ShippingAddress = request.ShippingAddress,
            TotalAmount = request.TotalPrice,

            // trạng thái giao hàng
            Status = "PENDING",

            // trạng thái thanh toán
            StatusFee = request.PaymentMethod == "COD"
                ? "COD"
                : "CANCEL",

            CreatedAt = DateTime.Now
        };

        foreach (var item in request.Items)
        {
            order.OrderItems.Add(new OrderItem
            {
                ProductName = item.ProductName,
                Quantity = item.Quantity,
                Price = item.Price
            });
        }

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // 👉 PAYOS
        if (request.PaymentMethod == "BANKING")
        {
            var payment = await _payOSService.CreatePaymentAsync(
                order.Id,
                (int)order.TotalAmount
            );

            return Ok(new
            {
                orderId = order.Id,
                checkoutUrl = payment.CheckoutUrl,
                qrCode = payment.QrCode
            });
        }

        // 👉 COD
        return Ok(new
        {
            orderId = order.Id
        });
    }

    [HttpGet("my-orders")]
    public IActionResult GetMyOrders()
    {
        var userId = int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!
        );

        var orders = _context.Orders
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => new
            {
                o.Id,
                o.CreatedAt,
                o.TotalAmount,
                o.Status,
                o.StatusFee,
                o.ShippingAddress,
                Items = o.OrderItems.Select(i => new
                {
                    i.ProductName,
                    i.Quantity,
                    i.Price
                })
            })
            .ToList();

        return Ok(orders);
    }
    [HttpPost("payos/webhook")]
    [AllowAnonymous]
    public async Task<IActionResult> PayOSWebhook([FromBody] Webhook webhook)
    {
        WebhookData data;

        try
        {
            data = await _payOSService.VerifyWebhookAsync(webhook);
            Console.WriteLine("Webhook verified successfully : "+data);
        }
        catch
        {
            // ❌ Sai chữ ký
            return BadRequest("Invalid webhook");
        }

        // ✅ Thanh toán thành công
        if (data.Code == "00")
        {
            var order = await _context.Orders
                .FirstOrDefaultAsync(o => o.Id == data.OrderCode);

            if (order != null && order.StatusFee != "PAID")
            {
                order.StatusFee = "PAID";

                await _context.SaveChangesAsync();
            }
        }

        return Ok();
    }

    [HttpGet("check-payment/{orderId}")]
    [AllowAnonymous]
    // Bắt buộc user đã login
    public async Task<IActionResult> CheckPayment(int orderId)
    {
        // Lấy userId từ token
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdClaim))
            return Unauthorized();

        var userId = int.Parse(userIdClaim);


        // Lấy order từ DB, kiểm tra xem có thuộc user không
        var order = await _context.Orders
            .Include(o => o.OrderItems)
            .FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);

        if (order == null)
            return NotFound("Order không tồn tại hoặc không thuộc user");

        // Nếu order thanh toán COD -> luôn trả PAID
        if (order.StatusFee == "COD")
        {
            return Ok(new { status = "PAID" });
        }

        // Nếu order BANKING và chưa thanh toán -> gọi PayOS API check
        if (order.StatusFee == "CANCEL")
        {
            try
            {
                var paymentStatus = await _payOSService.GetPaymentStatusAsync(orderId);

                // Nếu thanh toán thành công
                if (paymentStatus.Code?.ToString() == "00")
                {
                    order.StatusFee = "PAID";
                    await _context.SaveChangesAsync();
                    return Ok(new { status = "PAID" });
                }
            }
            catch
            {
                // lỗi gọi PayOS -> vẫn trả CANCEL
                return Ok(new { status = "CANCEL" });
            }
        }

        // Trả về trạng thái hiện tại
        return Ok(new { status = order.StatusFee == "PAID" ? "PAID" : "CANCEL" });
    }



}
