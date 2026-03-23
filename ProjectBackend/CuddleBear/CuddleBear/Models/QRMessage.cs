namespace CuddleBear.Models
{
    public class QRMessage
    {
        public int Id { get; set; }

        public int SenderId { get; set; }

        public string? ReceiverEmail { get; set; }

        public string? Message { get; set; }

        public string? ImageUrl { get; set; }

        public string? QrCode { get; set; }

        public DateTime? CreatedAt { get; set; }

        public virtual User? Sender { get; set; }
    }
}
