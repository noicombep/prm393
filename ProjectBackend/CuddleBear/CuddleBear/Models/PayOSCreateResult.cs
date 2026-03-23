namespace CuddleBear.Models
{
    public class PayOSCreateResult
    {
        public string CheckoutUrl { get; set; } = string.Empty;
        public string QrCode { get; set; } = string.Empty;
        public long OrderCode { get; set; }
    }

}
