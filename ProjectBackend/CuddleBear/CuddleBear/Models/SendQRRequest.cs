namespace CuddleBear.Models
{
    public class SendQRRequest
    {
        public string Email { get; set; }
        public string Message { get; set; }
        public IFormFile? Image { get; set; }
    }
}
