using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Abp.Application.Services;
using Abp.Domain.Repositories;
using Abp.UI;
using Microsoft.AspNetCore.Http;
using TrieuHiNeCon.Toeic.Dtos;
using TrieuHiNeCon.Toeic.Entities;
using TrieuHiNeCon.Toeic.Services;

namespace TrieuHiNeCon.Toeic.AppServices
{
    public class ExamAppService : ApplicationService, IExamAppService
    {
        private readonly IRepository<Exam, int> _examRepo;
        private readonly IRepository<PassageGroup, int> _passageRepo;
        private readonly IRepository<Question, int> _questionRepo;
        private readonly IRepository<QuestionOption, int> _optionRepo;
        private readonly IRepository<ExamAttempt, long> _attemptRepo;
        private readonly IRepository<UserAnswer, long> _answerRepo;
        private readonly WordDocumentParser _parser;

        public ExamAppService(
            IRepository<Exam, int> examRepo,
            IRepository<PassageGroup, int> passageRepo,
            IRepository<Question, int> questionRepo,
            IRepository<QuestionOption, int> optionRepo,
            IRepository<ExamAttempt, long> attemptRepo,
            IRepository<UserAnswer, long> answerRepo,
            WordDocumentParser parser)
        {
            _examRepo = examRepo;
            _passageRepo = passageRepo;
            _questionRepo = questionRepo;
            _optionRepo = optionRepo;
            _attemptRepo = attemptRepo;
            _answerRepo = answerRepo;
            _parser = parser;
        }

        // ---------------------------------------------------------------
        // 1. Upload & Import đề thi từ file Word
        // ---------------------------------------------------------------
        public async Task<ImportExamResultDto> ImportFromWordAsync(ImportExamInput input)
        {
            if (input.File == null || input.File.Length == 0)
                throw new UserFriendlyException("Vui lòng chọn file .docx.");

            if (!input.File.FileName.EndsWith(".docx", StringComparison.OrdinalIgnoreCase))
                throw new UserFriendlyException("Chỉ chấp nhận file định dạng .docx.");

            // 1. Parse file Word
            WordParseResult parseResult;
            using (var stream = input.File.OpenReadStream())
            {
                parseResult = _parser.Parse(stream);
            }

            // 2. Nếu có bất kỳ lỗi nào => HỦY TOÀN BỘ, không lưu
            if (parseResult.HasError)
            {
                return new ImportExamResultDto
                {
                    Success = false,
                    Errors = parseResult.Errors
                };
            }

            // 3. Kiểm tra tổng số câu hỏi
            int totalL1 = parseResult.Level1Questions.Count;
            int totalL2 = parseResult.Level2Groups.Sum(g => g.Questions.Count);
            int total = totalL1 + totalL2;
            if (total != 100)
            {
                return new ImportExamResultDto
                {
                    Success = false,
                    Errors = new List<string> { $"Đề thi phải có đúng 100 câu hỏi (101–200). Hiện có {total} câu." }
                };
            }

            // 4. Tạo Exam trong DB (sử dụng UoW của ABP, tự rollback nếu lỗi)
            var exam = new Exam
            {
                Title = input.Title,
                Description = input.Description,
                DurationMinutes = 75,
                TotalQuestions = 100,
                Status = ExamStatus.Draft
            };
            int examId = await _examRepo.InsertAndGetIdAsync(exam);

            // 5. Lưu Level 1
            foreach (var q in parseResult.Level1Questions)
            {
                q.ExamId = examId;
                var options = q.Options?.ToList() ?? new List<QuestionOption>();
                q.Options = null;
                int qId = await _questionRepo.InsertAndGetIdAsync(q);
                foreach (var opt in options)
                {
                    opt.Id = 0;
                    opt.QuestionId = qId;
                    await _optionRepo.InsertAsync(opt);
                }
            }

            // 6. Lưu Level 2
            foreach (var (group, questions) in parseResult.Level2Groups)
            {
                group.ExamId = examId;
                int groupId = await _passageRepo.InsertAndGetIdAsync(group);
                foreach (var q in questions)
                {
                    q.ExamId = examId;
                    q.PassageGroupId = groupId;
                    var options = q.Options?.ToList() ?? new List<QuestionOption>();
                    q.Options = null;
                    int qId = await _questionRepo.InsertAndGetIdAsync(q);
                    foreach (var opt in options)
                    {
                        opt.Id = 0;
                        opt.QuestionId = qId;
                        await _optionRepo.InsertAsync(opt);
                    }
                }
            }

            return new ImportExamResultDto
            {
                Success = true,
                ExamId = examId,
                TotalQuestions = total
            };
        }

        // ---------------------------------------------------------------
        // 2. Danh sách đề thi (cho Flutter)
        // ---------------------------------------------------------------
        public async Task<List<ExamListItemDto>> GetPublishedExamsAsync()
        {
            var exams = await _examRepo.GetAllListAsync(e =>
                e.Status == ExamStatus.Published && !e.IsDeleted);

            return exams.Select(e => new ExamListItemDto
            {
                Id = e.Id,
                Title = e.Title,
                DurationMinutes = e.DurationMinutes,
                TotalQuestions = e.TotalQuestions
            }).ToList();
        }

