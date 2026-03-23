using CuddleBear.Models;
using CuddleBear.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CuddleBear.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : Controller
    {
        private readonly BearShopDbContext _context;


        private readonly IProductService _productService;

        public ReviewsController(IProductService productService, IConfiguration config, BearShopDbContext context)
        {
            _productService = productService;
            _context = context;
        }
        [HttpGet("product/{productId}")]
        public async Task<IActionResult> GetReviewsByProduct(int productId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Where(r => r.ProductId == productId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new
                {
                    r.Id,
                    r.Rating,
                    r.Comment,
                    r.CreatedAt,
                    UserName = r.User != null ? r.User.Username : "Anonymous"
                })
                .ToListAsync();

            return Ok(reviews);
        }
        [Authorize]
        [HttpPost]
        public async Task<IActionResult> CreateReview([FromBody] Review review)
        {

            //var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
             var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
            var existingReview = await _context.Reviews
       .FirstOrDefaultAsync(r => r.UserId == userId && r.ProductId == review.ProductId);

            if (existingReview != null)
            {
                return BadRequest("You have already reviewed this product.");
            }
            review.CreatedAt = DateTime.Now;
            Review review1 = new Review
            {
                ProductId = review.ProductId,
                UserId = userId,
                Rating = review.Rating,
                Comment= review.Comment,
                CreatedAt = review.CreatedAt
            };
            _context.Reviews.Add(review1);
            await _context.SaveChangesAsync();

            return Ok(review);
        }

        // ⭐ Xóa review
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReview(int id)
        {
            var review = await _context.Reviews.FindAsync(id);
            if (review == null) return NotFound();

            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}
