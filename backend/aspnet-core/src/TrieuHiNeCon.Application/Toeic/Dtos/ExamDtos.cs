using System.Collections.Generic;
using Microsoft.AspNetCore.Http;

namespace TrieuHiNeCon.Toeic.Dtos
{
    // ── INPUT DTOs ──────────────────────────────────────────────────────

    public class ImportExamInput
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public IFormFile File { get; set; }
    }

    public class SubmitAttemptInput
    {
        public long AttemptId { get; set; }
        public bool IsTimedOut { get; set; }
        public List<AnswerInput> Answers { get; set; }
    }

    public class AnswerInput
    {
        public int QuestionId { get; set; }
        public string SelectedAnswer { get; set; }  // "A","B","C","D" hoặc null
    }

    // ── OUTPUT DTOs ──────────────────────────────────────────────────────

    public class ImportExamResultDto
    {
        public bool Success { get; set; }
        public int ExamId { get; set; }
        public int TotalQuestions { get; set; }
        public List<string> Errors { get; set; } = new List<string>();
    }

    public class ExamListItemDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
    }

    public class ExamDetailDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public List<QuestionDto> Level1Questions { get; set; }
        public List<PassageGroupDto> Level2Groups { get; set; }
    }

    public class PassageGroupDto
    {
        public int Id { get; set; }
        public string PassageText { get; set; }
        public string ImagePath { get; set; }
        public int PartNumber { get; set; }
        public List<QuestionDto> Questions { get; set; }
    }

    public class QuestionDto
    {
        public int Id { get; set; }
        public int QuestionNumber { get; set; }
        public string QuestionText { get; set; }
        public List<OptionDto> Options { get; set; }
        // KHÔNG trả về CorrectAnswer cho client khi đang làm bài
    }

    public class OptionDto
    {
        public string OptionKey { get; set; }
        public string OptionText { get; set; }
    }

    public class ExamResultDto
    {
        public long AttemptId { get; set; }
        public int TotalCorrect { get; set; }
        public int TotalWrong { get; set; }
        public int TotalSkipped { get; set; }
        public decimal ScorePercent { get; set; }
    }

    // ── ADMIN DTOs (Xem trước & Chỉnh sửa đề thi) ────────────────────────

    public class AdminExamListItemDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public string Status { get; set; }
        public System.DateTime CreationTime { get; set; }
    }

    public class AdminExamPreviewDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public string Status { get; set; }
        public List<AdminQuestionDto> Level1Questions { get; set; }
        public List<AdminPassageGroupDto> Level2Groups { get; set; }
    }

    public class AdminPassageGroupDto
    {
        public int Id { get; set; }
        public string PassageText { get; set; }
        public string ImagePath { get; set; }
        public int PartNumber { get; set; }
        public List<AdminQuestionDto> Questions { get; set; }
    }

    public class AdminQuestionDto
    {
        public int Id { get; set; }
        public int QuestionNumber { get; set; }
        public string QuestionText { get; set; }
        public string CorrectAnswer { get; set; } // Giảng viên rà soát đáp án đúng
        public List<OptionDto> Options { get; set; }
    }

    public class UpdateExamInput
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
    }

    public class UpdateQuestionInput
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; }
        public string CorrectAnswer { get; set; }
        public List<OptionDto> Options { get; set; }
    }
}

