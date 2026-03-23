using CuddleBear.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Metadata;
using System.Security.Claims;

namespace CuddleBear.Controllers
{

    [Route("api/[controller]")]

    public class BlogController : ControllerBase
    {
        private readonly BearShopDbContext _context;
        private readonly IConfiguration _config;

        public BlogController(BearShopDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }
        [Authorize]
        [HttpPost("blogs")]
        public async Task<IActionResult> CreateBlog( [FromBody]  CreateBlogDto dto)
        {

            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var blog = new Blog
            {
                UserId= int.Parse(userId),
                Title = dto.Title,
                Content = dto.Content,
                ImageUrl = dto.ImageUrl,
                CreatedAt = DateTime.Now
            };

            _context.Blogs.Add(blog);
            await _context.SaveChangesAsync();

            return Ok(blog);
        }

        [HttpGet("blogs")]
        public async Task<IActionResult> GetBlogs()
        {
            var blogs = await _context.Blogs
                .Include(b => b.User)
                .Select(b => new
                {
                    b.Id,
                    b.Title,
                    b.Content,
                    b.ImageUrl,
                    b.CreatedAt,
                    username = b.User.Username
                })
                .ToListAsync();

            return Ok(blogs);
        }

        [HttpPost("{id}/like")]
        public async Task<IActionResult> LikeBlog(int id)
        {
            var blog = await _context.Blogs.FindAsync(id);

            if (blog == null)
                return NotFound();

            blog.Likes = (blog.Likes ?? 0) + 1;

            await _context.SaveChangesAsync();

            return Ok(new { likes = blog.Likes });
        }
        [HttpGet("top")]
        public async Task<IActionResult> GetTopBlogs()
        {
            var blogs = await _context.Blogs
                .OrderByDescending(b => b.Likes)   // sắp xếp theo like giảm dần
                .Take(5)                           // lấy top 5
                .Select(b => new
                {
                    b.Id,
                    b.Title,
                    b.Content,
                    b.ImageUrl,
                    b.CreatedAt,
                    b.Likes
                })
                .ToListAsync();

            return Ok(blogs);
        }
    }
    }
