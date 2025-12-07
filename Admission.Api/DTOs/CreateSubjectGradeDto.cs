using System.ComponentModel.DataAnnotations;

namespace Admission.Api.DTOs
{
    public class CreateSubjectGradeDto
    {
        [Required]
        public int ApplicationId { get; set; }

        [Required, MaxLength(100)]
        public string Subject { get; set; } = null!;

        [Required, Range(1,5)]
        public int Grade { get; set; }
    }
}