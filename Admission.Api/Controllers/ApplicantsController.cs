using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Admission.Api.Data;
using Admission.Api.Models;
using Admission.Api.DTOs;

namespace Admission.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ApplicantsController : ControllerBase
    {
        private readonly AdmissionDbContext _db;
        public ApplicantsController(AdmissionDbContext db) => _db = db;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ApplicantDto>>> GetAll()
        {
            var items = await _db.Applicants
                .AsNoTracking()
                .Select(a => new ApplicantDto {
                    id = a.id,
                    LastName = a.LastName,
                    FirstName = a.FirstName,
                    Patronymic = a.Patronymic,
                    Gender = a.Gender,
                    Citizenship = a.Citizenship,
                    BirthDate = a.BirthDate,
                    PassportData = a.PassportData,
                    ApplicantAddress = a.ApplicantAddress,
                    ParentsAddress = a.ParentsAddress,
                    ForeignLanguage = a.ForeignLanguage
                }).ToListAsync();

            return Ok(items);
        }

        [HttpGet("{id:int}", Name = "GetApplicant")]
        public async Task<ActionResult<ApplicantDto>> GetByid(int id)
        {
            var a = await _db.Applicants.AsNoTracking().FirstOrDefaultAsync(x => x.id == id);
            if (a == null) return NotFound();
            var dto = new ApplicantDto {
                id = a.id,
                LastName = a.LastName,
                FirstName = a.FirstName,
                Patronymic = a.Patronymic,
                Gender = a.Gender,
                Citizenship = a.Citizenship,
                BirthDate = a.BirthDate,
                PassportData = a.PassportData,
                ApplicantAddress = a.ApplicantAddress,
                ParentsAddress = a.ParentsAddress,
                ForeignLanguage = a.ForeignLanguage
            };
            return Ok(dto);
        }

        [HttpPost]
        public async Task<ActionResult<ApplicantDto>> Create(CreateApplicantDto create)
        {
            var model = new Applicant {
                LastName = create.LastName,
                FirstName = create.FirstName,
                Patronymic = create.Patronymic,
                Gender = create.Gender,
                Citizenship = create.Citizenship,
                BirthDate = create.BirthDate,
                PassportData = create.PassportData,
                ApplicantAddress = create.ApplicantAddress,
                ParentsAddress = create.ParentsAddress,
                ForeignLanguage = create.ForeignLanguage
            };

            _db.Applicants.Add(model);
            try
            {
                await _db.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                // обработка уникальных ограничений
                return Problem(detail: ex.Message);
            }

            var dto = new ApplicantDto {
                id = model.id,
                LastName = model.LastName,
                FirstName = model.FirstName,
                Patronymic = model.Patronymic,
                Gender = model.Gender,
                Citizenship = model.Citizenship,
                BirthDate = model.BirthDate,
                PassportData = model.PassportData,
                ApplicantAddress = model.ApplicantAddress,
                ParentsAddress = model.ParentsAddress,
                ForeignLanguage = model.ForeignLanguage
            };

            return CreatedAtRoute("GetApplicant", new { id = dto.id }, dto);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, CreateApplicantDto update)
        {
            var existing = await _db.Applicants.FindAsync(id);
            if (existing == null) return NotFound();

            existing.LastName = update.LastName;
            existing.FirstName = update.FirstName;
            existing.Patronymic = update.Patronymic;
            existing.Gender = update.Gender;
            existing.Citizenship = update.Citizenship;
            existing.BirthDate = update.BirthDate;
            existing.PassportData = update.PassportData;
            existing.ApplicantAddress = update.ApplicantAddress;
            existing.ParentsAddress = update.ParentsAddress;
            existing.ForeignLanguage = update.ForeignLanguage;

            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _db.Applicants.FindAsync(id);
            if (existing == null) return NotFound();

            _db.Applicants.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}