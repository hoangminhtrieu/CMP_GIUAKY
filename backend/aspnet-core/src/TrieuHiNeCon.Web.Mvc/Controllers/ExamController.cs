using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.AspNetCore.Mvc.Controllers;
using Abp.Web.Models;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TrieuHiNeCon.Toeic.AppServices;
using TrieuHiNeCon.Toeic.Dtos;

namespace TrieuHiNeCon.Web.Controllers
{
    public class ExamController : AbpController
    {
        private readonly ExamAppService _examService;

        public ExamController(ExamAppService examService)
        {
            _examService = examService;
        }

        // ==============================================================
        // ADMIN MVC VIEWS (Website dành cho Giảng viên / Quản trị viên)
        // ==============================================================

        // GET: /Exam hoặc /Exam/Index - Danh sách đề thi
        public async Task<IActionResult> Index()
        {
            var exams = await _examService.GetAdminExamsAsync();
            return View(exams);
        }

        // GET: /Exam/Import - Giao diện upload file Word
        public IActionResult Import()
        {
            return View();
        }

        // GET: /Exam/Preview/5 - Xem trước đề thi, rà soát lỗi chính tả, đáp án
        public async Task<IActionResult> Preview(int id)
        {
            var exam = await _examService.GetExamPreviewAsync(id);
            return View(exam);
        }

        // GET: /Exam/Edit/5 - Giao diện chỉnh sửa đề thi & câu hỏi
        public async Task<IActionResult> Edit(int id)
        {
            var exam = await _examService.GetExamPreviewAsync(id);
            return View(exam);
        }

        // GET: /Exam/Take/5 - Giao diện làm bài thi TOEIC trực tuyến (Figma UI Flow)
        public async Task<IActionResult> Take(int id)
        {
            var exam = await _examService.GetExamPreviewAsync(id);
            if (exam == null) return NotFound();
            return View(exam);
        }

        // ==============================================================
        // ADMIN ACTIONS & APIs
        // ==============================================================

        // POST: /Exam/Import hoặc /api/exam/import
        [HttpPost]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/import")]
        [Route("Exam/Import")]
        [RequestSizeLimit(20 * 1024 * 1024)] // 20MB
        public async Task<IActionResult> ImportFile(
            [FromForm] string title,
            [FromForm] string description,
            IFormFile file)
        {
            var result = await _examService.ImportFromWordAsync(new ImportExamInput
            {
                Title = title,
                Description = description,
                File = file
            });

            if (!result.Success)
            {
                return BadRequest(new
                {
                    success = false,
                    message = "Import thất bại! File chưa đúng chuẩn định dạng bộ thẻ.",
                    errors = result.Errors
                });
            }

            return Ok(new
            {
                success = true,
                message = $"Import thành công {result.TotalQuestions} câu hỏi.",
                examId = result.ExamId
            });
        }

        [HttpPost]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/updateExam")]
        public async Task<IActionResult> UpdateExam([FromBody] UpdateExamInput input)
        {
            await _examService.UpdateExamAsync(input);
            return Ok(new { success = true, message = "Đã cập nhật thông tin đề thi thành công." });
        }

        [HttpPost]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/updateQuestion")]
        public async Task<IActionResult> UpdateQuestion([FromBody] UpdateQuestionInput input)
        {
            await _examService.UpdateQuestionAsync(input);
            return Ok(new { success = true, message = "Đã cập nhật câu hỏi thành công." });
        }

        [HttpPost]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/publish/{id}")]
        public async Task<IActionResult> Publish(int id)
        {
            await _examService.PublishExamAsync(id);
            return Ok(new { success = true, message = "Đề thi đã được công bố cho học viên làm bài." });
        }

        [HttpPost]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/delete/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _examService.DeleteExamAsync(id);
            return Ok(new { success = true, message = "Đã xóa đề thi." });
        }

        // ==============================================================
        // CLIENT / MOBILE APIS (Dành cho ứng dụng Flutter & Web)
        // ==============================================================

        // GET /api/exam/list
        [HttpGet]
        [EnableCors("AllowAll")]
        [DontWrapResult]
        [Route("api/exam/list")]
        public async Task<IActionResult> List()
        {
            var exams = await _examService.GetPublishedExamsAsync();
            return Ok(exams);
        }

        // GET /api/exam/preview-data/{examId} (Full 100 questions for React / Web)
        [HttpGet]
        [EnableCors("AllowAll")]
        [DontWrapResult]
        [Route("api/exam/preview-data/{examId}")]
        public async Task<IActionResult> PreviewData(int examId)
        {
            var preview = await _examService.GetExamPreviewAsync(examId);
            return Ok(preview);
        }

        // GET /api/exam/detail/{examId}
        [HttpGet]
        [EnableCors("AllowAll")]
        [DontWrapResult]
        [Route("api/exam/detail/{examId}")]
        public async Task<IActionResult> Detail(int examId)
        {
            var detail = await _examService.GetExamForAttemptAsync(examId);
            return Ok(detail);
        }

        // POST /api/exam/start/{examId}
        [HttpPost]
        [EnableCors("AllowAll")]
        [DontWrapResult]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/start/{examId}")]
        public async Task<IActionResult> Start(int examId)
        {
            long attemptId = await _examService.StartAttemptAsync(examId);
            return Ok(new { attemptId });
        }

        // POST /api/exam/submit
        [HttpPost]
        [EnableCors("AllowAll")]
        [DontWrapResult]
        [IgnoreAntiforgeryToken]
        [Route("api/exam/submit")]
        public async Task<IActionResult> Submit([FromBody] SubmitAttemptInput input)
        {
            var result = await _examService.SubmitAttemptAsync(input);
            return Ok(result);
        }
    }
}
