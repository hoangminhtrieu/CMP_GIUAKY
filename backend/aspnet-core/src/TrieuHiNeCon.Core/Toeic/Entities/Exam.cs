using System;
using System.Collections.Generic;
using Abp.Domain.Entities.Auditing;

namespace TrieuHiNeCon.Toeic.Entities
{
    /// <summary>
    /// Đề thi TOEIC
    /// </summary>
    public class Exam : FullAuditedEntity<int>
    {
        public const int MaxTitleLength = 256;

        public string Title { get; set; }

        public string Description { get; set; }

        /// <summary>
        /// Thời gian làm bài (phút). TOEIC Reading = 75 phút
        /// </summary>
        public int DurationMinutes { get; set; } = 75;

        /// <summary>
        /// Tổng số câu hỏi
        /// </summary>
        public int TotalQuestions { get; set; }

        /// <summary>
        /// Trạng thái: Draft, Published, Archived
        /// </summary>
        public ExamStatus Status { get; set; } = ExamStatus.Draft;

        public virtual ICollection<PassageGroup> PassageGroups { get; set; }
        public virtual ICollection<Question> Questions { get; set; }
    }

    public enum ExamStatus : byte
    {
        Draft = 0,
        Published = 1,
        Archived = 2
    }
}
