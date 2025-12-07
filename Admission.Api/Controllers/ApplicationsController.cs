using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Admission.Api.Data;
using Admission.Api.DTOs;
using Admission.Api.Models;

namespace Admission.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ApplicationsController : ControllerBase
    {
        private readonly AdmissionDbContext _db;
        public ApplicationsController(AdmissionDbContext db) => _db = db;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ApplicationDto>>> GetAll()
        {
            var items = await _db.Applications
                .AsNoTracking()
                .Select(a => new ApplicationDto {
                    Id = a.Id,
                    ApplicantId = a.ApplicantId,
                    Faculty = a.Faculty,
                    Specialty = a.Specialty,
                    EducationalInstitution = a.EducationalInstitution,
                    GraduationYear = a.GraduationYear,
                    DocumentType = a.DocumentType,
                    DocumentNumber = a.DocumentNumber,
                    AverageScore = a.AverageScore,
                    EgeScore = a.EgeScore,
                    GroupNumber = a.GroupNumber
                }).ToListAsync();

            return Ok(items);
        }

        [HttpGet("{id:int}", Name = "GetApplication")]
        public async Task<ActionResult<ApplicationDto>> GetById(int id)
        {
            var a = await _db.Applications.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
            if (a == null) return NotFound();
            
            return Ok(new ApplicationDto {
                Id = a.Id,
                ApplicantId = a.ApplicantId,
                Faculty = a.Faculty,
                Specialty = a.Specialty,
                EducationalInstitution = a.EducationalInstitution,
                GraduationYear = a.GraduationYear,
                DocumentType = a.DocumentType,
                DocumentNumber = a.DocumentNumber,
                AverageScore = a.AverageScore,
                EgeScore = a.EgeScore,
                GroupNumber = a.GroupNumber
            });
        }

        [HttpPost]
        public async Task<ActionResult<ApplicationDto>> Create(CreateApplicationDto dto)
        {
            // Ensure applicant exists
            var applicant = await _db.Applicants.FindAsync(dto.ApplicantId);
            if (applicant == null) return BadRequest($"Applicant with id {dto.ApplicantId} not found.");

            var model = new Application {
                ApplicantId = dto.ApplicantId,
                Faculty = dto.Faculty,
                Specialty = dto.Specialty,
                EducationalInstitution = dto.EducationalInstitution,
                GraduationYear = dto.GraduationYear,
                DocumentType = dto.DocumentType,
                DocumentNumber = dto.DocumentNumber,
                AverageScore = dto.AverageScore,
                EgeScore = dto.EgeScore,
                GroupNumber = dto.GroupNumber
            };

            _db.Applications.Add(model);
            await _db.SaveChangesAsync();

            var result = new ApplicationDto {
                Id = model.Id,
                ApplicantId = model.ApplicantId,
                Faculty = model.Faculty,
                Specialty = model.Specialty,
                EducationalInstitution = model.EducationalInstitution,
                GraduationYear = model.GraduationYear,
                DocumentType = model.DocumentType,
                DocumentNumber = model.DocumentNumber,
                AverageScore = model.AverageScore,
                EgeScore = model.EgeScore,
                GroupNumber = model.GroupNumber
            };

            return CreatedAtRoute("GetApplication", new { id = result.Id }, result);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, CreateApplicationDto dto)
        {
            var existing = await _db.Applications.FindAsync(id);
            if (existing == null) return NotFound();

            // Optionally check existence of applicant
            var applicant = await _db.Applicants.FindAsync(dto.ApplicantId);
            if (applicant == null) return BadRequest($"Applicant with id {dto.ApplicantId} not found.");

            existing.ApplicantId = dto.ApplicantId;
            existing.Faculty = dto.Faculty;
            existing.Specialty = dto.Specialty;
            existing.EducationalInstitution = dto.EducationalInstitution;
            existing.GraduationYear = dto.GraduationYear;
            existing.DocumentType = dto.DocumentType;
            existing.DocumentNumber = dto.DocumentNumber;
            existing.AverageScore = dto.AverageScore;
            existing.EgeScore = dto.EgeScore;
            existing.GroupNumber = dto.GroupNumber;

            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _db.Applications.FindAsync(id);
            if (existing == null) return NotFound();

            _db.Applications.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}