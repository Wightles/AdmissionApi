using System.ComponentModel.DataAnnotations;

namespace Admission.Api.DTOs
{
    public class CreateApplicationDto
    {
        [Required]
        public int ApplicantId { get; set; }

        [Required, MaxLength(255)]
        public string Faculty { get; set; } = null!;

        [Required, MaxLength(255)]
        public string Specialty { get; set; } = null!;

        [MaxLength(255)]
        public string? EducationalInstitution { get; set; }

        public int? GraduationYear { get; set; }

        [MaxLength(100)]
        public string? DocumentType { get; set; }

        [MaxLength(50)]
        public string? DocumentNumber { get; set; }

        public decimal? AverageScore { get; set; }
        public decimal? EgeScore { get; set; }

        [MaxLength(10)]
        public string? GroupNumber { get; set; }
    }
}