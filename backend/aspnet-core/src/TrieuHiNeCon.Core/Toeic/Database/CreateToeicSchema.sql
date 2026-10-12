-- ============================================================
-- Script T-SQL: Tạo Schema CSDL Ứng dụng Thi TOEIC
-- Database: SQL Server 2019
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TrieuHiNeConDb')
BEGIN
    CREATE DATABASE TrieuHiNeConDb;
END
GO

USE TrieuHiNeConDb;
GO

-- ============================================================
-- 1. Bảng Đề Thi
-- ============================================================
CREATE TABLE Exams (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    Title            NVARCHAR(256)   NOT NULL,
    [Description]    NVARCHAR(MAX)   NULL,
    DurationMinutes  INT             NOT NULL DEFAULT 75,
    TotalQuestions   INT             NOT NULL DEFAULT 100,
    [Status]         TINYINT         NOT NULL DEFAULT 0,  -- 0=Draft,1=Published,2=Archived
    IsDeleted        BIT             NOT NULL DEFAULT 0,
    CreationTime     DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatorUserId    BIGINT          NULL,
    LastModificationTime DATETIME2   NULL,
    LastModifierUserId   BIGINT      NULL,
    DeletionTime     DATETIME2       NULL,
    DeleterUserId    BIGINT          NULL
);
GO

-- ============================================================
-- 2. Bảng Nhóm Đoạn Văn/Hình Ảnh (Level 2: Part 6 & 7)
-- ============================================================
CREATE TABLE PassageGroups (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    ExamId          INT             NOT NULL REFERENCES Exams(Id),
    PassageText     NVARCHAR(MAX)   NULL,      -- Nội dung đoạn văn
    ImagePath       NVARCHAR(512)   NULL,      -- Đường dẫn ảnh (nếu là passage ảnh)
    OrderIndex      INT             NOT NULL DEFAULT 0,
    PartNumber      INT             NOT NULL,  -- 6 hoặc 7
    IsDeleted       BIT             NOT NULL DEFAULT 0,
    CreationTime    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatorUserId   BIGINT          NULL,
    LastModificationTime DATETIME2  NULL,
    LastModifierUserId   BIGINT     NULL,
    DeletionTime    DATETIME2       NULL,
    DeleterUserId   BIGINT          NULL
);
GO

-- ============================================================
-- 3. Bảng Câu Hỏi
-- PassageGroupId NULL  => Level 1 (Part 5, độc lập)
-- PassageGroupId != NULL => Level 2 (Part 6/7, phụ thuộc passage)
-- ============================================================
CREATE TABLE Questions (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    ExamId           INT             NOT NULL REFERENCES Exams(Id),
    PassageGroupId   INT             NULL REFERENCES PassageGroups(Id),  -- NULL = Level 1
    QuestionNumber   INT             NOT NULL,    -- 101..200
    QuestionText     NVARCHAR(MAX)   NOT NULL,
    PartNumber       INT             NOT NULL,    -- 5, 6, hoặc 7
    CorrectAnswer    CHAR(1)         NOT NULL CHECK (CorrectAnswer IN ('A','B','C','D')),
    Explanation      NVARCHAR(MAX)   NULL,
    IsDeleted        BIT             NOT NULL DEFAULT 0,
    CreationTime     DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatorUserId    BIGINT          NULL,
    LastModificationTime DATETIME2   NULL,
    LastModifierUserId   BIGINT      NULL,
    DeletionTime     DATETIME2       NULL,
    DeleterUserId    BIGINT          NULL,

    CONSTRAINT UQ_ExamQuestion UNIQUE (ExamId, QuestionNumber)
);
GO

-- ============================================================
-- 4. Bảng Đáp Án A/B/C/D
-- ============================================================
CREATE TABLE QuestionOptions (
    Id           INT IDENTITY(1,1) PRIMARY KEY,
    QuestionId   INT             NOT NULL REFERENCES Questions(Id),
    OptionKey    CHAR(1)         NOT NULL CHECK (OptionKey IN ('A','B','C','D')),
    OptionText   NVARCHAR(MAX)   NOT NULL,
    IsDeleted    BIT             NOT NULL DEFAULT 0,
    CreationTime DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatorUserId BIGINT         NULL,
    LastModificationTime DATETIME2 NULL,
    LastModifierUserId   BIGINT   NULL,
    DeletionTime DATETIME2       NULL,
    DeleterUserId BIGINT         NULL,

    CONSTRAINT UQ_QuestionOption UNIQUE (QuestionId, OptionKey)
);
GO

-- ============================================================
-- 5. Bảng Lần Thi của Người Dùng
-- ============================================================
CREATE TABLE ExamAttempts (
    Id           BIGINT IDENTITY(1,1) PRIMARY KEY,
    ExamId       INT             NOT NULL REFERENCES Exams(Id),
    UserId       BIGINT          NOT NULL,
    StartTime    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    SubmitTime   DATETIME2       NULL,
    [Status]     TINYINT         NOT NULL DEFAULT 0,  -- 0=InProgress,1=Submitted,2=TimedOut
    TotalCorrect INT             NULL,
    TotalWrong   INT             NULL,
    TotalSkipped INT             NULL,
    ScorePercent DECIMAL(5,2)    NULL,
    IsDeleted    BIT             NOT NULL DEFAULT 0,
    CreationTime DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatorUserId BIGINT         NULL,
    LastModificationTime DATETIME2 NULL,
    LastModifierUserId   BIGINT   NULL,
    DeletionTime DATETIME2       NULL,
    DeleterUserId BIGINT         NULL
);
GO

-- ============================================================
-- 6. Bảng Câu Trả Lời Của Người Dùng
-- ============================================================
CREATE TABLE UserAnswers (
    Id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    ExamAttemptId   BIGINT          NOT NULL REFERENCES ExamAttempts(Id),
    QuestionId      INT             NOT NULL REFERENCES Questions(Id),
    SelectedAnswer  CHAR(1)         NULL CHECK (SelectedAnswer IN ('A','B','C','D')),  -- NULL = bỏ qua
    IsCorrect       BIT             NULL,                                               -- NULL = chưa chấm
    IsDeleted       BIT             NOT NULL DEFAULT 0,
    CreationTime    DATETIME2       NOT NULL DEFAULT GETUTCDATE(),
    CreatorUserId   BIGINT          NULL,
    LastModificationTime DATETIME2  NULL,
    LastModifierUserId   BIGINT     NULL,
    DeletionTime    DATETIME2       NULL,
    DeleterUserId   BIGINT          NULL,

    CONSTRAINT UQ_AttemptQuestion UNIQUE (ExamAttemptId, QuestionId)
);
GO

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX IX_Questions_ExamId ON Questions(ExamId);
CREATE INDEX IX_Questions_PassageGroupId ON Questions(PassageGroupId);
CREATE INDEX IX_QuestionOptions_QuestionId ON QuestionOptions(QuestionId);
CREATE INDEX IX_ExamAttempts_UserId ON ExamAttempts(UserId);
CREATE INDEX IX_ExamAttempts_ExamId ON ExamAttempts(ExamId);
CREATE INDEX IX_UserAnswers_ExamAttemptId ON UserAnswers(ExamAttemptId);
GO

PRINT 'Database schema created successfully.';
