namespace Admission.Api.DTOs
{
    public class SubjectGradeDto
    {
        public int Id { get; set; }
        public int ApplicationId { get; set; }
        public string Subject { get; set; } = null!;
        public int Grade { get; set; }
    }
}