namespace Admission.Api.DTOs
{
    public class ApplicationDto
    {
        public int Id { get; set; }
        public int ApplicantId { get; set; }
        public string Faculty { get; set; } = null!;
        public string Specialty { get; set; } = null!;
        public string? EducationalInstitution { get; set; }
        public int? GraduationYear { get; set; }
        public string? DocumentType { get; set; }
        public string? DocumentNumber { get; set; }
        public decimal? AverageScore { get; set; }
        public decimal? EgeScore { get; set; }
        public string? GroupNumber { get; set; }
    }
}