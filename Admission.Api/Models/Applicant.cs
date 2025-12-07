using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Admission.Api.Models
{
    public class Applicant
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int id { get; set; }  // ← ЗАГЛАВНАЯ I!

    [Required, MaxLength(100)]
    public string LastName { get; set; } = null!;

    [Required, MaxLength(100)]
    public string FirstName { get; set; } = null!;

    [MaxLength(100)]
    public string? Patronymic { get; set; }

    [Required, MaxLength(1)]
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

    public ICollection<Application> Applications { get; set; } = new List<Application>();
}
}