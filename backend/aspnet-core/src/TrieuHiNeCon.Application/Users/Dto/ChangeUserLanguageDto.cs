using System.ComponentModel.DataAnnotations;

namespace TrieuHiNeCon.Users.Dto;

public class ChangeUserLanguageDto
{
    [Required]
    public string LanguageName { get; set; }
}