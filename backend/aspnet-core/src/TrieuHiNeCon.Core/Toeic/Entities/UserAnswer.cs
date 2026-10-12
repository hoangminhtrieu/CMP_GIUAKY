using Abp.Domain.Entities.Auditing;

namespace TrieuHiNeCon.Toeic.Entities
{
    /// <summary>
    /// Câu trả lời của người dùng cho từng câu hỏi trong 1 lần thi
    /// </summary>
    public class UserAnswer : FullAuditedEntity<long>
    {
        public long ExamAttemptId { get; set; }
        public virtual ExamAttempt ExamAttempt { get; set; }

        public int QuestionId { get; set; }
        public virtual Question Question { get; set; }

        /// <summary>
        /// Đáp án người dùng chọn: 'A', 'B', 'C', 'D', hoặc null nếu bỏ qua
        /// </summary>
        public string SelectedAnswer { get; set; }

        /// <summary>
        /// Kết quả chấm: true = đúng, false = sai, null = bỏ qua
        /// </summary>
        public bool? IsCorrect { get; set; }
    }
}
