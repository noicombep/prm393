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
    public class AuthController : ControllerBase
    {
        private readonly BearShopDbContext _context;
        private readonly IConfiguration _config;

        public AuthController(BearShopDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        [HttpPost("register")]
        public IActionResult Register(RegisterDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (_context.Users.Any(x => x.Email == dto.Email))
                return BadRequest(new
                {
                    field = "email",
                    message = "Email đã tồn tại"
                });

            if (!IsStrongPassword(dto.Password))
                return BadRequest(new
                {
                    field = "password",
                    message = "Mật khẩu phải ≥ 8 ký tự, có chữ hoa, chữ thường và ký tự đặc biệt"
                });
            var otp = new Random().Next(100000, 999999).ToString();

            var emailOtp = new EmailOtp
            {
                Email = dto.Email,
                OtpCode = otp,
                ExpireAt = DateTime.Now.AddMinutes(5)
            };

            _context.EmailOtps.Add(emailOtp);
            _context.SaveChanges();

            var emailService = new EmailService();
            emailService.SendOtp(dto.Email, otp);

            return Ok(new
            {
                message = "OTP đã gửi về email",
                email = dto.Email
            });
        }
        [HttpPost("verify-otp")]
        public IActionResult VerifyOtp(VerifyOtpDto dto)
        {
            var otp = _context.EmailOtps
                .FirstOrDefault(x => x.Email == dto.Email && x.OtpCode == dto.Otp);

            if (otp == null || otp.ExpireAt < DateTime.Now)
                return BadRequest("OTP không hợp lệ");

            var user = new User
            {
                Username = dto.Username,
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                RoleId = 2
            };

            _context.Users.Add(user);

            _context.EmailOtps.Remove(otp);

            _context.SaveChanges();

            return Ok("Đăng ký thành công");
        }
        private bool IsStrongPassword(string password)
        {
            if (password.Length < 8)
                return false;

            bool hasUpper = password.Any(char.IsUpper);
            bool hasLower = password.Any(char.IsLower);
            bool hasSpecial = password.Any(ch => !char.IsLetterOrDigit(ch));

            return hasUpper && hasLower && hasSpecial;
        }


        [HttpPost("login")]
        public IActionResult Login(LoginDto dto)
        {
            var user = _context.Users
                .Include(u => u.Role)
                .FirstOrDefault(u => u.Email == dto.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash) )
                return Unauthorized(new
                {
                    field = "login",
                    message = "Sai email hoặc mật khẩu"
                });

            if (!user.IsActive)
            {
                return Unauthorized(new
                {
                    field = "account",
                    message = "Tài khoản đã bị khóa"
                });
            }

            var token = GenerateJwt(user);

            return Ok(new
            {
                token,
                fullName = user.FullName,
                role = user.Role.Name
            });
        }


        private string GenerateJwt(User user)
        {
            var claims = new[]
            {
                //Id
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()), 
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Role, user.Role.Name)
        };

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_config["Jwt:Key"])
            );

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddHours(2),
                signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        [Authorize]
        [HttpGet("profile")]
        public IActionResult Profile()
        {
            return Ok("Đã đăng nhập");
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("admin-only")]
        public IActionResult AdminOnly()
        {
            return Ok("Chỉ admin");
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("customers")]
        public async Task<IActionResult> GetCustomers()
        {
            var customers = await _context.Users
                .Where(u => u.RoleId == 2)
                .Select(u => new
                {
                    u.Id,
                    u.Username,
                    u.Email,
                    u.FullName
                })
                .ToListAsync();

            return Ok(customers);
        }


        [Authorize(Roles = "Admin")]
        [HttpPut("users/{id}")]
        public async Task<IActionResult> UpdateUser(int id, UpdateUserDto dto)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
                return NotFound("User không tồn tại");

            // Update từng field nếu có
            if (!string.IsNullOrEmpty(dto.Username))
                user.Username = dto.Username;

            if (!string.IsNullOrEmpty(dto.Email))
                user.Email = dto.Email;

            if (!string.IsNullOrEmpty(dto.FullName))
                user.FullName = dto.FullName;

            if (dto.RoleId.HasValue)
                user.RoleId = dto.RoleId.Value;

            if (dto.IsActive.HasValue)
                user.IsActive = dto.IsActive.Value;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật thành công" });
        }


        [Authorize(Roles = "Admin")]
        [HttpDelete("users/{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
                return NotFound("User không tồn tại");

            // ❗ Soft delete
            user.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa (soft delete)" });
        }


        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userId == null)
                return Unauthorized();

            var user = await _context.Users
                .Include(u => u.Role)
                .Where(u => u.Id == int.Parse(userId))
                .Select(u => new
                {
                    u.Id,
                    u.Username,
                    u.Email,
                    u.FullName,
                    u.Phone,
                    u.Address,
                    role = u.Role.Name
                })
                .FirstOrDefaultAsync();

            return Ok(user);
        }
        [Authorize]
        [HttpPut("me")]
        public async Task<IActionResult> UpdateProfile(UpdateUserDto dto)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userId == null)
                return Unauthorized();

            var user = await _context.Users.FindAsync(int.Parse(userId));

            if (user == null)
                return NotFound();

            if (!string.IsNullOrEmpty(dto.FullName))
                user.FullName = dto.FullName;

            if (!string.IsNullOrEmpty(dto.Phone))
                user.Phone = dto.Phone;

            if (!string.IsNullOrEmpty(dto.Address))
                user.Address = dto.Address;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật thành công" });
        }


        [Authorize]
        [HttpPut("change-password")]
        public async Task<IActionResult> ChangePassword(ChangePasswordDto dto)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userId == null)
                return Unauthorized();

            var user = await _context.Users.FindAsync(int.Parse(userId));

            if (user == null)
                return NotFound();

            // ❌ check mật khẩu cũ
            if (!BCrypt.Net.BCrypt.Verify(dto.OldPassword, user.PasswordHash))
            {
                return BadRequest(new
                {
                    message = "Mật khẩu cũ không đúng"
                });
            }
            // ✅ validate mật khẩu mới
            // ✅ update password
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đổi mật khẩu thành công" });
        }
    }

}
