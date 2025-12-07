namespace Admission.Api.DTOs
{
    public class ExamResultDto
    {
        public int Id { get; set; }
        public int ApplicationId { get; set; }
        public int ApplicantId { get; set; }
        public string? Classroom { get; set; }
        public string Subject { get; set; } = null!;
        public DateTime? ExamDate { get; set; }
        public int Score { get; set; }
    }
    
    public class ExamResultWithApplicantDto : ExamResultDto
    {
        public string? ApplicantName { get; set; }
        public string? Specialty { get; set; }
        public string? Faculty { get; set; }
    }
}