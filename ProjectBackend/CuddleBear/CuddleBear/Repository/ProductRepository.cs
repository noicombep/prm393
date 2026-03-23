using CuddleBear.Models;
using Microsoft.EntityFrameworkCore;

namespace CuddleBear.Repository
{
    public class ProductRepository : GenericRepository<Product>, IProductRepository
    {

        public ProductRepository(BearShopDbContext context) : base(context) { }

        public async Task<IEnumerable<Product>> GetActiveProductsAsync()
        {
            return await _context.Products
                .Where(p => p.IsActive)
                .Include(p => p.Category)
                .ToListAsync();
        }



        public async Task<List<ProductTopDto>> GetTop4()
        {
            return await _context.Products
                .Where(p => p.IsActive)
                .Take(4)
                .Select(p => new ProductTopDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.Price,
                    ImageUrl = p.ImageUrl
                })
                .ToListAsync();
        }


    }
}
