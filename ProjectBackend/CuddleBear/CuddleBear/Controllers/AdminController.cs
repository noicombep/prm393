using CuddleBear.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CuddleBear.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
 //   [Authorize(Roles = "Admin")]

    public class AdminController : ControllerBase
    {
        private readonly BearShopDbContext _context;

        private readonly IWebHostEnvironment _env;

        public AdminController(BearShopDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        // ======================
        // STATS
        // ======================

        [HttpGet("stats")]
        public IActionResult GetStats()
        {
            var revenue = _context.Orders
                .Where(o => o.StatusFee == "PAID")
                .Sum(o => (decimal?)o.TotalAmount) ?? 0;

            var orders = _context.Orders.Count();

            var users = _context.Users.Count();

            var products = _context.Products.Count();

            return Ok(new
            {
                revenue,
                orders,
                users,
                products
            });
        }


        // ======================
        // REVENUE CHART
        // ======================

        [HttpGet("revenue-chart")]
        public IActionResult RevenueChart()
        {
            var data = _context.Orders
                .Where(o => o.StatusFee == "PAID" && o.CreatedAt != null)
                .GroupBy(o => o.CreatedAt.Value.Month)
                .Select(g => new
                {
                    monthNumber = g.Key,
                    month = new DateTime(1, g.Key, 1).ToString("MMM"),
                    revenue = g.Sum(x => x.TotalAmount)
                })
                .OrderBy(x => x.monthNumber)
                .Select(x => new
                {
                    month = x.month,
                    revenue = x.revenue
                })
                .ToList();

            return Ok(data);
        }


        // =========================
        // ORDERS
        // =========================

        [HttpGet("orders")]
        public async Task<IActionResult> GetOrders()
        {
            var orders = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new
                {
                    id = o.Id,
                    username = o.User.Username,
                    totalAmount = o.TotalAmount,
                    status = o.Status,
                    paymentStatus = o.StatusFee,
                    createdAt = o.CreatedAt,
                    items = o.OrderItems.Select(i => new
                    {
                        productName = i.ProductName,
                        quantity = i.Quantity,
                        price = i.Price
                    })
                })
                .ToListAsync();

            return Ok(orders);
        }

        [HttpPut("orders/{id}")]
        public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] UpdateOrderStatusDto dto)
        {
            var order = await _context.Orders.FindAsync(id);

            if (order == null)
                return NotFound();

            order.Status = dto.Status;
            if(dto.Status == "DELIVERED")
            {
                order.StatusFee = "PAID";
            }
            else { 
                order.StatusFee = "CANCEL";
            }
            await _context.SaveChangesAsync();

            return Ok(order);
        }

        [HttpGet("orders/{id}")]
        public async Task<IActionResult> GetOrder(int id)
        {
            var order = await _context.Orders
                .Where(o => o.Id == id)
                .Select(o => new
                {
                    o.Id,
                    o.Status,
                    o.StatusFee,
                    o.CreatedAt,
                    o.TotalAmount,
                    Username = o.User.Username,
                    OrderItems = o.OrderItems.Select(i => new
                    {
                        i.Id,
                        ProductName = i.ProductName,
                        i.Price,
                        i.Quantity
                    })
                })
                .FirstOrDefaultAsync();

            if (order == null) return NotFound();

            return Ok(order);
        }
        // =========================
        // USERS
        // =========================

        [HttpGet("users")]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _context.Users
                .Include(u => u.Role)
                .ToListAsync();

            return Ok(users);
        }

        [HttpPut("users/{id}")]
        public async Task<IActionResult> UpdateUserRole(int id, [FromBody] UpdateUserRoleDto body)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
                return NotFound();

            user.RoleId = body.RoleId;

            await _context.SaveChangesAsync();

            return Ok(user);
        }

        // =========================
        // PRODUCTS
        // =========================

        [HttpGet("products")]
        public async Task<IActionResult> GetAllProducts()
        {
            var products = await _context.Products
                .Include(p => p.Category)
                .ToListAsync();

            return Ok(products);
        }

        [HttpPost("products")]
        public async Task<IActionResult> CreateProduct([FromForm] ProductCreateDto dto)
        {
            string? imagePath = null;

            if (dto.Image != null)
            {
                var folder = Path.Combine(_env.WebRootPath, "images");

                if (!Directory.Exists(folder))
                {
                    Directory.CreateDirectory(folder);
                }

                var fileName = Guid.NewGuid() + Path.GetExtension(dto.Image.FileName);
                var path = Path.Combine(folder, fileName);

                using (var stream = new FileStream(path, FileMode.Create))
                {
                    await dto.Image.CopyToAsync(stream);
                }

                imagePath = "/images/" + fileName;
            }

            var product = new Product
            {
                Name = dto.Name,
                Description = dto.Description,
                Price = dto.Price,
                Stock = dto.Stock,
                CategoryId = dto.CategoryId,
                ImageUrl = imagePath,
                CreatedAt = DateTime.Now,
                IsActive = true
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            return Ok(product);
        }

        [HttpPut("products/{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromForm] ProductCreateDto dto)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
                return NotFound();

            product.Name = dto.Name;
            product.Description = dto.Description;
            product.Price = dto.Price;
            product.Stock = dto.Stock;
            product.CategoryId = dto.CategoryId;

            if (dto.Image != null)
            {
                var folder = Path.Combine(_env.WebRootPath, "images");

                if (!Directory.Exists(folder))
                {
                    Directory.CreateDirectory(folder);
                }

                var fileName = Guid.NewGuid() + Path.GetExtension(dto.Image.FileName);
                var path = Path.Combine(folder, fileName);

                using (var stream = new FileStream(path, FileMode.Create))
                {
                    await dto.Image.CopyToAsync(stream);
                }

                product.ImageUrl = "/images/" + fileName;
            }

            await _context.SaveChangesAsync();

            return Ok(product);
        }

        [HttpDelete("products/{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
                return NotFound();

            _context.Products.Remove(product);

            await _context.SaveChangesAsync();

            return Ok();
        }

        // =========================
        // CATEGORIES
        // =========================

        [HttpGet("categories")]
        public async Task<IActionResult> GetAllCategories()
        {
            return Ok(await _context.Categories.ToListAsync());
        }

        [HttpPost("categories")]
        public async Task<IActionResult> CreateCategory([FromBody] Category category)
        {
            _context.Categories.Add(category);

            await _context.SaveChangesAsync();

            return Ok(category);
        }

        [HttpPut("categories/{id}")]
        public async Task<IActionResult> UpdateCategory(int id, [FromBody] Category data)
        {
            var category = await _context.Categories.FindAsync(id);

            if (category == null)
                return NotFound();

            category.Name = data.Name;
            category.IsActive = data.IsActive;

            await _context.SaveChangesAsync();

            return Ok(category);
        }

        [HttpDelete("categories/{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var category = await _context.Categories.FindAsync(id);

            if (category == null)
                return NotFound();

            _context.Categories.Remove(category);

            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}