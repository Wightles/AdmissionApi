using System.ComponentModel.DataAnnotations;

namespace Admission.Api.Models
{
    public class ExamResult
    {
        public int Id { get; set; }

        [Required]
        public int ApplicationId { get; set; }
        public Application? Application { get; set; }

        [MaxLength(20)]
        public string? Classroom { get; set; }

        [Required, MaxLength(100)]
        public string Subject { get; set; } = null!;

        public DateTime? ExamDate { get; set; }

        [Required]
        public int Score { get; set; } // 0..100
    }
}