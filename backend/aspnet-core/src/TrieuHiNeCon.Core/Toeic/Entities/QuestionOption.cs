using Abp.Domain.Entities.Auditing;

namespace TrieuHiNeCon.Toeic.Entities
{
    /// <summary>
    /// Các lựa chọn A/B/C/D cho mỗi câu hỏi
    /// </summary>
    public class QuestionOption : FullAuditedEntity<int>
    {
        public int QuestionId { get; set; }
        public virtual Question Question { get; set; }

        /// <summary>
        /// 'A', 'B', 'C', 'D'
        /// </summary>
        public string OptionKey { get; set; }

        /// <summary>
        /// Nội dung đáp án
        /// </summary>
        public string OptionText { get; set; }
    }
}
