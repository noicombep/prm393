using CuddleBear.Models;
using Microsoft.EntityFrameworkCore;

namespace CuddleBear.Repository
{
    public class OrderRepository : GenericRepository<Order>, IOrderRepository
    {
        public OrderRepository(BearShopDbContext context) : base(context) { }

        public async Task<Order> CreateOrderAsync(Order order)
        {
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
            return order;
        }

        public async Task<List<Order>> GetOrdersByUserAsync(int userId)
        {
            return await _context.Orders.Where(o => o.User.Id == userId).Include(o => o.OrderItems).ToListAsync();
        }
    }
}
