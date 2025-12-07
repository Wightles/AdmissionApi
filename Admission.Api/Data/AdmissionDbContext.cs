using Microsoft.EntityFrameworkCore;
using Admission.Api.Models;

namespace Admission.Api.Data
{
    public class AdmissionDbContext : DbContext
    {
        public AdmissionDbContext(DbContextOptions<AdmissionDbContext> options) : base(options) { }

        public DbSet<Applicant> Applicants { get; set; } = null!;
        public DbSet<Application> Applications { get; set; } = null!;
        public DbSet<SubjectGrade> SubjectGrades { get; set; } = null!;
        public DbSet<ExamResult> ExamResults { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Applicants
            modelBuilder.Entity<Applicant>(entity =>
            {
                entity.ToTable("applicants");
                entity.HasKey(e => e.id);
                entity.Property(e => e.id).HasColumnName("id");
                entity.Property(e => e.LastName).HasColumnName("last_name").HasMaxLength(100).IsRequired();
                entity.Property(e => e.FirstName).HasColumnName("first_name").HasMaxLength(100).IsRequired();
                entity.Property(e => e.Patronymic).HasColumnName("patronymic").HasMaxLength(100);
                entity.Property(e => e.Gender).HasColumnName("gender").HasMaxLength(1).IsRequired();
                entity.Property(e => e.Citizenship).HasColumnName("citizenship").HasMaxLength(50).IsRequired();
                entity.Property(e => e.BirthDate).HasColumnName("birth_date").IsRequired();
                entity.Property(e => e.PassportData).HasColumnName("passport_data").HasMaxLength(150).IsRequired();
                entity.HasIndex(e => e.PassportData).IsUnique();
                entity.Property(e => e.ApplicantAddress).HasColumnName("applicant_address").IsRequired();
                entity.Property(e => e.ParentsAddress).HasColumnName("parents_address");
                entity.Property(e => e.ForeignLanguage).HasColumnName("foreign_language").HasMaxLength(50);
            });

            // Applications
            modelBuilder.Entity<Application>(entity =>
            {
                entity.ToTable("applications");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.ApplicantId).HasColumnName("applicant_id").IsRequired();
                entity.Property(e => e.Faculty).HasColumnName("faculty").HasMaxLength(255).IsRequired();
                entity.Property(e => e.Specialty).HasColumnName("specialty").HasMaxLength(255).IsRequired();
                entity.Property(e => e.EducationalInstitution).HasColumnName("educational_institution").HasMaxLength(255);
                entity.Property(e => e.GraduationYear).HasColumnName("graduation_year");
                entity.Property(e => e.DocumentType).HasColumnName("document_type").HasMaxLength(100);
                entity.Property(e => e.DocumentNumber).HasColumnName("document_number").HasMaxLength(50);
                entity.Property(e => e.AverageScore).HasColumnName("average_score").HasPrecision(5, 2);
                entity.Property(e => e.EgeScore).HasColumnName("ege_score").HasPrecision(5, 2);
                entity.Property(e => e.GroupNumber).HasColumnName("group_number").HasMaxLength(10);

                entity.HasOne(a => a.Applicant)
                      .WithMany(a => a.Applications)
                      .HasForeignKey(a => a.ApplicantId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // SubjectGrades
            modelBuilder.Entity<SubjectGrade>(entity =>
            {
                entity.ToTable("subject_grades");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.ApplicationId).HasColumnName("application_id").IsRequired();
                entity.Property(e => e.Subject).HasColumnName("subject").HasMaxLength(100).IsRequired();
                entity.Property(e => e.Grade).HasColumnName("grade").IsRequired();
                entity.HasIndex(e => new { e.ApplicationId, e.Subject }).IsUnique();

                entity.HasOne(sg => sg.Application)
                      .WithMany(a => a.SubjectGrades)
                      .HasForeignKey(sg => sg.ApplicationId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ExamResults
            modelBuilder.Entity<ExamResult>(entity =>
            {
                entity.ToTable("exam_results");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id");
                entity.Property(e => e.ApplicationId).HasColumnName("application_id").IsRequired();
                entity.Property(e => e.Classroom).HasColumnName("classroom").HasMaxLength(20);
                entity.Property(e => e.Subject).HasColumnName("subject").HasMaxLength(100).IsRequired();
                entity.Property(e => e.ExamDate).HasColumnName("exam_date");
                entity.Property(e => e.Score).HasColumnName("score").IsRequired();
                entity.HasIndex(e => new { e.ApplicationId, e.Subject }).IsUnique();

                entity.HasOne(er => er.Application)
                      .WithMany(a => a.ExamResults)
                      .HasForeignKey(er => er.ApplicationId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            base.OnModelCreating(modelBuilder);
        }
    }
}