using CuddleBear.Models;

namespace CuddleBear.Repository
{
    public interface IProductRepository : IGenericRepository<Product>
    {
        Task<IEnumerable<Product>> GetActiveProductsAsync();
        Task<List<ProductTopDto>> GetTop4();
    }
}
