using Azure.Core;
using CuddleBear.Models;
using CuddleBear.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;

namespace CuddleBear.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]  
    public class CheckoutController : ControllerBase
    {
        private readonly BearShopDbContext _context;
        private readonly IOrderService _orderService;
        public CheckoutController(IOrderService orderService, BearShopDbContext context )
        {
            _orderService = orderService;
            _context = context;
        }
        public class CreateOrderDto
        {
            public string ShippingAddress { get; set; } = "";
            public List<OrderItem> Items { get; set; } = new();
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
                Status = "PENDING",
                StatusFee = request.PaymentMethod,
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

            return Ok(new
            {
                message = "Create order success",
                orderId = order.Id
            });
        }
        [HttpGet("my-orders")]
        public async Task<IActionResult> MyOrders()
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var orders = await _orderService.GetOrdersByUserAsync(userId);

            return Ok(orders);
        }
    }
}
