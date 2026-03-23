using CuddleBear.Models;
using CuddleBear.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CuddleBear.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/qr")]
    public class QRController : ControllerBase
    {
        private readonly BearShopDbContext _context;
        private readonly QrService _qrService;
        private readonly EmailService _emailService;

        public QRController(
            BearShopDbContext context,
            QrService qrService,
            EmailService emailService)
        {
            _context = context;
            _qrService = qrService;
            _emailService = emailService;
        }

        [Authorize]
        [HttpPost("send")]
        public async Task<IActionResult> SendQR([FromForm] SendQRRequest request)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier).Value);

            string qrContent = request.Message;

            if (request.Image != null)
            {
                var fileName = Guid.NewGuid().ToString() + Path.GetExtension(request.Image.FileName);

                var path = Path.Combine("wwwroot/images", fileName);

                using (var stream = new FileStream(path, FileMode.Create))
                {
                    await request.Image.CopyToAsync(stream);
                }

                qrContent = $"https://localhost:7131/images/{fileName}";
            }

            byte[] qr = _qrService.GenerateQr(qrContent);

            var qrMessage = new QRMessage
            {
                SenderId = userId,
                ReceiverEmail = request.Email,
                Message = request.Message,
                ImageUrl = qrContent,
                QrCode = Convert.ToBase64String(qr),
                CreatedAt = DateTime.Now
            };

            _context.QRMessages.Add(qrMessage);
            await _context.SaveChangesAsync();
            await _emailService.SendQR(request.Email, qr);
            return Ok(qr);
        }


        [Authorize]
        [HttpGet("notifications")]
        public async Task<IActionResult> GetNotifications()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier).Value);

            var list = await _context.Notifications
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .ToListAsync();

            return Ok(list);
        }
    }
}
