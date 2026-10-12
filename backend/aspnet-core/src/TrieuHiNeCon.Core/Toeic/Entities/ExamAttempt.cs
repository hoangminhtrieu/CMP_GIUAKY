using System;
using Abp.Domain.Entities.Auditing;

namespace TrieuHiNeCon.Toeic.Entities
{
    /// <summary>
    /// Lần thử thi của người dùng
    /// </summary>
    public class ExamAttempt : FullAuditedEntity<long>
    {
        public int ExamId { get; set; }
        public virtual Exam Exam { get; set; }

        public long UserId { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime? SubmitTime { get; set; }

        /// <summary>
        /// Trạng thái: InProgress, Submitted, TimedOut
        /// </summary>
        public AttemptStatus Status { get; set; } = AttemptStatus.InProgress;

        // Kết quả (do Backend chấm sau khi nộp)
        public int? TotalCorrect { get; set; }
        public int? TotalWrong { get; set; }
        public int? TotalSkipped { get; set; }
        public decimal? ScorePercent { get; set; }
    }

    public enum AttemptStatus : byte
    {
        InProgress = 0,
        Submitted = 1,
        TimedOut = 2
    }
}
