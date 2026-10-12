using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using System.Data.Common;

namespace TrieuHiNeCon.EntityFrameworkCore;

public static class TrieuHiNeConDbContextConfigurer
{
    public static void Configure(DbContextOptionsBuilder<TrieuHiNeConDbContext> builder, string connectionString)
    {
        builder.UseSqlServer(connectionString)
               .ConfigureWarnings(w => w.Ignore(RelationalEventId.PendingModelChangesWarning));
    }

    public static void Configure(DbContextOptionsBuilder<TrieuHiNeConDbContext> builder, DbConnection connection)
    {
        builder.UseSqlServer(connection)
               .ConfigureWarnings(w => w.Ignore(RelationalEventId.PendingModelChangesWarning));
    }
}
