namespace CuddleBear.Models
{
public class PaymentStatusResponse
{
    public string OrderCode { get; set; } = null!;
    public string Code { get; set; } = null!;   // "00" = thanh toán thành công
    public int Amount { get; set; }
    public string Status { get; set; } = null!;
}

}
