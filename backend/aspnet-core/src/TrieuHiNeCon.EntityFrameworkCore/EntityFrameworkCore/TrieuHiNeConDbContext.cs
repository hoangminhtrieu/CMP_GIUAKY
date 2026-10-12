using Abp.Zero.EntityFrameworkCore;
using TrieuHiNeCon.Authorization.Roles;
using TrieuHiNeCon.Authorization.Users;
using TrieuHiNeCon.MultiTenancy;
using Microsoft.EntityFrameworkCore;

namespace TrieuHiNeCon.EntityFrameworkCore;

public class TrieuHiNeConDbContext : AbpZeroDbContext<Tenant, Role, User, TrieuHiNeConDbContext>
{
    /* Define a DbSet for each entity of the application */
    public virtual DbSet<TrieuHiNeCon.Toeic.Entities.Exam> Exams { get; set; }
    public virtual DbSet<TrieuHiNeCon.Toeic.Entities.PassageGroup> PassageGroups { get; set; }
    public virtual DbSet<TrieuHiNeCon.Toeic.Entities.Question> Questions { get; set; }
    public virtual DbSet<TrieuHiNeCon.Toeic.Entities.QuestionOption> QuestionOptions { get; set; }
    public virtual DbSet<TrieuHiNeCon.Toeic.Entities.ExamAttempt> ExamAttempts { get; set; }
    public virtual DbSet<TrieuHiNeCon.Toeic.Entities.UserAnswer> UserAnswers { get; set; }

    public TrieuHiNeConDbContext(DbContextOptions<TrieuHiNeConDbContext> options)
        : base(options)
    {
    }
}