        // ---------------------------------------------------------------
        // 3. Lấy chi tiết đề thi để làm bài
        // ---------------------------------------------------------------
        public async Task<ExamDetailDto> GetExamForAttemptAsync(int examId)
        {
            var exam = await _examRepo.GetAsync(examId);
            if (exam.Status != ExamStatus.Published)
                throw new UserFriendlyException("Đề thi chưa được công bố.");

            var questions = await _questionRepo.GetAllListAsync(q => q.ExamId == examId);
            var passages = await _passageRepo.GetAllListAsync(p => p.ExamId == examId);
            var allOptions = await _optionRepo.GetAllListAsync(o => questions.Select(q => q.Id).Contains(o.QuestionId));

            foreach (var q in questions)
            {
                q.Options = allOptions.Where(o => o.QuestionId == q.Id).OrderBy(o => o.OptionKey).ToList();
            }

            var dto = new ExamDetailDto
            {
                Id = exam.Id,
                Title = exam.Title,
                DurationMinutes = exam.DurationMinutes,
                TotalQuestions = exam.TotalQuestions,
                Level1Questions = questions
                    .Where(q => q.PassageGroupId == null)
                    .OrderBy(q => q.QuestionNumber)
                    .Select(MapToQuestionDto).ToList(),
                Level2Groups = passages
                    .OrderBy(p => p.OrderIndex)
                    .Select(p => new PassageGroupDto
                    {
                        Id = p.Id,
                        PassageText = p.PassageText,
                        ImagePath = p.ImagePath,
                        PartNumber = p.PartNumber,
                        Questions = questions
                            .Where(q => q.PassageGroupId == p.Id)
                            .OrderBy(q => q.QuestionNumber)
                            .Select(MapToQuestionDto).ToList()
                    }).ToList()
            };

            return dto;
        }

        // ---------------------------------------------------------------
        // 4. Bắt đầu lần thi
        // ---------------------------------------------------------------
        public async Task<long> StartAttemptAsync(int examId)
        {
            var attempt = new ExamAttempt
            {
                ExamId = examId,
                UserId = AbpSession.UserId ?? 0,
                StartTime = DateTime.UtcNow,
                Status = AttemptStatus.InProgress
            };
            return await _attemptRepo.InsertAndGetIdAsync(attempt);
        }

        // ---------------------------------------------------------------
        // 5. Nộp bài & Chấm điểm
        // ---------------------------------------------------------------
        public async Task<ExamResultDto> SubmitAttemptAsync(SubmitAttemptInput input)
        {
            var attempt = await _attemptRepo.GetAsync(input.AttemptId);
            if (attempt.UserId != (AbpSession.UserId ?? 0))
                throw new UserFriendlyException("Không có quyền nộp bài này.");
            if (attempt.Status != AttemptStatus.InProgress)
                throw new UserFriendlyException("Bài thi đã được nộp.");

            // Lấy tất cả câu hỏi của đề
            var questions = await _questionRepo.GetAllListAsync(q => q.ExamId == attempt.ExamId);
            var questionDict = questions.ToDictionary(q => q.Id, q => q.CorrectAnswer);

            int correct = 0, wrong = 0, skipped = 0;

            foreach (var q in questions)
            {
                var submitted = input.Answers?.FirstOrDefault(a => a.QuestionId == q.Id);
                string selected = submitted?.SelectedAnswer;
                bool? isCorrect = null;

                if (string.IsNullOrEmpty(selected))
                {
                    skipped++;
                }
                else if (selected == q.CorrectAnswer)
                {
                    correct++;
                    isCorrect = true;
                }
                else
                {
                    wrong++;
                    isCorrect = false;
                }

                await _answerRepo.InsertAsync(new UserAnswer
                {
                    ExamAttemptId = attempt.Id,
                    QuestionId = q.Id,
                    SelectedAnswer = selected,
                    IsCorrect = isCorrect
                });
            }

            // Cập nhật kết quả
            attempt.SubmitTime = DateTime.UtcNow;
            attempt.Status = input.IsTimedOut ? AttemptStatus.TimedOut : AttemptStatus.Submitted;
            attempt.TotalCorrect = correct;
            attempt.TotalWrong = wrong;
            attempt.TotalSkipped = skipped;
            attempt.ScorePercent = questions.Count > 0
                ? Math.Round((decimal)correct / questions.Count * 100, 2) : 0;

            await _attemptRepo.UpdateAsync(attempt);

            return new ExamResultDto
            {
                AttemptId = attempt.Id,
                TotalCorrect = correct,
                TotalWrong = wrong,
                TotalSkipped = skipped,
                ScorePercent = attempt.ScorePercent ?? 0
            };
        }

        // ---------------------------------------------------------------
        // 6. ADMIN: Lấy danh sách đề thi quản lý
        // ---------------------------------------------------------------
        public async Task<List<AdminExamListItemDto>> GetAdminExamsAsync()
        {
            var exams = await _examRepo.GetAllListAsync(e => !e.IsDeleted);
            return exams.OrderByDescending(e => e.CreationTime).Select(e => new AdminExamListItemDto
            {
                Id = e.Id,
                Title = e.Title,
                Description = e.Description,
                DurationMinutes = e.DurationMinutes,
                TotalQuestions = e.TotalQuestions,
                Status = e.Status.ToString(),
                CreationTime = e.CreationTime
            }).ToList();
        }

