using CuddleBear.Models;

namespace CuddleBear.Service
{
    public interface IOrderService
    {
        Task<Order> CreateOrderAsync(int userId, string address, List<OrderItem> items);
        Task<List<Order>> GetOrdersByUserAsync(int userId);
    }
}
