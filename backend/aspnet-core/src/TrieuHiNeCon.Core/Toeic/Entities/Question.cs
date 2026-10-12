using System.Collections.Generic;
using Abp.Domain.Entities.Auditing;

namespace TrieuHiNeCon.Toeic.Entities
{
    /// <summary>
    /// Câu hỏi - dùng chung cho cả Level 1 và Level 2
    /// </summary>
    public class Question : FullAuditedEntity<int>
    {
        public int ExamId { get; set; }
        public virtual Exam Exam { get; set; }

        /// <summary>
        /// NULL = Level 1 (Part 5 độc lập)
        /// NOT NULL = Level 2 (Part 6/7 phụ thuộc đoạn văn)
        /// </summary>
        public int? PassageGroupId { get; set; }
        public virtual PassageGroup PassageGroup { get; set; }

        /// <summary>
        /// Số thứ tự câu hỏi trong đề (101..200)
        /// </summary>
        public int QuestionNumber { get; set; }

        /// <summary>
        /// Nội dung câu hỏi (có thể chứa "-------" blank)
        /// </summary>
        public string QuestionText { get; set; }

        /// <summary>
        /// Part trong đề thi (5, 6, hoặc 7)
        /// </summary>
        public int PartNumber { get; set; }

        /// <summary>
        /// Đáp án đúng: 'A', 'B', 'C', hoặc 'D'
        /// </summary>
        public string CorrectAnswer { get; set; }

        /// <summary>
        /// Giải thích đáp án (tuỳ chọn)
        /// </summary>
        public string Explanation { get; set; }

        public virtual ICollection<QuestionOption> Options { get; set; }
    }
}