        // ---------------------------------------------------------------
        // 7. ADMIN: Xem trước đề thi & rà soát lỗi chính tả, đáp án
        // ---------------------------------------------------------------
        public async Task<AdminExamPreviewDto> GetExamPreviewAsync(int examId)
        {
            var exam = await _examRepo.GetAsync(examId);
            var questions = await _questionRepo.GetAllListAsync(q => q.ExamId == examId);
            var passages = await _passageRepo.GetAllListAsync(p => p.ExamId == examId);
            var allOptions = await _optionRepo.GetAllListAsync(o => questions.Select(q => q.Id).Contains(o.QuestionId));

            foreach (var q in questions)
            {
                q.Options = allOptions.Where(o => o.QuestionId == q.Id).OrderBy(o => o.OptionKey).ToList();
            }

            var dto = new AdminExamPreviewDto
            {
                Id = exam.Id,
                Title = exam.Title,
                Description = exam.Description,
                DurationMinutes = exam.DurationMinutes,
                TotalQuestions = exam.TotalQuestions,
                Status = exam.Status.ToString(),
                Level1Questions = questions
                    .Where(q => q.PassageGroupId == null)
                    .OrderBy(q => q.QuestionNumber)
                    .Select(MapToAdminQuestionDto).ToList(),
                Level2Groups = passages
                    .OrderBy(p => p.OrderIndex)
                    .Select(p => new AdminPassageGroupDto
                    {
                        Id = p.Id,
                        PassageText = p.PassageText,
                        ImagePath = p.ImagePath,
                        PartNumber = p.PartNumber,
                        Questions = questions
                            .Where(q => q.PassageGroupId == p.Id)
                            .OrderBy(q => q.QuestionNumber)
                            .Select(MapToAdminQuestionDto).ToList()
                    }).ToList()
            };

            return dto;
        }

        // ---------------------------------------------------------------
        // 8. ADMIN: Chỉnh sửa thông tin đề thi
        // ---------------------------------------------------------------
        public async Task UpdateExamAsync(UpdateExamInput input)
        {
            var exam = await _examRepo.GetAsync(input.Id);
            exam.Title = input.Title;
            exam.Description = input.Description;
            await _examRepo.UpdateAsync(exam);
        }

        // ---------------------------------------------------------------
        // 9. ADMIN: Chỉnh sửa nội dung câu hỏi và đáp án
        // ---------------------------------------------------------------
        public async Task UpdateQuestionAsync(UpdateQuestionInput input)
        {
            var question = await _questionRepo.GetAsync(input.QuestionId);
            question.QuestionText = input.QuestionText;
            if (!string.IsNullOrEmpty(input.CorrectAnswer))
            {
                question.CorrectAnswer = input.CorrectAnswer.ToUpper();
            }
            await _questionRepo.UpdateAsync(question);

            if (input.Options != null && input.Options.Count > 0)
            {
                var options = await _optionRepo.GetAllListAsync(o => o.QuestionId == input.QuestionId);
                foreach (var optInput in input.Options)
                {
                    var opt = options.FirstOrDefault(o => o.OptionKey == optInput.OptionKey);
                    if (opt != null)
                    {
                        opt.OptionText = optInput.OptionText;
                        await _optionRepo.UpdateAsync(opt);
                    }
                }
            }
        }

        // ---------------------------------------------------------------
        // 10. ADMIN: Công bố đề thi (cho phép học viên thi)
        // ---------------------------------------------------------------
        public async Task PublishExamAsync(int examId)
        {
            var exam = await _examRepo.GetAsync(examId);
            exam.Status = ExamStatus.Published;
            await _examRepo.UpdateAsync(exam);
        }

        // ---------------------------------------------------------------
        // 11. ADMIN: Xóa đề thi
        // ---------------------------------------------------------------
        public async Task DeleteExamAsync(int examId)
        {
            await _examRepo.DeleteAsync(examId);
        }

        private static AdminQuestionDto MapToAdminQuestionDto(Question q) => new AdminQuestionDto
        {
            Id = q.Id,
            QuestionNumber = q.QuestionNumber,
            QuestionText = q.QuestionText,
            CorrectAnswer = q.CorrectAnswer,
            Options = q.Options?.Select(o => new OptionDto
            {
                OptionKey = o.OptionKey,
                OptionText = o.OptionText
            }).ToList() ?? new List<OptionDto>()
        };

        private static QuestionDto MapToQuestionDto(Question q) => new QuestionDto
        {
            Id = q.Id,
            QuestionNumber = q.QuestionNumber,
            QuestionText = q.QuestionText,
            Options = q.Options?.Select(o => new OptionDto
            {
                OptionKey = o.OptionKey,
                OptionText = o.OptionText
            }).ToList() ?? new List<OptionDto>()
        };
    }
}

