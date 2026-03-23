using CuddleBear.Models;
using CuddleBear.Service;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;


namespace CuddleBear.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly BearShopDbContext _context;


        private readonly IProductService _productService;
       
        public ProductsController(IProductService productService, IConfiguration config, BearShopDbContext context)
        {
            _productService = productService;
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> getAll()
        {
            var products = await _productService.GetAllAsync();
            return Ok(products);
        }
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null) return NotFound();
            return Ok(product);
        }
        [HttpGet("top4")]
        public async Task<IActionResult> GetTop4()
        {
            var products = await _productService.GetTop4();
            return Ok(products);
        }
      





    }
}
