using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Admission.Api.Data;
using Admission.Api.DTOs;
using Admission.Api.Models;

namespace Admission.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ExamResultsController : ControllerBase
    {
        private readonly AdmissionDbContext _db;
        public ExamResultsController(AdmissionDbContext db) => _db = db;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ExamResultDto>>> GetAll()
        {
            var items = await _db.ExamResults
                .AsNoTracking()
                .Select(e => new ExamResultDto {
                    Id = e.Id,
                    ApplicationId = e.ApplicationId,
                    Classroom = e.Classroom,
                    Subject = e.Subject,
                    ExamDate = e.ExamDate,
                    Score = e.Score
                }).ToListAsync();
            return Ok(items);
        }

        [HttpGet("with-applicant")]
        public async Task<ActionResult<IEnumerable<ExamResultWithApplicantDto>>> GetAllWithApplicant()
        {
            var items = await _db.ExamResults
                .Include(e => e.Application)
                .ThenInclude(a => a.Applicant)
                .AsNoTracking()
                .Select(e => new ExamResultWithApplicantDto {
                    Id = e.Id,
                    ApplicationId = e.ApplicationId,
                    ApplicantId = e.Application.ApplicantId,
                    Classroom = e.Classroom,
                    Subject = e.Subject,
                    ExamDate = e.ExamDate,
                    Score = e.Score,
                    ApplicantName = e.Application.Applicant.LastName + " " + 
                                   e.Application.Applicant.FirstName + " " + 
                                   (e.Application.Applicant.Patronymic ?? ""),
                    Specialty = e.Application.Specialty,
                    Faculty = e.Application.Faculty
                }).ToListAsync();
            return Ok(items);
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<ExamResultDto>> GetById(int id)
        {
            var e = await _db.ExamResults.AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);
            if (e == null) return NotFound();
            
            return Ok(new ExamResultDto {
                Id = e.Id,
                ApplicationId = e.ApplicationId,
                Classroom = e.Classroom,
                Subject = e.Subject,
                ExamDate = e.ExamDate,
                Score = e.Score
            });
        }

        [HttpGet("{id:int}/with-applicant")]
        public async Task<ActionResult<ExamResultWithApplicantDto>> GetByIdWithApplicant(int id)
        {
            var e = await _db.ExamResults
                .Include(er => er.Application)
                .ThenInclude(a => a.Applicant)
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);
                
            if (e == null) return NotFound();
            
            return Ok(new ExamResultWithApplicantDto {
                Id = e.Id,
                ApplicationId = e.ApplicationId,
                ApplicantId = e.Application.ApplicantId,
                Classroom = e.Classroom,
                Subject = e.Subject,
                ExamDate = e.ExamDate,
                Score = e.Score,
                ApplicantName = e.Application.Applicant.LastName + " " + 
                               e.Application.Applicant.FirstName + " " + 
                               (e.Application.Applicant.Patronymic ?? ""),
                Specialty = e.Application.Specialty,
                Faculty = e.Application.Faculty
            });
        }

        [HttpPost]
        public async Task<ActionResult<ExamResultDto>> Create(CreateExamResultDto dto)
        {
            var app = await _db.Applications.FindAsync(dto.ApplicationId);
            if (app == null) return BadRequest($"Application with id {dto.ApplicationId} not found.");

            var model = new ExamResult {
                ApplicationId = dto.ApplicationId,
                Classroom = dto.Classroom,
                Subject = dto.Subject,
                ExamDate = dto.ExamDate,
                Score = dto.Score
            };

            _db.ExamResults.Add(model);
            try
            {
                await _db.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                return Problem(detail: ex.Message);
            }

            return CreatedAtAction(nameof(GetById), new { id = model.Id }, new ExamResultDto {
                Id = model.Id,
                ApplicationId = model.ApplicationId,
                Classroom = model.Classroom,
                Subject = model.Subject,
                ExamDate = model.ExamDate,
                Score = model.Score
            });
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, CreateExamResultDto dto)
        {
            var existing = await _db.ExamResults.FindAsync(id);
            if (existing == null) return NotFound();

            existing.Classroom = dto.Classroom;
            existing.Subject = dto.Subject;
            existing.ExamDate = dto.ExamDate;
            existing.Score = dto.Score;

            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _db.ExamResults.FindAsync(id);
            if (existing == null) return NotFound();

            _db.ExamResults.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}