using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Admission.Api.Data;
using Admission.Api.DTOs;
using Admission.Api.Models;

namespace Admission.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SubjectGradesController : ControllerBase
    {
        private readonly AdmissionDbContext _db;
        public SubjectGradesController(AdmissionDbContext db) => _db = db;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<SubjectGradeDto>>> GetAll()
        {
            var items = await _db.SubjectGrades
                .AsNoTracking()
                .Select(sg => new SubjectGradeDto {
                    Id = sg.Id,
                    ApplicationId = sg.ApplicationId,
                    Subject = sg.Subject,
                    Grade = sg.Grade
                }).ToListAsync();
            return Ok(items);
        }

        [HttpPost]
        public async Task<ActionResult<SubjectGradeDto>> Create(CreateSubjectGradeDto dto)
        {
            // Validate application exists
            var app = await _db.Applications.FindAsync(dto.ApplicationId);
            if (app == null) return BadRequest($"Application with id {dto.ApplicationId} not found.");

            var model = new SubjectGrade {
                ApplicationId = dto.ApplicationId,
                Subject = dto.Subject,
                Grade = dto.Grade
            };

            _db.SubjectGrades.Add(model);
            try
            {
                await _db.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                return Problem(detail: ex.Message);
            }

            return CreatedAtAction(nameof(GetAll), new { id = model.Id }, new SubjectGradeDto {
                Id = model.Id,
                ApplicationId = model.ApplicationId,
                Subject = model.Subject,
                Grade = model.Grade
            });
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _db.SubjectGrades.FindAsync(id);
            if (existing == null) return NotFound();

            _db.SubjectGrades.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}