using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Admission.Api.Models
{
    public class Application
    {
        public int Id { get; set; }

        [Required]
        public int ApplicantId { get; set; }
        public Applicant? Applicant { get; set; }

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

        [Column(TypeName = "numeric(5,2)")]
        public decimal? AverageScore { get; set; }

        [Column(TypeName = "numeric(5,2)")]
        public decimal? EgeScore { get; set; }

        [MaxLength(10)]
        public string? GroupNumber { get; set; }

        public ICollection<SubjectGrade> SubjectGrades { get; set; } = new List<SubjectGrade>();
        public ICollection<ExamResult> ExamResults { get; set; } = new List<ExamResult>();
    }
}