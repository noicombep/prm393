using CuddleBear.Models;
namespace CuddleBear.Service
{
    public interface IProductService
    {
        Task<IEnumerable<Product>> GetAllAsync();
        Task<Product?> GetByIdAsync(int id);
        Task<List<ProductTopDto>> GetTop4();

    }
}
