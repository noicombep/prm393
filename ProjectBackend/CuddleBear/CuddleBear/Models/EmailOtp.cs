namespace CuddleBear.Models
{
    public class EmailOtp
    {
        public int Id { get; set; }

        public string Email { get; set; } = null!;

        public string OtpCode { get; set; } = null!;

        public DateTime ExpireAt { get; set; }
    }
}
    