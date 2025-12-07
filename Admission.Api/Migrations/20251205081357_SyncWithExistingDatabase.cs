using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Admission.Api.Migrations
{
    public partial class SyncWithExistingDatabase : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ПУСТО - таблицы уже существуют
            
            // ТОЛЬКО если нужно создать индексы или constraints, которые отсутствуют
            // Добавьте их здесь, но НЕ CreateTable!
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // ПУСТО - не удаляем существующие таблицы
        }
    }
}