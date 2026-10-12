using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Abp.Domain.Services;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using TrieuHiNeCon.Toeic.Entities;

namespace TrieuHiNeCon.Toeic.Services
{
    /// <summary>
    /// Kết quả parse một file Word.
    /// Nếu HasError = true thì KHÔNG được lưu vào CSDL.
    /// </summary>
    public class WordParseResult
    {
        public bool HasError { get; set; }
        public List<string> Errors { get; set; } = new List<string>();
        public List<Question> Level1Questions { get; set; } = new List<Question>();
        public List<(PassageGroup Group, List<Question> Questions)> Level2Groups { get; set; }
            = new List<(PassageGroup, List<Question>)>();
    }

    /// <summary>
    /// Domain Service đọc và parse file .docx theo bộ thẻ chuẩn.
    /// Áp dụng kiểm tra nghiêm ngặt: có bất kỳ lỗi nào => hủy toàn bộ.
    /// </summary>
    public class WordDocumentParser : IDomainService
    {
        private static readonly HashSet<string> ValidAnswers = new HashSet<string> { "A", "B", "C", "D" };

        /// <summary>
        /// Parse file Word từ stream, trả về WordParseResult.
        /// Gọi code này TRƯỚC khi lưu vào DB.
        /// </summary>
        public WordParseResult Parse(Stream docxStream)
        {
            var result = new WordParseResult();
            string[] lines;

            // 1. Đọc tất cả dòng text từ docx
            try
            {
                lines = ExtractTextLines(docxStream);
            }
            catch (Exception ex)
            {
                result.HasError = true;
                result.Errors.Add($"Không thể đọc file Word: {ex.Message}");
                return result;
            }

            // 2. Parse từng block
            int i = 0;
            int expectedQuestionNumber = 101;

            while (i < lines.Length)
            {
                string line = lines[i].Trim();

                if (line == "[L1]")
                {
                    var (q, err, nextIdx) = ParseLevel1Block(lines, i + 1, expectedQuestionNumber);
                    result.Errors.AddRange(err);
                    if (q != null)
                    {
                        result.Level1Questions.Add(q);
                        expectedQuestionNumber++;
                    }
                    i = nextIdx;
                }
                else if (line == "[L2]")
                {
                    var (group, questions, err2, nextIdx) = ParseLevel2Block(lines, i + 1, ref expectedQuestionNumber);
                    result.Errors.AddRange(err2);
                    if (group != null)
                        result.Level2Groups.Add((group, questions));
                    i = nextIdx;
                }
                else if (!string.IsNullOrWhiteSpace(line))
                {
                    // Dòng không nhận dạng được
                    i++;
                }
                else
                {
                    i++;
                }
            }

            result.HasError = result.Errors.Any();
            return result;
        }

        // -----------------------------------------------------------------
        // Parse một block Level 1 (Part 5)
        // -----------------------------------------------------------------
        private (Question q, List<string> errors, int nextIdx)
            ParseLevel1Block(string[] lines, int start, int expectedNumber)
        {
            var errors = new List<string>();
            var q = new Question { PartNumber = 5, Options = new List<QuestionOption>() };
            int i = start;
            bool foundEnd = false;

            while (i < lines.Length)
            {
                string line = lines[i].Trim();

                if (line == "[END]") { foundEnd = true; i++; break; }
                if (line.StartsWith("[Q:"))
                {
                    var m = Regex.Match(line, @"^\[Q:(\d+)\]\s*(.+)$");
                    if (!m.Success)
                    {
                        errors.Add($"Dòng {i + 1}: Thẻ [Q] không đúng định dạng: {line}");
                    }
                    else
                    {
                        int num = int.Parse(m.Groups[1].Value);
                        if (num != expectedNumber)
                            errors.Add($"Dòng {i + 1}: Sai thứ tự câu. Mong đợi {expectedNumber}, nhận {num}.");
                        q.QuestionNumber = num;
                        q.QuestionText = m.Groups[2].Value.Trim();
                    }
                }
                else if (Regex.IsMatch(line, @"^\[([ABCD])\]\s*(.+)$"))
                {
                    var m = Regex.Match(line, @"^\[([ABCD])\]\s*(.+)$");
                    q.Options.Add(new QuestionOption
                    {
                        OptionKey = m.Groups[1].Value,
                        OptionText = m.Groups[2].Value.Trim()
                    });
                }
                else if (line.StartsWith("[ANS:"))
                {
                    var m = Regex.Match(line, @"^\[ANS:([A-D])\]$");
                    if (!m.Success)
                        errors.Add($"Dòng {i + 1}: Thẻ [ANS] không hợp lệ: {line}");
                    else
                        q.CorrectAnswer = m.Groups[1].Value;
                }
                else if (!string.IsNullOrWhiteSpace(line))
                {
                    errors.Add($"Dòng {i + 1}: Dòng không nhận dạng được trong block [L1]: {line}");
                }

                i++;
            }

            if (!foundEnd)
                errors.Add($"Block [L1] câu {expectedNumber}: Thiếu thẻ [END].");
            if (q.Options.Count != 4)
                errors.Add($"Câu {expectedNumber}: Cần đúng 4 đáp án A/B/C/D, nhận {q.Options.Count}.");
            if (string.IsNullOrEmpty(q.CorrectAnswer))
                errors.Add($"Câu {expectedNumber}: Thiếu thẻ [ANS].");
            if (string.IsNullOrEmpty(q.QuestionText))
                errors.Add($"Câu {expectedNumber}: Thiếu thẻ [Q].");

            return errors.Any() ? (null, errors, i) : (q, errors, i);
        }

