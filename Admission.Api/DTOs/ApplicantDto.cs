namespace Admission.Api.DTOs
{
    public class ApplicantDto
    {
        public int id { get; set; }
        public string LastName { get; set; } = null!;
        public string FirstName { get; set; } = null!;
        public string? Patronymic { get; set; }
        public string Gender { get; set; } = null!;
        public string Citizenship { get; set; } = null!;
        public DateTime BirthDate { get; set; }
        public string PassportData { get; set; } = null!;
        public string ApplicantAddress { get; set; } = null!;
        public string? ParentsAddress { get; set; }
        public string? ForeignLanguage { get; set; }
    }
}