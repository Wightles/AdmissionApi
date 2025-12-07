using System.ComponentModel.DataAnnotations;

namespace Admission.Api.Models
{
    public class SubjectGrade
    {
        public int Id { get; set; }

        [Required]
        public int ApplicationId { get; set; }
        public Application? Application { get; set; }

        [Required, MaxLength(100)]
        public string Subject { get; set; } = null!;

        [Required]
        public int Grade { get; set; } // 1..5
    }
}