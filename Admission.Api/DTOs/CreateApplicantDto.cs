using System.ComponentModel.DataAnnotations;

namespace Admission.Api.DTOs
{
    public class CreateApplicantDto
    {
        [Required, MaxLength(100)]
        public string LastName { get; set; } = null!;

        [Required, MaxLength(100)]
        public string FirstName { get; set; } = null!;

        [MaxLength(100)]
        public string? Patronymic { get; set; }

        [Required, RegularExpression("^[mf]$")]
        public string Gender { get; set; } = null!;

        [Required, MaxLength(50)]
        public string Citizenship { get; set; } = null!;

        [Required]
        public DateTime BirthDate { get; set; }

        [Required, MaxLength(150)]
        public string PassportData { get; set; } = null!;

        [Required]
        public string ApplicantAddress { get; set; } = null!;

        public string? ParentsAddress { get; set; }

        [MaxLength(50)]
        public string? ForeignLanguage { get; set; }
    }
}