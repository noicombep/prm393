namespace CuddleBear.Models
{
    public class PayOSWebhookDto
    {
        public string signature { get; set; } = "";
        public PayOSWebhookData data { get; set; } = new();
    }

    public class PayOSWebhookData
    {
        public long orderCode { get; set; }
        public string description { get; set; } = "";
        public int amount { get; set; }
        public string reference { get; set; } = "";
    }


}