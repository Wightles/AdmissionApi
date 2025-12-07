using System.ComponentModel.DataAnnotations;

namespace Admission.Api.DTOs
{
    public class CreateExamResultDto
    {
        [Required]
        public int ApplicationId { get; set; }

        [MaxLength(20)]
        public string? Classroom { get; set; }

        [Required, MaxLength(100)]
        public string Subject { get; set; } = null!;

        public DateTime? ExamDate { get; set; }

        [Required, Range(0,100)]
        public int Score { get; set; }
    }
}