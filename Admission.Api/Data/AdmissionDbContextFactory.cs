using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace Admission.Api.Data
{
    public class AdmissionDbContextFactory : IDesignTimeDbContextFactory<AdmissionDbContext>
    {
        public AdmissionDbContext CreateDbContext(string[] args)
        {
            // Настройка конфигурации
            IConfigurationRoot configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json")
                .AddJsonFile("appsettings.Development.json", optional: true)
                .Build();

            // Получение строки подключения
            var connectionString = configuration.GetConnectionString("DefaultConnection");

            // Настройка опций DbContext
            var optionsBuilder = new DbContextOptionsBuilder<AdmissionDbContext>();
            optionsBuilder.UseNpgsql(connectionString);

            return new AdmissionDbContext(optionsBuilder.Options);
        }
    }
}