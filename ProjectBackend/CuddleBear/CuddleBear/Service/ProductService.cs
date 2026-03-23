using CuddleBear.Models;
using CuddleBear.Repository;

namespace CuddleBear.Service
{
    public class ProductService : IProductService
    {
        private readonly IProductRepository _productRepo;
        public ProductService(IProductRepository productRepo)
        {
            _productRepo = productRepo;
        }
        public async Task<IEnumerable<Product>> GetAllAsync()
        {
           return await _productRepo.GetActiveProductsAsync();
        }

        public async Task<Product?> GetByIdAsync(int id)
        {
           return await _productRepo.GetByIdAsync(id);
        }

        public async Task<List<ProductTopDto>> GetTop4()
        { 
             return await _productRepo.GetTop4();
        }
    }
}
