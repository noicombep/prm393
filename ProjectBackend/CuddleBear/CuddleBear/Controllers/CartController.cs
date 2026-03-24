using System.Text.Json;
using CuddleBear.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
namespace CuddleBear.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CartController : ControllerBase
    {
        

        private string GetCartKey()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userId))
                return "CART_GUEST";

            return $"CART_{userId}";
        }
        // 📌 Lấy cart từ cookie
        private List<CartItemDto> GetCart()
        {
            var cartJson = Request.Cookies[GetCartKey()];
            return string.IsNullOrEmpty(cartJson)
                ? new List<CartItemDto>()
                : JsonSerializer.Deserialize<List<CartItemDto>>(cartJson);
        }

        // 📌 Lưu cart vào cookie
        private void SaveCart(List<CartItemDto> cart)
        {
            var options = new CookieOptions
            {

                Expires = DateTime.Now.AddDays(7),
                HttpOnly = false,
                Secure = true, // true nếu HTTPS
                SameSite = SameSiteMode.None,
            };

            Response.Cookies.Append(
                GetCartKey(),
                JsonSerializer.Serialize(cart),
                options
            );
        }

        [HttpPost("add")]
        public IActionResult AddToCart([FromBody] CartItemDto item)
        {
            var cart = GetCart();

            var existingItem = cart.FirstOrDefault(x => x.ProductId == item.ProductId);

            if (existingItem != null)
            {
                existingItem.Quantity += item.Quantity;
            }
            else
            {
                cart.Add(item);
            }

            SaveCart(cart);
            return Ok(cart);
        }


        [HttpGet]
        public IActionResult GetCartItems()
        {
            return Ok(GetCart());
        }

        [HttpDelete("remove/{productId}")]
        public IActionResult Remove(int productId)
        {
            var cart = GetCart();
            cart.RemoveAll(x => x.ProductId == productId);

            SaveCart(cart);
            return Ok(cart);
        }


        [HttpPut("update")]
        public IActionResult UpdateQuantity(int productId, int quantity)
        {
            var cart = GetCart();
            var item = cart.FirstOrDefault(x => x.ProductId == productId);

            if (item == null) return NotFound();

            item.Quantity = quantity;
            SaveCart(cart);

            return Ok(cart);
        }

        [HttpDelete("clear")]
        public IActionResult Clear()
        {
            Response.Cookies.Delete(GetCartKey());
            return Ok();
        }


    }
}

