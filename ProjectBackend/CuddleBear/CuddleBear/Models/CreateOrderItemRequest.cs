namespace CuddleBear.Models
{
    public class CreateOrderItemRequest
    {
        public string ProductName { get; set; } = null!;
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }
}
