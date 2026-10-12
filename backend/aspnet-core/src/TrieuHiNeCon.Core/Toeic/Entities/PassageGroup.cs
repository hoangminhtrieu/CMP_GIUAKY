using System.Collections.Generic;
using Abp.Domain.Entities.Auditing;

namespace TrieuHiNeCon.Toeic.Entities
{
    /// <summary>
    /// Nhóm đoạn văn / hình ảnh cho Part 6 & Part 7 (Level 2)
    /// </summary>
    public class PassageGroup : FullAuditedEntity<int>
    {
        /// <summary>
        /// Thuộc đề thi nào
        /// </summary>
        public int ExamId { get; set; }
        public virtual Exam Exam { get; set; }

        /// <summary>
        /// Nội dung đoạn văn (HTML hoặc plain text)
        /// </summary>
        public string PassageText { get; set; }

        /// <summary>
        /// Đường dẫn ảnh (null nếu là text passage)
        /// </summary>
        public string ImagePath { get; set; }

        /// <summary>
        /// Thứ tự hiển thị trong đề thi
        /// </summary>
        public int OrderIndex { get; set; }

        /// <summary>
        /// Part của đề (6 hoặc 7)
        /// </summary>
        public int PartNumber { get; set; }

        public virtual ICollection<Question> Questions { get; set; }
    }
}
