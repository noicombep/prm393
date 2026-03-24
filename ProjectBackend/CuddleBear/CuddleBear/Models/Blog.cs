namespace CuddleBear.Models
{
    public class Blog
    {
        public int Id { get; set; }

        public int? UserId { get; set; }

        public string? Title { get; set; }

        public string? Content { get; set; }
        public int? Likes { get; set; } = 0;
        public string? ImageUrl { get; set; }

        public DateTime? CreatedAt { get; set; }

        public virtual User? User { get; set; }
    }
}
