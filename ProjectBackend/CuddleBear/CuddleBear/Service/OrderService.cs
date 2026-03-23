using CuddleBear.Models;
using CuddleBear.Repository;

namespace CuddleBear.Service
{
    public class OrderService : IOrderService
    {
        private readonly IOrderRepository _orderRepo;

        public OrderService(IOrderRepository orderRepo)
        {
            _orderRepo = orderRepo;
        }
        public async Task<Order> CreateOrderAsync(int userId, string address, List<OrderItem> items)
        {
            decimal total = items.Sum(i => i.Price * i.Quantity);
            var order = new Order
            {
                UserId = userId,
                ShippingAddress = address,
                TotalAmount = total,
                Status = "Pending",
                CreatedAt = DateTime.UtcNow,
                OrderItems = items
            };
            return await _orderRepo.CreateOrderAsync(order);
        }

        public async Task<List<Order>> GetOrdersByUserAsync(int userId)
        {
            return await _orderRepo.GetOrdersByUserAsync(userId);
        }


    }
}
