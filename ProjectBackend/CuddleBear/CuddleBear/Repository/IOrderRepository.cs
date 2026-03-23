using CuddleBear.Models;

namespace CuddleBear.Repository
{
    public interface IOrderRepository : IGenericRepository<Order>
    {
        Task<Order> CreateOrderAsync(Order order);
        Task<List<Order>> GetOrdersByUserAsync(int userId);
    }
}