        // -----------------------------------------------------------------
        // Parse một block Level 2 (Part 6 / Part 7)
        // -----------------------------------------------------------------
        private (PassageGroup group, List<Question> questions, List<string> errors, int nextIdx)
            ParseLevel2Block(string[] lines, int start, ref int expectedNumber)
        {
            var errors = new List<string>();
            var group = new PassageGroup();
            var questions = new List<Question>();
            int i = start;
            bool inPassage = false;
            var passageBuilder = new System.Text.StringBuilder();
            bool foundEnd = false;

            while (i < lines.Length)
            {
                string line = lines[i].Trim();

                if (line == "[END]") { foundEnd = true; i++; break; }

                if (line == "[PASSAGE]") { inPassage = true; i++; continue; }
                if (line == "[/PASSAGE]") { inPassage = false; group.PassageText = passageBuilder.ToString().Trim(); i++; continue; }
                if (inPassage) { passageBuilder.AppendLine(lines[i]); i++; continue; }

                if (line.StartsWith("[IMAGE:"))
                {
                    var m = Regex.Match(line, @"^\[IMAGE:(.+)\]$");
                    if (!m.Success) errors.Add($"Dòng {i + 1}: Thẻ [IMAGE] sai định dạng.");
                    else group.ImagePath = m.Groups[1].Value.Trim();
                }
                else if (line.StartsWith("[Q:"))
                {
                    var (q, qErrors, nextI) = ParseLevel1Block(lines, i, expectedNumber);
                    // Level1Block sẽ tiêu thụ từ dòng [Q:...] trở đi, nhưng ở đây
                    // câu hỏi nằm trong L2 nên parse riêng
                    var m = Regex.Match(line, @"^\[Q:(\d+)\]\s*(.+)$");
                    if (!m.Success)
                    {
                        errors.Add($"Dòng {i + 1}: Thẻ [Q] không đúng: {line}");
                        i++;
                        continue;
                    }
                    int num = int.Parse(m.Groups[1].Value);
                    if (num != expectedNumber)
                        errors.Add($"Dòng {i + 1}: Sai thứ tự câu. Mong đợi {expectedNumber}, nhận {num}.");

                    var question = new Question
                    {
                        QuestionNumber = num,
                        QuestionText = m.Groups[2].Value.Trim(),
                        PartNumber = group.PartNumber > 0 ? group.PartNumber : 7,
                        Options = new List<QuestionOption>()
                    };
                    i++;

                    // Đọc A/B/C/D và ANS cho câu này
                    while (i < lines.Length)
                    {
                        string inner = lines[i].Trim();
                        if (inner.StartsWith("[Q:") || inner == "[END]") break;
                        if (Regex.IsMatch(inner, @"^\[([ABCD])\]\s*(.+)$"))
                        {
                            var om = Regex.Match(inner, @"^\[([ABCD])\]\s*(.+)$");
                            question.Options.Add(new QuestionOption
                            {
                                OptionKey = om.Groups[1].Value,
                                OptionText = om.Groups[2].Value.Trim()
                            });
                        }
                        else if (inner.StartsWith("[ANS:"))
                        {
                            var am = Regex.Match(inner, @"^\[ANS:([A-D])\]$");
                            if (!am.Success) errors.Add($"Dòng {i + 1}: [ANS] sai định dạng.");
                            else question.CorrectAnswer = am.Groups[1].Value;
                        }
                        else if (!string.IsNullOrWhiteSpace(inner))
                        {
                            errors.Add($"Dòng {i + 1}: Dòng không nhận dạng trong câu {num}: {inner}");
                        }
                        i++;
                    }

                    if (question.Options.Count != 4)
                        errors.Add($"Câu {num}: Cần đúng 4 đáp án, nhận {question.Options.Count}.");
                    if (string.IsNullOrEmpty(question.CorrectAnswer))
                        errors.Add($"Câu {num}: Thiếu [ANS].");

                    questions.Add(question);
                    expectedNumber++;
                    continue;
                }
                else if (!string.IsNullOrWhiteSpace(line))
                {
                    errors.Add($"Dòng {i + 1}: Dòng không nhận dạng trong block [L2]: {line}");
                }

                i++;
            }

            if (!foundEnd)
                errors.Add("Block [L2]: Thiếu thẻ [END].");
            if (string.IsNullOrEmpty(group.PassageText) && string.IsNullOrEmpty(group.ImagePath))
                errors.Add("Block [L2]: Thiếu [PASSAGE] hoặc [IMAGE].");
            if (questions.Count < 2)
                errors.Add("Block [L2]: Cần ít nhất 2 câu hỏi.");

            return (errors.Any() ? null : group, questions, errors, i);
        }

        // -----------------------------------------------------------------
        // Trích xuất text từ file .docx
        // -----------------------------------------------------------------
        private string[] ExtractTextLines(Stream stream)
        {
            var lines = new List<string>();
            using (var doc = WordprocessingDocument.Open(stream, false))
            {
                var body = doc.MainDocumentPart.Document.Body;
                foreach (var para in body.Descendants<Paragraph>())
                {
                    lines.Add(para.InnerText);
                }
            }
            return lines.ToArray();
        }
    }
}
