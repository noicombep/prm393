namespace CuddleBear.Models
{
    public class CreateOrderRequest
    {
        public string ShippingAddress { get; set; } = null!;
        public string PaymentMethod { get; set; } = null!;
        public decimal TotalPrice { get; set; }
        public List<CreateOrderItemRequest> Items { get; set; } = new();
    }
}
