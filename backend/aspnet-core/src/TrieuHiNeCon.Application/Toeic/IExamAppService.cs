using System.Collections.Generic;
using System.Threading.Tasks;
using Abp.Application.Services;
using TrieuHiNeCon.Toeic.Dtos;

namespace TrieuHiNeCon.Toeic.AppServices
{
    public interface IExamAppService : IApplicationService
    {
        // Giảng viên / Admin
        Task<ImportExamResultDto> ImportFromWordAsync(ImportExamInput input);
        Task<List<AdminExamListItemDto>> GetAdminExamsAsync();
        Task<AdminExamPreviewDto> GetExamPreviewAsync(int examId);
        Task UpdateExamAsync(UpdateExamInput input);
        Task UpdateQuestionAsync(UpdateQuestionInput input);
        Task PublishExamAsync(int examId);
        Task DeleteExamAsync(int examId);

        // Học viên / Mobile Client
        Task<List<ExamListItemDto>> GetPublishedExamsAsync();
        Task<ExamDetailDto> GetExamForAttemptAsync(int examId);
        Task<long> StartAttemptAsync(int examId);
        Task<ExamResultDto> SubmitAttemptAsync(SubmitAttemptInput input);
    }
}
